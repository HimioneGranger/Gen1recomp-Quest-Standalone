-- ROM-free proof for the Gen 1 NPC cadence prerequisite. Ordinary NPCs take
-- 32 frames per cell; a scripted escort can opt into the player's 16 frames.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = require("tests.love_stub")
local NPC = require("src.world.NPC")

local function walking(stepFrames)
  return setmetatable({
    cellX = 0, cellY = 0, px = 0, py = 0,
    facing = "down", moving = true, progress = 0,
    targetX = 0, targetY = 1, stepFrames = stepFrames,
    stepFlip = false, frozen = true,
  }, { __index = NPC })
end

local ordinary = walking()
for _ = 1, 16 do ordinary:update({}, {}) end
T.check(ordinary.moving, "an ordinary NPC is only halfway after 16 frames")
T.eq(ordinary.py, 8, "the halfway point is eight pixels")
for _ = 1, 16 do ordinary:update({}, {}) end
T.check(not ordinary.moving, "an ordinary NPC completes at 32 frames")
T.eq(ordinary.cellY, 1, "the ordinary step lands on the target cell")

local escort = walking(16)
for _ = 1, 16 do escort:update({}, {}) end
T.check(not escort.moving, "a synchronized escort completes at 16 frames")
T.eq(escort.cellY, 1, "the synchronized escort lands on the target cell")

local phase = walking()
for _ = 1, 8 do phase:update({}, {}) end
T.eq(phase:walkPhase(), 1, "the walk pose uses the scaled cadence quarter")
for _ = 1, 16 do phase:update({}, {}) end
T.eq(phase:walkPhase(), 0, "the pose returns for the final cadence quarter")

T.finish("npc_walk_cadence")
