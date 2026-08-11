-- Explicit Quest framebuffer ownership: replacements and teardown release
-- immediately instead of waiting for Android's eventual GC/finalizer pass.
--   luajit tests/engine/quest_canvas_lifetime_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
local Lifetime = require("src.quest.dramaless.CanvasLifetime")

local function canvas(w, h)
  local c = { w = w, h = h, releases = 0 }
  function c:getWidth() return self.w end
  function c:getHeight() return self.h end
  function c:release() self.releases = self.releases + 1 end
  return c
end

local made = 0
local function factory(w, h)
  made = made + 1
  return canvas(w, h)
end

local first = canvas(320, 288)
local same, changed = Lifetime.resize(first, 320, 288, factory)
check(same == first and not changed, "matching canvas is reused")
eq(first.releases, 0, "reuse does not release the live target")
eq(made, 0, "reuse does not allocate")

local replacement
replacement, changed = Lifetime.resize(first, 608, 288, factory)
check(changed and replacement ~= first, "dimension change replaces canvas")
eq(first.releases, 1, "superseded canvas releases immediately")
eq(made, 1, "replacement allocates exactly once")

local cleared = Lifetime.release(replacement)
eq(cleared, nil, "release clears the owner's slot")
eq(replacement.releases, 1, "teardown releases the live canvas once")
eq(Lifetime.release(nil), nil, "nil teardown is harmless")

local failed, failedChanged, err = Lifetime.resize(
  canvas(1, 1), 2, 2, function() error("allocation refused") end)
eq(failed, nil, "failed resize never returns a released old target")
check(not failedChanged, "failed resize is not reported as a change")
check(tostring(err):find("allocation refused", 1, true) ~= nil,
  "failed resize preserves the allocation reason")

T.finish("Quest canvas lifetime")
