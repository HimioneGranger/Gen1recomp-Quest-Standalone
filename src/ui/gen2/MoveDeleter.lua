-- The Blackthorn move deleter's move list (engine/events/move_deleter.asm
-- ChooseMoveToDelete, engine/pokemon/mon_menu.asm).  ChooseMoveToDelete shares
-- SetUpMoveScreenBG / SetUpMoveList with the summary screen's move page
-- (src/ui/gen2/SummaryMenu.lua moveDetailPlacements), so the four-slot list
-- geometry is the same box: names at (2, 3 + 2*slot), PP at
-- (10/13/15/16, nameY + 1).  What ChooseMoveToDelete does NOT share is the
-- type/power/accuracy plaque under it -- DeleteMoveScreen2DMenuData is a bare
-- `db 3, 1` / `dn 2, 0` menu (3 rows, cursor offset column 2), so only the
-- move list itself is drawn here.
--
-- The special that opens this (src/script/gen2/Specials.lua H.MoveDeletion)
-- has already run the "which move should it forget" line and refused a mon
-- with only one move before this screen is ever pushed, so this only has to
-- answer a row.

local Chrome = require("src.ui.gen2.Chrome")
local Sound = require("src.core.Sound")

local MoveDeleter = {}
MoveDeleter.__index = MoveDeleter
MoveDeleter.isOpaque = false

function MoveDeleter:wantsFillScale() return true end

-- opts: mon (the party mon whose moves are listed), moves (data.moves),
--       onChoose(index) -- 1-based move slot, onCancel()
function MoveDeleter.new(game, opts)
  opts = opts or {}
  local self = setmetatable({}, MoveDeleter)
  self.game = game
  local data = (game and game.data) or {}
  self.mon = opts.mon
  self.moves = opts.moves or data.moves
  self.onChoose = opts.onChoose
  self.onCancel = opts.onCancel
  self.list = (self.mon and self.mon.moves) or {}
  self.row = 1
  return self
end

function MoveDeleter:moveName(entry)
  if not entry then return "-" end
  local def = self.moves and self.moves[entry.id]
  return (def and def.name) or entry.id
end

function MoveDeleter:playSfx(name)
  local data = self.game and self.game.data
  local sfx = data and data.audio and data.audio.sfx
  if sfx and sfx[Sound.resolve(data, name)] then
    Sound.play(data, name)
  end
end

function MoveDeleter:finish(index)
  if self.done then return end
  self.done = true
  if index then
    if self.onChoose then self.onChoose(index) end
  elseif self.onCancel then
    self.onCancel()
  end
end

-- ScrollingMenuJoypad, no wrap: DeleteMoveScreen2DMenuData sets no
-- _2DMENU_WRAP bit, so the cursor stops at the ends the way every other
-- unwrapped 2D menu in Gold does.
function MoveDeleter:update(_dt)
  if self.done then return end
  local input = self.game and self.game.input
  if not input then return end
  local n = #self.list
  if n == 0 then
    if input:wasPressed("a") or input:wasPressed("b") then self:finish(nil) end
    return
  end
  if input:wasPressed("up") and self.row > 1 then
    self.row = self.row - 1
  elseif input:wasPressed("down") and self.row < n then
    self.row = self.row + 1
  elseif input:wasPressed("a") then
    self:playSfx("Sfx_ReadText2")
    self:finish(self.row)
  elseif input:wasPressed("b") then
    self:playSfx("Sfx_ReadText2")
    self:finish(nil)
  end
end

function MoveDeleter:draw()
  Chrome.textbox(0, 1, 18, 9)
  for slot = 1, 4 do
    local nameY = 3 + (slot - 1) * 2
    local ppY = nameY + 1
    local entry = self.list[slot]
    if entry then
      Chrome.print(self:moveName(entry), 2, nameY)
      Chrome.print("PP", 10, ppY)
      Chrome.print(Chrome.number(entry.pp, 2, true), 13, ppY)
      Chrome.print("/", 15, ppY)
      Chrome.print(Chrome.number(entry.maxPp or entry.pp, 2, true), 16, ppY)
    else
      Chrome.print("-", 2, nameY)
      Chrome.print("--", 10, ppY)
    end
  end
  if self.row >= 1 and self.row <= #self.list then
    Chrome.cursor(1, 3 + (self.row - 1) * 2)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return MoveDeleter
