-- ROM-free containment contract for link transport and state-update failures.
--   luajit tests/engine/link_game_containment.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

love = require("tests.love_stub")

local T = require("tests.modkit")
local Game = require("src.core.Game")

local function stackWith(overworld, update)
  local stack = { states = { overworld, { id = "link" }, { id = "overlay" } } }
  function stack:top() return self.states[#self.states] end
  function stack:pop() return table.remove(self.states) end
  function stack:push(state) self.states[#self.states + 1] = state end
  stack.update = update or function() end
  return stack
end

local function input()
  return { step = function() end }
end

do
  local overworld = { id = "overworld" }
  local closed = 0
  local game = setmetatable({
    overworld = overworld,
    stack = stackWith(overworld),
    linkSession = {},
    linkNet = { close = function() closed = closed + 1 end },
    save = { player = {}, playTime = 0 },
    data = { text = {} },
  }, { __index = Game })
  game:breakLink("fixture")
  T.eq(game.linkSession, nil, "breakLink clears the session")
  T.eq(game.linkNet, nil, "breakLink clears the transport")
  T.eq(closed, 1, "breakLink closes the transport once")
  T.eq(game.stack.states[1], overworld, "breakLink preserves the overworld")
  T.check(game.stack.states[2] == nil or game.stack.states[2].id ~= "link",
    "breakLink removes the link state")
end

do
  local overworld = { id = "overworld" }
  local updates, closed = 0, 0
  local stack = stackWith(overworld, function() updates = updates + 1 end)
  local game = setmetatable({
    overworld = overworld,
    stack = stack,
    input = input(),
    linkNet = {
      closed = false,
      update = function() error("transport boom") end,
      close = function() closed = closed + 1 end,
    },
    save = { player = {}, playTime = 0 },
    data = { text = {} },
  }, { __index = Game })
  T.check(pcall(game.step, game, 1 / 60),
    "a transport throw is contained")
  T.eq(updates, 0, "a failed transport does not advance the link state")
  T.eq(closed, 1, "a failed transport is closed")
  T.eq(game.save.playTime, 0, "a failed link step does not advance play time")
end

do
  local overworld = { id = "overworld" }
  local game = setmetatable({
    overworld = overworld,
    stack = stackWith(overworld, function() error("state boom") end),
    input = input(),
    linkSession = {},
    save = { player = {}, playTime = 0 },
    data = { text = {} },
  }, { __index = Game })
  T.check(pcall(game.step, game, 1 / 60),
    "a linked state throw is contained")
  T.eq(game.linkSession, nil, "a linked state throw clears the session")
end

do
  local overworld = { id = "overworld" }
  local game = setmetatable({
    overworld = overworld,
    stack = stackWith(overworld, function() error("ordinary engine bug") end),
    input = input(),
    save = { player = {}, playTime = 0 },
  }, { __index = Game })
  T.check(not pcall(game.step, game, 1 / 60),
    "outside link play, engine errors still fail loudly")
end

T.finish("link game containment")
