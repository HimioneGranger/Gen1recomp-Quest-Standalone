-- Gold's START menu (engine/menus/start_menu.asm StartMenu).
--
-- The box is right-aligned -- menu_coords 10, 0, SCREEN_WIDTH - 1,
-- SCREEN_HEIGHT - 1 -- and grows to fit however many entries are currently
-- unlocked.  #DEX and POKEGEAR only appear once the player owns them, so early
-- in the game the menu is short; the ASM builds wMenuItemsList each time it
-- opens for exactly that reason (.SetUpMenuItems).
--
-- With MENU ACCOUNT on, a second box at the bottom-left describes the
-- highlighted entry (.MenuDesc), which is why every item carries two lines of
-- description text here.
--
-- The cursor position is remembered between openings
-- (wBattleMenuCursorPosition), so reopening the menu lands where you left it.
--
-- The assembled list runs through the ui.start_menu.items hook before the menu
-- opens, exactly as the Gen 1 port's does (src/ui/StartMenu.lua), so mods
-- insert, drop or reorder rows without patching this file.  It is the SAME
-- hook name and the same (game, items) payload: Gold's POKEGEAR row is simply
-- one more entry in the list the hook receives.

local Chrome = require("src.ui.gen2.Chrome")
local Logger = require("src.core.Logger")
local Runtime = require("src.mods.Runtime")
local Sound = require("src.core.Sound")

local StartMenu = {}
StartMenu.__index = StartMenu
-- Not opaque: the overworld keeps drawing underneath, the way the real menu
-- slides a window over the map.
StartMenu.isOpaque = false

-- SFX_MENU on open, SFX_READ_TEXT_2 (the click) on select
-- (StartMenu_Show's `ld de, SFX_MENU / call PlaySFX` and .Select's
-- PlayClickSFX).  By LABEL, not index: the old numeric ids (2 and 3) landed
-- on whatever the sfx table had there -- the item-get jingle on every menu
-- open -- and a repointed table would drift again.

-- STARTMENUITEM_* in the order .SetUpMenuItems appends them.  `need` is the
-- save flag that unlocks the entry; nil means always shown.
--
-- Labels are the ASM's own strings, with the compression bytes expanded the
-- way the cart expands them at print time: "#DEX" is POKé + DEX (seven tiles),
-- while "<POKE>GEAR" is <PO><KE>GEAR -- the <PO> and <KE> glyphs ($70/$71) are
-- one tile each, so that row is six tiles wide, not eight.  That difference is
-- exactly what kept POKéGEAR hanging off the menu box's right edge.
local ITEMS = {
  {
    id = "pokedex", label = "POKéDEX", need = "pokedex",
    desc = { "POKéMON", "database" },
  },
  {
    id = "pokemon", label = "POKéMON", need = "party",
    desc = { "Party <PK><MN>", "status" },
  },
  {
    id = "pack", label = "PACK", need = "pack",
    desc = { "Contains", "items" },
  },
  {
    id = "pokegear", label = "<PO><KE>GEAR", need = "pokegear",
    desc = { "Trainer's", "key device" },
  },
  {
    -- The player's own name is the label (.StatusString is "<PLAYER>").
    id = "status", label = nil,
    desc = { "Your own", "status" },
  },
  {
    id = "save", label = "SAVE",
    desc = { "Save your", "progress" },
  },
  {
    id = "option", label = "OPTION",
    desc = { "Change", "settings" },
  },
  {
    -- The mod manager's discoverable home, exactly as the Gen 1 start menu
    -- carries it: the row only appears once at least one mod has been
    -- discovered, so a vanilla install's menu is the cart's.
    id = "mods", label = "MODS", need = "mods",
    desc = { "Installed", "add-ons" },
  },
  {
    -- The cart's EXIT just closed the menu (CloseStartMenu).  A window with a
    -- close button already covers that, so -- exactly as the Gen 1 port does
    -- (src/ui/StartMenu.lua) -- this row is QUIT and power-cycles back to the
    -- title after a confirmation that defaults to NO.
    id = "quit", label = "QUIT",
    desc = { "Return to", "the title" },
  },
}

-- The confirmation's yes/no box.  A bare YesNoBox lands at YesNoMenuHeader's
-- own menu_coords 10, 5, 15, 9, which is exactly where the start menu is, so
-- this uses the other position the cart already places one at:
-- SaveTheGame_yesorno's `lb bc, 0, 7`, a 6x5 box at (0,7) clear of the menu.
-- Labels sit at (2,8) and (2,10) -- border + 1, plus a column for
-- STATICMENU_CURSOR and no extra row because STATICMENU_NO_TOP_SPACING is set.
local YESNO_X, YESNO_Y, YESNO_W, YESNO_H = 0, 7, 6, 5

-- Persisted across openings, like wBattleMenuCursorPosition.
StartMenu.lastIndex = 1

-- ui.start_menu.items identity: an unhooked build hands its own list back.
local function sameItems(_, items) return items end

-- opts: save, onChoose(id), onClose(), unlocked (override table for tests)
function StartMenu.new(game, opts)
  opts = opts or {}
  local self = setmetatable({}, StartMenu)
  self.game = game
  self.save = opts.save or (game and game.save)
  self.onChoose = opts.onChoose
  self.onClose = opts.onClose
  self.unlocked = opts.unlocked
  local items = self:visibleItems()
  -- Unguarded, like the Gen 1 site: the menu is built once per opening, not
  -- per frame, so there is nothing here worth a wantsHook fast path.  A hook
  -- that answers with anything but a table is degraded to the vanilla list
  -- rather than emptying the player's menu.
  local hooked = Runtime.call("ui.start_menu.items", sameItems, game, items)
  if type(hooked) == "table" then
    items = hooked
  else
    Logger.error("ui.start_menu.items returned %s; keeping the vanilla items",
                 type(hooked))
  end
  self.items = items
  local options = (self.save and self.save.options) or {}
  self.showDescription = options.menuAccount ~= false

  self.list = Chrome.List.new({
    items = self.items,
    -- GetMenuTextStartCoord: the box's left/top plus one for the border, plus
    -- one more for the cursor column (STATICMENU_CURSOR) and one more for the
    -- top spacing this menu does not opt out of -- so (10,0) becomes (12,2),
    -- and Chrome.List puts the cursor at x - 1 = 11.
    x = 12, y = 2, spacing = 2,
    -- Two rows per entry inside an 18-row screen leaves room for eight, which
    -- is exactly the vanilla count.  A mod that adds a row scrolls rather than
    -- drawing off the bottom of the frame; Chrome.List puts the ▼ hint on.
    rows = math.min(#self.items, 8),
    wrap = true,
    startAccepts = true,
    index = math.min(StartMenu.lastIndex, math.max(1, #self.items)),
    onChoose = function(value, index) self:choose(value, index) end,
    onCancel = function() self:close() end,
  })
  return self
end

-- Which entries the player has unlocked.  Derived from the save so the menu
-- grows as the game does; `unlocked` overrides it wholesale for tests.
-- .SetUpMenuItems tests two ENGINE flag bits, and both arrive as `setflag`
-- ids in save.engineFlags (constants/engine_flags.asm const order, via
-- World:setEngineFlag): `bit STATUSFLAGS_POKEDEX_F, [wStatusFlags]` is
-- ENGINE_POKEDEX = 11, written by Oak at Mr. Pokemon's house, and
-- `bit POKEGEAR_OBTAINED_F, [wPokegearFlags]` is ENGINE_POKEGEAR = 4,
-- written by Mom on the way out the door.
local ENGINE_POKEGEAR, ENGINE_POKEDEX = 4, 11

function StartMenu:availability()
  if self.unlocked then return self.unlocked end
  local save = self.save or {}
  local inventory = save.inventory or {}
  local engine = save.engineFlags or {}
  local status = self.game and self.game.modStatus
  return {
    mods = status ~= nil and #(status.available or {}) > 0,
    -- ENGINE_POKEDEX first; pokedexReceived stays as the test/driver override.
    pokedex = engine[ENGINE_POKEDEX] == true or save.pokedexReceived == true,
    party = #(save.party or {}) > 0,
    -- The PACK exists from the start; the cart gates it on nothing.
    pack = true,
    pokegear = engine[ENGINE_POKEGEAR] == true
      or (inventory.POKEGEAR or 0) > 0 or save.pokegearReceived == true,
  }
end

function StartMenu:visibleItems()
  local available = self:availability()
  local playerName = (self.save and self.save.player and self.save.player.name)
    or "GOLD"
  local out = {}
  for _, item in ipairs(ITEMS) do
    if not item.need or available[item.need] then
      out[#out + 1] = {
        label = item.label or playerName,
        value = item.id,
        desc = item.desc,
      }
    end
  end
  return out
end

function StartMenu:playSfx(name)
  local data = self.game and self.game.data
  local audio = data and data.audio
  if not audio then return end
  if audio.sfx and audio.sfx[name] then Sound.play(data, name) end
end

function StartMenu:enter()
  self:playSfx("Sfx_Menu")
end

-- index comes from Chrome.List (src/ui/gen2/Chrome.lua:346) so a hook-injected
-- entry can be found by position: a mod's row carries an onSelect callback and
-- no `value`, the way the Gen 1 menu's rows do (src/ui/StartMenu.lua:30), and
-- without this arm it falls off the end of the id chain in Game2:switch.
function StartMenu:choose(id, index)
  StartMenu.lastIndex = self.list.index
  local item = index and self.items[index]
  if item and item.onSelect and item.value == nil then
    self:playSfx("Sfx_ReadText2")
    item.onSelect(self.game)
    return
  end
  self:playSfx("Sfx_ReadText2")
  if id == "quit" then
    -- Ask before throwing away everything since the last save.  NO is the
    -- default, the way the Gen 1 port's QUIT is.
    self.phase = "confirm"
    self.confirmChoice = 2
    return
  end
  if self.onChoose then self.onChoose(id) end
end

function StartMenu:confirmQuit()
  self.phase = nil
  if self.onQuit then
    self.onQuit()
  elseif self.game and self.game.returnToTitle then
    self.game:returnToTitle()
  end
end

function StartMenu:close()
  StartMenu.lastIndex = self.list.index
  if self.onClose then self.onClose() end
end

function StartMenu:update(_dt)
  local input = self.game and self.game.input
  if not input then return end
  if self.phase == "confirm" then
    if input:wasPressed("up") or input:wasPressed("down") then
      self.confirmChoice = self.confirmChoice == 1 and 2 or 1
    elseif input:wasPressed("a") then
      if self.confirmChoice == 1 then
        self:confirmQuit()
      else
        self.phase = nil
      end
    elseif input:wasPressed("b") or input:wasPressed("start") then
      self.phase = nil
    end
    return
  end
  -- START closes the menu as well as opening it.
  if input:wasPressed("start") then
    self:close()
    return
  end
  self.list:update(input)
end

function StartMenu:draw()
  -- AutomaticGetMenuBottomCoord: bottom = top + 2 * items + 1, so the box is
  -- two rows per entry plus its two border rows.  A menu that a mod has grown
  -- past the screen scrolls instead of overflowing (Chrome.List draws the ▼
  -- hint when there is more below).
  local height = math.min(#self.items * 2 + 2, Chrome.SCREEN_H)
  Chrome.box(10, 0, 10, height)
  self.list:draw()

  if self.phase == "confirm" then
    Chrome.textbox(0, 12, 18, 4)
    Chrome.print("Return to the", 1, 14)
    Chrome.print("title screen?", 1, 16)
    Chrome.box(YESNO_X, YESNO_Y, YESNO_W, YESNO_H)
    Chrome.print("YES", YESNO_X + 2, YESNO_Y + 1)
    Chrome.print("NO", YESNO_X + 2, YESNO_Y + 3)
    Chrome.cursor(YESNO_X + 1,
      YESNO_Y + (self.confirmChoice == 1 and 1 or 3))
    return
  end

  if not self.showDescription then return end
  local item = self.list:current()
  local desc = item and item.desc
  if not desc then return end
  -- ._DrawMenuAccount ClearBox (0,13) 5 rows by 10, .PrintMenuAccount decoord
  -- 0, 14 and the desc's `next` steps two rows (start_menu.asm:366-382).
  local G = love.graphics
  G.setColor(1, 1, 1, 1)
  G.rectangle("fill", 0, 13 * 8, 10 * 8, 5 * 8)
  Chrome.print(desc[1] or "", 0, 14)
  Chrome.print(desc[2] or "", 0, 16)
end

StartMenu.ITEMS = ITEMS

return StartMenu
