-- mod.postLog: one-way log reporting to the manifest-declared log_url.
-- The things this pins are the strict ones -- https-only destination that
-- lives in the manifest (not per-call), a closed list of format switches,
-- a body ceiling, opaque per-mod handles, and refusal without the network
-- permission.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Net = require("src.mods.Net")
local Fetch = require("src.net.Fetch")

-- Stand in for the worker pool: jobs resolve when the test says so, so no
-- test here touches a socket.
local submitted, nextId, states = {}, 0, {}
Fetch.post = function(url, body, opts)
  nextId = nextId + 1
  submitted[nextId] = { url = url, body = body, opts = opts }
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

local LOGGER = {
  ["mods/log_sender/manifest.json"] = [[{
    "id": "log_sender",
    "name": "Log Sender",
    "version": "1.0.0",
    "entry": "main.lua",
    "api": 2,
    "permissions": ["network"],
    "log_url": "https://logs.example.com/logs"
  }]],
  ["mods/log_sender/main.lua"] = [[
    local mod = ...
    mod.exports.send = function(body, opts)
      local handle, err = mod:postLog(body, opts)
      if not handle then return nil, err end
      return handle
    end
    mod.exports.poll = function(h) return mod.fetch:poll(h) end
    mod.exports.release = function(h) return mod.fetch:release(h) end
  ]],
}

local function manifest(id, extra)
  return ('{"id": "%s", "name": "T", "version": "1.0.0", "entry": "main.lua", '
    .. '"api": 2%s}'):format(id, extra or "")
end

local NO_URL = {
  ["mods/log_no_url/manifest.json"] = manifest("log_no_url", ', "permissions": ["network"]'),
  ["mods/log_no_url/main.lua"] = [[
    local mod = ...
    mod.exports.try = function()
      local ok, err = pcall(function() return mod:postLog("body") end)
      return ok, err
    end
  ]],
}

-- ------------------------------------------------ the closed opts list
local run = T.sdk.loadMods({ "mods/log_sender" }, { fs = T.sdk.memfs(LOGGER) })
T.eq(#run.errors, 0, "the logger mod loads clean (" .. tostring(run.errors[1]) .. ")")
local api = run.loader.exports.log_sender

local bad, badErr = api.send("body", { format = "xml" })
T.eq(bad, nil, "an unknown format is refused")
T.check(badErr and badErr:find("text and json only", 1, true), "and names the allowed ones")

local badKey, keyErr = api.send("body", { envelope = true })
T.eq(badKey, nil, "an unknown opt key is refused")
T.check(keyErr and keyErr:find("format is the only switch", 1, true), "and says so")

-- ------------------------------------------------ body validation
local empty, emptyErr = api.send("")
T.eq(empty, nil, "an empty body is refused")
local big = string.rep("x", Net.MAX_BODY + 1)
local bigH, bigErr = api.send(big)
T.eq(bigH, nil, "an oversized body is refused")
T.check(bigErr and bigErr:find("limit", 1, true), "and names the limit")

-- ------------------------------------------------- text format (default)
local handle, err = api.send("hello log")
T.check(handle ~= nil, "a plain text post returns a handle (" .. tostring(err) .. ")")
T.eq(type(handle), "table", "the handle is opaque, not the engine's job id")
T.eq(api.poll(handle).status, "pending", "a fresh post polls as pending")

local sent
for _, job in pairs(submitted) do
  if job.url == "https://logs.example.com/logs" and job.body == "hello log" then sent = job end
end
T.check(sent ~= nil, "the post reached the pool with the manifest URL")
T.eq(sent.opts.contentType, "text/plain", "plain text posts as text/plain")
T.check(sent.opts.userAgent:find("log_sender", 1, true),
  "the request identifies the calling mod")

-- -------------------------------------------------- json format
local jh, jerr = api.send("line one", { format = "json" })
T.check(jh ~= nil, "a json post returns a handle (" .. tostring(jerr) .. ")")
local jsent
for _, job in pairs(submitted) do
  if job.opts.contentType == "application/json" then jsent = job end
end
T.check(jsent ~= nil, "json posts as application/json")
local decoded = require("src.link.Json").decode(jsent.body)
T.eq(type(decoded), "table", "the json body is a table")
T.eq(decoded.format, "json", "the envelope names its format")
T.eq(decoded.mod, "log_sender", "the envelope names the mod")
T.eq(decoded.body, "line one", "the payload survives the envelope")

-- completion flows through poll, like get
states[1] = { status = "ok", progress = 1 }
local got = api.poll(handle)
T.eq(got.status, "ok", "a completed post polls ok")

api.release(handle)
run.release()

-- --------------------------------------- manifest without log_url refuses
local nurl = T.sdk.loadMods({ "mods/log_no_url" }, { fs = T.sdk.memfs(NO_URL) })
T.eq(#nurl.errors, 0, "no log_url loads clean (" .. tostring(nurl.errors[1]) .. ")")
local okCall, callErr = nurl.loader.exports.log_no_url.try()
T.check(not okCall and callErr:find("log_url", 1, true),
  "postLog without log_url names the missing manifest field")
nurl.release()

-- ------------------------------------------- manifest validation: the gate
-- log_url without the network permission is a load violation in a strict
-- manifest: the mod declares a network capability it did not opt in to.  The
-- violation fires inside manifest validation, so the mod never enters
-- loader.mods at all.
local badManifest = T.sdk.loadMods({ "mods/log_bad" }, { fs = T.sdk.memfs({
  ["mods/log_bad/manifest.json"] = manifest("log_bad",
    ', "log_url": "https://logs.example.com/logs"'),
  ["mods/log_bad/main.lua"] = "local mod = ...",
}) })
T.eq(badManifest.mods.log_bad, nil,
  "log_url without network: the mod is refused before load")

-- a non-https log_url is refused even with the permission
local httpManifest = T.sdk.loadMods({ "mods/log_http" }, { fs = T.sdk.memfs({
  ["mods/log_http/manifest.json"] = manifest("log_http",
    ', "permissions": ["network"], "log_url": "http://logs.example.com/logs"'),
  ["mods/log_http/main.lua"] = "local mod = ...",
}) })
T.eq(httpManifest.mods.log_http, nil,
  "an http log_url: the mod is refused before load")

-- an api 1 manifest carries no strict surface: log_url is ignored, and the
-- mod loads (its postLog call still refuses -- there is no log_url to use)
local api1 = T.sdk.loadMods({ "mods/log_api1" }, { fs = T.sdk.memfs({
  ["mods/log_api1/manifest.json"] = [[{
    "id": "log_api1", "name": "T", "version": "1.0.0", "entry": "main.lua",
    "api": 1, "log_url": "https://logs.example.com/logs"
  }]],
  ["mods/log_api1/main.lua"] = "local mod = ...",
}) })
T.eq(#api1.errors, 0, "an api 1 manifest ignores log_url ("
  .. tostring(api1.errors[1]) .. ")")
T.check(api1.loader.mods.log_api1 ~= nil, "and the mod loads")

T.finish("mod_postlog")
