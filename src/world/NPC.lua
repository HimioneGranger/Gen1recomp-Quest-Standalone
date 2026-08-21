-- Map object (NPC/item) built from a generated object_event entry.
-- STAY objects keep their facing; WALK objects wander randomly within the
-- roam constraint (ANY_DIR / UP_DOWN / LEFT_RIGHT), like the original.

local Collision = require("src.world.Collision")
local SpriteRenderer = require("src.render.SpriteRenderer")

local NPC = {}
NPC.__index = NPC

local STEP_FRAMES = 16

local FACING_FROM_RANGE = {
  DOWN = "down", UP = "up", LEFT = "left", RIGHT = "right",
}

local ROAM_DIRS = {
  ANY_DIR = { "up", "down", "left", "right" },
  UP_DOWN = { "up", "down" },
  LEFT_RIGHT = { "left", "right" },
}

function NPC.new(data, mapId, objDef)
  local self = setmetatable({}, NPC)
  self.def = objDef
  self.id = string.format("%s_obj_%d", mapId, objDef.index)
  local spriteDef = data.sprites[objDef.sprite]
  assert(spriteDef, "unknown sprite " .. tostring(objDef.sprite))
  self.sprite = SpriteRenderer.new(spriteDef, self.id)
  -- object_event coordinates are already walk-grid cells
  self.cellX, self.cellY = objDef.x, objDef.y
  self.px, self.py = self.cellX * 16, self.cellY * 16
  self.facing = FACING_FROM_RANGE[objDef.range] or "down"
  self.moving = false
  self.progress = 0
  self.stepFlip = false
  self.frozen = false -- scripts freeze NPCs while talking
  self.wanders = objDef.movement == "WALK"
  self.roamDirs = ROAM_DIRS[objDef.range] or ROAM_DIRS.ANY_DIR
  self.timer = love.math.random(30, 120)
  return self
end

function NPC:facePlayer(player)
  local dx = player.cellX - self.cellX
  local dy = player.cellY - self.cellY
  if math.abs(dx) > math.abs(dy) then
    self.facing = dx > 0 and "right" or "left"
  else
    self.facing = dy > 0 and "down" or "up"
  end
end

function NPC:update(map, entities)
  -- self.stepFrames overrides the shared 16-frame walk for an object whose
  -- step has to stay in phase with something else: Yellow's follower
  -- Pikachu takes the player's own step length, halved while it is more
  -- than a cell behind (FastPikachuFollow, engine/pikachu/
  -- pikachu_follow.asm).  self.hopStep is the same file's $5-$8 hop
  -- command: two cells of travel inside one step's frames
  -- (DoubleAddPikachuStepVectorToScreenPixelCoords), which is why the
  -- pixel span doubles while the frame count does not.  Nothing else sets
  -- either field, so every other object keeps the constant (#410, #409).
  local stepLen = self.stepFrames or STEP_FRAMES
  local span = self.hopStep and 2 or 1
  if self.moving then
    self.progress = self.progress + 1
    -- NPC_CHANGE_FACING: animate the walk cycle in place, no translation
    -- (movement.asm ChangeFacingDirection zeroes the delta); px/py stay
    -- pinned to the current cell while walkPhase() cycles.
    if self.marching then
      if self.progress >= stepLen then
        self.progress = 0
        self.moving = false
        self.marching = false
        self.stepFlip = not self.stepFlip
      end
      return
    end
    local d = Collision.DELTA[self.facing]
    -- 1px per frame at the default length; a shortened step scales instead,
    -- so the cell still lands on a 16px boundary (Player:update does the
    -- same for the bicycle)
    local moved = math.floor(self.progress * 16 * span / stepLen)
    self.px = self.cellX * 16 + d[1] * moved
    self.py = self.cellY * 16 + d[2] * moved
    if self.progress >= stepLen then
      self.cellX, self.cellY = self.targetX, self.targetY
      self.targetX, self.targetY = nil, nil
      self.px, self.py = self.cellX * 16, self.cellY * 16
      self.moving = false
      self.hopStep = nil
      self.stepFlip = not self.stepFlip
    end
    return
  end
  if self.frozen or not self.wanders then return end
  self.timer = self.timer - 1
  if self.timer > 0 then return end
  self.timer = love.math.random(30, 180)
  local dir = self.roamDirs[love.math.random(#self.roamDirs)]
  self.facing = dir
  if love.math.random() < 0.5 then return end -- sometimes just turn
  -- never wander onto warps, so NPCs don't walk out of the map
  local tx, ty = Collision.target(self.cellX, self.cellY, dir)
  if map:warpAtCell(tx, ty) then return end
  if Collision.canMove(map, entities, self, dir) then
    self.targetX, self.targetY = tx, ty
    self.moving = true
    self.progress = 0
  end
end

function NPC:walkPhase()
  if not self.moving then return 0 end
  local p = self.progress % 16
  return (p >= 4 and p < 12) and 1 or 0
end

-- Same contract as Player:pose -- the sheet, position, facing and step
-- phase this frame renders to -- so a render pipeline can pose an NPC
-- without caring which kind of entity it is.  An NPC never hops, so the
-- trailing hop flag is always false.
function NPC:pose()
  return self.sprite, self.px, self.py, self.facing,
         self:walkPhase(), self.stepFlip, false
end

function NPC:draw(camX, camY)
  local sprite, px, py, facing, phase, flip = self:pose()
  sprite:draw(px, py, camX, camY, facing, phase, flip, nil, nil,
              self.frameOverride)
end

return NPC
