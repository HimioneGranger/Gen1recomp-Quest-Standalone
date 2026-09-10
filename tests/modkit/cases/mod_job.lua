-- mod.job: background compute for sandboxed mods, behind the "background"
-- permission.  The worker rebuilds the mod's sandbox before loading its
-- script, so what this file pins is the contract that keeps a job from being
-- love.thread by another name -- plain data only, paths that cannot climb,
-- handles that do not cross mods, and ceilings on how much a mod can start.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Job = require("src.mods.Job")

local WORKER = {
  ["mods/job_worker_mod/manifest.json"] = [[{
    "id": "job_worker_mod",
    "name": "Job Worker",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2,
    "permissions": ["background"]
  }]],
  ["mods/job_worker_mod/main.lua"] = [[
    local mod = ...
    mod.exports.available = mod.job:available()
    mod.exports.run = function(script, arg, opts)
      return mod.job:run(script, arg, opts)
    end
    mod.exports.poll = function(h) return mod.job:poll(h) end
    mod.exports.release = function(h) return mod.job:release(h) end
    mod.exports.cancel = function(h) return mod.job:cancel(h) end
  ]],
  ["mods/job_worker_mod/jobs/crunch.lua"] = [[
    local arg = ...
    local total = 0
    for i = 1, (arg and arg.n or 0) do total = total + i end
    return { total = total }
  ]],
}

local OTHER = {
  ["mods/job_other/manifest.json"] = [[{
    "id": "job_other",
    "name": "Job Other",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2,
    "permissions": ["background"]
  }]],
  ["mods/job_other/main.lua"] = [[
    local mod = ...
    mod.exports.poll = function(h) return mod.job:poll(h) end
    mod.exports.cancel = function(h) return mod.job:cancel(h) end
  ]],
}

local UNPERMISSIONED = {
  ["mods/job_probe/manifest.json"] = [[{
    "id": "job_probe",
    "name": "Job Probe",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2
  }]],
  ["mods/job_probe/main.lua"] = [[
    local mod = ...
    mod.exports.available = mod.job:available()
    local ok, err = pcall(function() return mod.job:run("jobs/x.lua") end)
    mod.exports.refused = not ok and tostring(err) or false
  ]],
}

local function merged(...)
  local out = {}
  for _, fixture in ipairs({ ... }) do
    for path, body in pairs(fixture) do out[path] = body end
  end
  return out
end

-- ------------------------------------------------- plain-data enforcement
-- Nothing but plain data can cross a thread boundary; a function reaching
-- LÖVE's serialiser fails deep inside it instead of at the mod's own call.
local okData, dataErr = Job.plain({ a = 1, b = "two", c = { d = true } })
T.check(okData and okData.c.d == true, "plain data survives the copy")
T.check(select(2, Job.plain({ f = function() end })),
  "a function is refused")
T.check(select(2, Job.plain(function() end)), "a bare function is refused")
T.check(select(2, Job.plain({ [{}] = 1 })), "a table key is refused")
local cycle = {}; cycle.self = cycle
T.check(select(2, Job.plain(cycle)), "a cycle is refused, not hung on")
local deep = {}
local cur = deep
for _ = 1, Job.MAX_DEPTH + 4 do cur.next = {}; cur = cur.next end
T.check(select(2, Job.plain(deep)), "absurd nesting is refused")
T.eq(dataErr, nil, "a clean table reports no error")

-- the copy is a copy: mutating the source does not reach the copy
local src = { n = 1 }
local copied = Job.plain(src)
src.n = 99
T.eq(copied.n, 1, "the payload is snapshotted, not referenced")

-- ------------------------------------------------------- permissioned use
local run = T.sdk.loadMods({ "mods/job_worker_mod", "mods/job_other" },
  { fs = T.sdk.memfs(merged(WORKER, OTHER)) })
T.eq(#run.errors, 0,
  "the permissioned mods load clean (" .. tostring(run.errors[1]) .. ")")
local api = run.loader.exports.job_worker_mod

-- The test harness has no love.thread, so run() reports that rather than
-- pretending; the gating, path and data rules above it still apply and are
-- what this suite exists to pin.
local handle, why = api.run("jobs/crunch.lua", { n = 10 })
if Job.available() then
  T.check(handle ~= nil, "run() returns a handle (" .. tostring(why) .. ")")
  T.eq(type(handle), "table", "the handle is opaque")
else
  T.eq(handle, nil, "run() reports when the host has no threads")
  T.check(why and why:find("unavailable", 1, true), "and says so plainly")
end

-- ------------------------------------------------------ paths cannot climb
-- A job script is named inside the mod's own folder, the same rule mod:read
-- follows.  A job is not a way to name a path.
-- These assert the PATH message specifically: "unavailable" is also truthy,
-- so a loose check here would pass even with the path rules removed.
local _, climbErr = api.run("../../../etc/passwd", {})
T.check(climbErr and climbErr:find("inside its root", 1, true),
  "a climbing path is refused (" .. tostring(climbErr) .. ")")
local _, absErr = api.run("/etc/passwd", {})
T.check(absErr and absErr:find("inside its root", 1, true),
  "an absolute path is refused")
local _, driveErr = api.run("C:/windows/system32/x.lua", {})
T.check(driveErr and driveErr:find("inside its root", 1, true),
  "a drive-relative path is refused")
local _, emptyErr = api.run("", {})
T.check(emptyErr and emptyErr:find("script path", 1, true),
  "an empty path is refused")
local _, typeErr = api.run(nil, {})
T.check(typeErr and typeErr:find("script path", 1, true),
  "a non-string path is refused")

-- a function in the argument is caught at the mod's call, not in LÖVE
local _, argErr = api.run("jobs/crunch.lua", { cb = function() end })
T.check(argErr and argErr:find("plain data", 1, true),
  "a non-serialisable argument is refused with a reason")

-- ------------------------------------------- handles do not cross mods
local other = run.loader.exports.job_other
T.eq(api.poll({}).status, "error", "a forged handle reads as an error")
T.eq(api.poll(1).status, "error", "a guessed id reads as an error")
if handle then
  T.eq(other.poll(handle).status, "error",
    "another mod cannot poll a handle it does not own")
  T.eq(other.cancel(handle), false,
    "another mod cannot cancel a handle it does not own")
end

-- ------------------------------------------------------------- unload
local loader = run.loader
Job.releaseAll(loader, "job_worker_mod")
T.eq(loader.jobs and loader.jobs.job_worker_mod, nil,
  "unloading a mod drops every job it still held")
run.release()

-- --------------------------------------------- without the permission
local probe = T.sdk.loadMods({ "mods/job_probe" },
  { fs = T.sdk.memfs(UNPERMISSIONED) })
T.eq(#probe.errors, 0,
  "the unpermissioned mod loads clean (" .. tostring(probe.errors[1]) .. ")")
local out = probe.loader.exports.job_probe
T.eq(out.available, false, "available() is quietly false without the permission")
T.check(out.refused and out.refused:find('"background" permission', 1, true),
  "run() without the permission names it")
probe.release()

T.finish("mod_job")
