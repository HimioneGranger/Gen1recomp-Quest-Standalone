-- Screen id -> factory resolution.  The screens registry (Data.screens)
-- wins; engine screens are the require fallback, so a mod-free boot
-- resolves every id to the exact module it required before.  One cache,
-- dropped with the rest of the asset caches on dev-mode hot reload.

local Assets = require("src.render.Assets")
local Logger = require("src.core.Logger")

local Screens = {}

-- ids whose builtin module is not under src/ui/
local BUILTIN = {
  ManagerState = "src.mods.ManagerState",
}

-- The Gen 2 (Gold) screens, which live under src/ui/gen2/.  Half of them share
-- a module name with a Gen 1 screen (PartyMenu, StartMenu, TitleState,
-- OakSpeech, NamingScreen, PokedexMenu, OptionsMenu, TrainerCard, BoxMenu,
-- SummaryMenu, BattleState, SlotMachine, Credits, HallOfFame), so the ids
-- carry a "Gen2" prefix: one registry serves both generations, and a mod that
-- replaces Gold's party menu must not also replace Red's.  The prefix is the
-- same namespace the Gold data tables use for the same collision
-- (data.gen2Palettes, data.gen2Icons).
--
-- Everything listed is a stack state: `new(game, opts)`, pushed and popped.
-- The drawing helpers sitting next to them in src/ui/gen2/ (Chrome, TileSheet,
-- PackGfx, SpriteAnims, BattleAnimView, BattleHud) are not screens and get no
-- id -- a mod reskins those through the asset search path, not through here.
--
-- Gen2HallOfFame is the screen; the roster behind it is src/core/gen2/
-- HallOfFame.lua, which is a model and gets no id either.
--
-- The Game Corner's three PRIZE COUNTERS get no id for the same reason: on the
-- cart they are map script and nothing else (GoldenrodGameCornerTMVendorScript
-- and its Celadon twins are `loadmenu` / `verticalmenu` / `checkcoins` /
-- `giveitem` / `givepoke` / `takecoins`, all of which src/script/gen2/Vm.lua
-- runs), so a prize counter is reached by talking to the vendor and never by
-- pushing a screen.  The slot machine and card flip next door ARE engine
-- screens and do have ids.
local GEN2 = {
  "BankOfMom",
  "BattleState", "BattleTransition", "BoxMenu", "CardFlip",
  -- The Pokecenter PC's whose-PC top menu and the player's item PC behind it;
  -- Gen2PcMenu below is the storage system both BILL's PC rows open.
  "CenterPcMenu",
  "ContestMenu",
  "CopyrightSplash", "Credits", "DayCareMenu", "DecorationMenu", "Diploma",
  "EggHatchAnim", "ElevatorMenu", "EvolutionAnim",
  "GameFreakPresents", "GoldSilverIntro", "HallOfFame", "HeldItemMenu",
  -- Gen2InitClock is both timeset.asm screens: the new-game hour/minute pair
  -- OakSpeech opens with, and Mom's day-of-week wheel.
  "InitClock",
  "ItemPcMenu",
  "MagnetTrainRide",
  -- MAIL, four screens: the compose keyboard, the full-page reader, the
  -- READ/TAKE/QUIT row the party submenu opens, and the PC's MAILBOX.
  "MailCompose", "MailMenu", "MailRead", "MailboxMenu",
  -- Gen2MapRadio is the in-house wall radio (`special MapRadio`), not a card.
  "MapRadio",
  "MainMenu", "MartMenu", "MoveDeleter", "NamePick", "NamingScreen", "OakSpeech",
  "OptionsMenu", "PackMenu", "PartyMenu", "PcMenu", "PhotoStudio", "PokedexMenu",
  "Pokegear", "SaveMenu", "ScriptMenu", "SlotMachine",
  "StartMenu", "SummaryMenu", "TitleState", "TradeAnim", "TradeMenu",
  "TrainerCard",
  -- Gen2UnownPrinter is the ALPH RUINS STAMP viewer, not the print itself.
  "UnownPrinter", "UnownPuzzle",
}

-- The full ids, in the same order, for tests and for the mod docs.
Screens.GEN2_IDS = {}
for _, name in ipairs(GEN2) do
  local id = "Gen2" .. name
  BUILTIN[id] = "src.ui.gen2." .. name
  Screens.GEN2_IDS[#Screens.GEN2_IDS + 1] = id
end

local cache = {}

local function builtinFor(id)
  return require(BUILTIN[id] or ("src.ui." .. id))
end

local function resolve(game, id)
  local hit = cache[id]
  if hit then return hit end
  local screens = game and game.data and game.data.screens
  local record = screens and screens[id]
  local factory
  if record then
    -- registry record: { new = fn } or a bare function (05-registry-system)
    factory = (type(record) == "function") and { new = record } or record
    factory.__modOwned = true
  else
    factory = builtinFor(id)
  end
  cache[id] = factory
  return factory
end

function Screens.get(game, id)
  return resolve(game, id)
end

-- Resolve and construct, without touching the stack.  Not every screen is
-- stacked the moment it is built: the Gen 1 battle queue defers its UI rows,
-- and Gold's mart holds a PACK instance for the whole sell flow
-- (src/ui/gen2/MartMenu.lua).  Those composers need the registry lookup, the
-- screenId stamp and the same degrade a push gets, so both paths share this.
local function build(game, id, ...)
  local factory = resolve(game, id)
  local inst
  if factory.__modOwned then
    -- a broken mod screen degrades to the builtin, never a dead end
    local ok, result = pcall(factory.new, game, ...)
    if ok and result then
      inst = result
    else
      Logger.error("mod screen '%s' failed: %s -- using builtin",
                   id, tostring(result))
      cache[id] = nil
      inst = builtinFor(id).new(game, ...)
    end
  else
    inst = factory.new(game, ...)
  end
  inst.screenId = inst.screenId or id
  return inst
end

function Screens.build(game, id, ...)
  return build(game, id, ...)
end

function Screens.push(game, id, ...)
  local inst = build(game, id, ...)
  game.stack:push(inst)
  return inst
end

function Screens.invalidate()
  cache = {}
end

Assets.register(Screens.invalidate)

return Screens
