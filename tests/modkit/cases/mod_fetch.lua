-- mod.fetch: background HTTP for sandboxed mods, behind the "network"
-- permission.  The sandbox blocks love.thread because newThread's Lua state
-- escapes every rule in it; this is the replacement, so the things that make
-- it NOT an escape are what this file pins -- http/https only, handles that
-- are opaque and per-mod, a ceiling on jobs in flight, and release on unload.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Net = require("src.mods.Net")
local Fetch = require("src.net.Fetch")

-- Stand in for the worker pool: jobs resolve when the test says so, so no
-- test here touches a socket.
local submitted, nextId, states = {}, 0, {}
Fetch.get = function(url, opts)
  nextId = nextId + 1
  submitted[nextId] = { url = url, opts = opts }
  states[nextId] = { status = "pending", progress = 0 }
  return nextId
end
Fetch.poll = function(id) return states[id] or { status = "error", err = "unknown job" } end
Fetch.isPending = function(id) return (states[id] or {}).status == "pending" end
Fetch.release = function(id) states[id] = nil end
Fetch.cancel = function(id)
  if states[id] and states[id].status == "pending" then states[id].status = "cancelled" end
end
Fetch.available = function() return true end

local FETCHER = {
  ["mods/net_fetcher/manifest.json"] = [[{
    "id": "net_fetcher",
    "name": "Net Fetcher",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2,
    "permissions": ["network"]
  }]],
  ["mods/net_fetcher/main.lua"] = [[
    local mod = ...
    mod.exports.available = mod.fetch:available()
    mod.exports.get = function(url, opts) return mod.fetch:get(url, opts) end
    mod.exports.poll = function(h) return mod.fetch:poll(h) end
    mod.exports.release = function(h) return mod.fetch:release(h) end
    mod.exports.cancel = function(h) return mod.fetch:cancel(h) end
  ]],
}

local OTHER = {
  ["mods/net_other/manifest.json"] = [[{
    "id": "net_other",
    "name": "Net Other",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2,
    "permissions": ["network"]
  }]],
  ["mods/net_other/main.lua"] = [[
    local mod = ...
    mod.exports.poll = function(h) return mod.fetch:poll(h) end
    mod.exports.cancel = function(h) return mod.fetch:cancel(h) end
    mod.exports.get = function(url) return mod.fetch:get(url) end
  ]],
}

local UNPERMISSIONED = {
  ["mods/net_probe/manifest.json"] = [[{
    "id": "net_probe",
    "name": "Net Probe",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2
  }]],
  ["mods/net_probe/main.lua"] = [[
    local mod = ...
    mod.exports.available = mod.fetch:available()
    local ok, err = pcall(function() return mod.fetch:get("https://example.com") end)
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

-- ---------------------------------------------------- scheme restriction
-- curl also speaks file://, scp:// and ftp://.  Without this check mod.fetch
-- would be a filesystem read and the sandbox would be pointless.
T.eq(Net.urlDenial("https://example.com/i.json"), nil, "https is allowed")
T.eq(Net.urlDenial("http://example.com/i.json"), nil, "http is allowed")
T.check(Net.urlDenial("file:///etc/passwd"), "file:// is refused")
T.check(Net.urlDenial("FILE:///etc/passwd"), "file:// is refused case-insensitively")
T.check(Net.urlDenial("scp://host/secret"), "scp:// is refused")
T.check(Net.urlDenial("ftp://host/x"), "ftp:// is refused")
T.check(Net.urlDenial("/etc/passwd"), "a bare path is refused")
T.check(Net.urlDenial("https://"), "a url with no host is refused")
T.check(Net.urlDenial(nil), "a non-string url is refused")
T.check(Net.urlDenial("file:///x"):find("http", 1, true),
  "the refusal says what is allowed")

-- ------------------------------------------------------- permissioned use
local run = T.sdk.loadMods({ "mods/net_fetcher", "mods/net_other" },
  { fs = T.sdk.memfs(merged(FETCHER, OTHER)) })
T.eq(#run.errors, 0,
  "the permissioned mods load clean (" .. tostring(run.errors[1]) .. ")")
local api = run.loader.exports.net_fetcher
T.eq(api.available, true, "available() is true with the permission")

local handle, err = api.get("https://example.com/index.json")
T.check(handle ~= nil, "get() returns a handle (" .. tostring(err) .. ")")
T.eq(type(handle), "table", "the handle is opaque, not the engine's job id")
T.eq(api.poll(handle).status, "pending", "a fresh job polls as pending")

-- the mod is named to the server, and cannot pose as the launcher
local sent
for _, job in pairs(submitted) do
  if job.url == "https://example.com/index.json" then sent = job end
end
T.check(sent and sent.opts.userAgent:find("net_fetcher", 1, true),
  "the request identifies the calling mod")

-- a refused url never reaches the pool
local before = nextId
local bad, badErr = api.get("file:///etc/passwd")
T.eq(bad, nil, "a file:// url returns no handle")
T.check(badErr and badErr:find("http", 1, true), "and says why")
T.eq(nextId, before, "and never reaches the fetch pool")

-- the body arrives through poll, as a copy
states[sent and 1 or 1] = { status = "ok", body = "{\"mods\":[]}", progress = 1 }
local got = api.poll(handle)
T.eq(got.status, "ok", "a completed job polls ok")
T.eq(got.body, "{\"mods\":[]}", "and hands over the body")
got.body = "tampered"
T.eq(api.poll(handle).body, "{\"mods\":[]}",
  "poll returns a copy; a mod cannot edit the engine's job table")

-- --------------------------------------------- handles do not cross mods
-- Fetch keys jobs by integer and the launcher's own downloads live in the
-- same table, so this is the property that matters most.
local other = run.loader.exports.net_other
T.eq(other.poll(handle).status, "error",
  "another mod cannot poll a handle it does not own")
T.eq(other.cancel(handle), false,
  "another mod cannot cancel a handle it does not own")
T.eq(api.poll({}).status, "error", "a forged handle reads as an error")
T.eq(api.poll(1).status, "error", "a guessed integer id reads as an error")

-- ------------------------------------------------------ in-flight ceiling
-- One mod must not be able to fill the shared three-worker pool.
local held = {}
for i = 1, Net.MAX_INFLIGHT + 2 do
  held[i] = select(1, api.get("https://example.com/" .. i))
end
local live = 0
for _, h in ipairs(held) do if h then live = live + 1 end end
T.check(live <= Net.MAX_INFLIGHT,
  "a mod is capped at " .. Net.MAX_INFLIGHT .. " requests in flight")
local _, capErr = api.get("https://example.com/overflow")
T.check(capErr and capErr:find("in flight", 1, true),
  "the refusal explains the cap")
-- releasing frees a slot
api.release(held[1])
local after = api.get("https://example.com/after-release")
T.check(after ~= nil, "releasing a handle frees a slot")

-- the timeout is clamped, so a mod cannot pin a worker
for _, h in ipairs(held) do if h then api.release(h) end end
if after then api.release(after) end
local slow, slowErr = api.get("https://example.com/slow", { maxSeconds = 99999 })
T.check(slow ~= nil, "a slot is free again (" .. tostring(slowErr) .. ")")
local slowJob
for _, job in pairs(submitted) do
  if job.url == "https://example.com/slow" then slowJob = job end
end
T.check(slow and slowJob.opts.maxSeconds <= Net.MAX_SECONDS,
  "a caller's timeout is clamped to " .. Net.MAX_SECONDS .. "s")

-- ------------------------------------------------------ release on unload
local loader = run.loader
T.check(loader.netJobs and loader.netJobs.net_fetcher,
  "the loader tracks the mod's jobs")
Net.releaseAll(loader, "net_fetcher")
T.eq(loader.netJobs.net_fetcher, nil,
  "unloading a mod drops every job it still held")
run.release()

-- --------------------------------------------- without the permission
local probe = T.sdk.loadMods({ "mods/net_probe" },
  { fs = T.sdk.memfs(UNPERMISSIONED) })
T.eq(#probe.errors, 0,
  "the unpermissioned mod loads clean (" .. tostring(probe.errors[1]) .. ")")
local out = probe.loader.exports.net_probe
T.eq(out.available, false, "available() is quietly false without the permission")
T.check(out.refused and out.refused:find('"network" permission', 1, true),
  "get() without the permission names it")
probe.release()

T.finish("mod_fetch")
