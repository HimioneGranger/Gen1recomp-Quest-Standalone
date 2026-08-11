-- Gen 2 script ordering: sdefer and reanchormap.
--
-- Both are pure ordering, which is why nothing caught them: the flags and the
-- geometry a scene script writes land identically either way.  What changes is
-- WHEN the deferred body runs -- inside the scene script, under the map's
-- fade-in, or after it as the pass's own player event.
--   luajit tests/gen2_script_order_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 script order")
local check, eq = S.check, S.eq

love = require("tests.love_stub")

local Events = require("src.world.gen2.Events")
local Vm = require("src.script.gen2.Vm")

-- ------------------------------------------------------------------- sdefer
--
-- RunSceneScript (engine/overworld/events.asm:388) clears RUN_DEFERRED_SCRIPT,
-- runs the scene body through ScriptEvents to its `end`, and only THEN
-- CallScript's whatever `sdefer` recorded.  The five League walk-ins, the Hall
-- of Fame induction, the Cerulean grunt and the Mt Moon rival cutscene are all
-- written `sdefer <body> / end`.
local function order(scripts)
  local seen = {}
  local vm = Vm.new(scripts, {}, Events.new(), {
    showText = function(body, onDone)
      seen[#seen + 1] = body
      onDone()
    end,
  })
  return vm, seen
end

do
  local vm, seen = order({
    generation = 2,
    ["scene"] = {
      { op = "sdefer", script = "deferred" },
      { op = "rawtext", text = "scene tail" },
      { op = "end" },
    },
    ["deferred"] = {
      { op = "rawtext", text = "deferred body" },
      { op = "end" },
    },
  })
  vm:start("scene")
  eq(#seen, 2, "both bodies ran")
  eq(seen[1], "scene tail", "the scene body runs first, all of it")
  eq(seen[2], "deferred body", "and the deferred script only after its `end`")
  check(not vm:running(), "and the pair leave nothing running")
end

-- The shape the cache actually carries: `sdefer <script> / end` on its own.
do
  local vm, seen = order({
    generation = 2,
    ["WILLS_ROOM:scene0"] = {
      { op = "sdefer", script = "WILLS_ROOM:walkin" },
      { op = "end" },
    },
    ["WILLS_ROOM:walkin"] = {
      { op = "rawtext", text = "door locks" },
      { op = "end" },
    },
  })
  vm:start("WILLS_ROOM:scene0")
  eq(seen[1], "door locks", "a bare sdefer still reaches its body")
  eq(#seen, 1, "exactly once")
end

-- scall is NOT sdefer: it runs where it stands and comes back.
do
  local vm, seen = order({
    generation = 2,
    ["caller"] = {
      { op = "scall", script = "sub" },
      { op = "rawtext", text = "after the call" },
      { op = "end" },
    },
    ["sub"] = {
      { op = "rawtext", text = "inside the call" },
      { op = "end" },
    },
  })
  vm:start("caller")
  eq(seen[1], "inside the call", "scall runs inline")
  eq(seen[2], "after the call", "and returns to the command after it")
end

-- A whiteout unwinds the script rather than ending it, so there is nothing
-- left to defer to.
do
  local vm, seen = order({
    generation = 2,
    ["scene"] = {
      { op = "sdefer", script = "deferred" },
      { op = "end" },
    },
    ["deferred"] = {
      { op = "rawtext", text = "should not run" },
      { op = "end" },
    },
  })
  vm.aborted = false
  local realRun = vm.runDeferred
  vm.runDeferred = function(self)
    self.aborted = true
    return realRun(self)
  end
  vm:start("scene")
  eq(#seen, 0, "an aborted run drops the deferred script")
end

-- Nesting: a deferred script that defers again.
do
  local vm, seen = order({
    generation = 2,
    ["scene"] = {
      { op = "sdefer", script = "first" },
      { op = "end" },
    },
    ["first"] = {
      { op = "sdefer", script = "second" },
      { op = "rawtext", text = "first body" },
      { op = "end" },
    },
    ["second"] = {
      { op = "rawtext", text = "second body" },
      { op = "end" },
    },
  })
  vm:start("scene")
  eq(seen[1], "first body", "the first deferred body runs whole")
  eq(seen[2], "second body", "then the one it deferred")
end

-- -------------------------------------------------------------- reanchormap
--
-- Script_reanchormap calls ReanchorMap (home/window.asm), which is
-- ClearWindowData plus a BG re-blit.  ElmsLab reanchors before every `pokepic`
-- and WillsRoom between the walk-in and the earthquake, so a window still
-- standing when it runs is one the cart has already taken down.
do
  local hidden = 0
  local vm = Vm.new({
    generation = 2,
    ["s"] = {
      { op = "pokepic", species = 155 },
      { op = "reanchormap", args = { 0x85 } },
      { op = "end" },
    },
  }, {}, Events.new(), {
    showPic = function() end,
    hidePic = function() hidden = hidden + 1 end,
  })
  vm:start("s")
  eq(hidden, 1, "reanchormap takes the open pokepic window down")
end

do
  -- ...and it is still safe with no window hook at all.
  local vm = Vm.new({
    generation = 2,
    ["s"] = { { op = "reanchormap", args = { 0x85 } }, { op = "end" } },
  }, {}, Events.new(), {})
  vm:start("s")
  check(not vm:running(), "and a run with no hooks still finishes")
end

S.finish()
