-- ROM-free contract for the optional WIDE extended battle HUD.
--   luajit tests/engine/extended_battle_hud_contract.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local BattleState = require("src.battle.BattleState")
local Game = require("src.core.Game")
local OptionsMenu = require("src.ui.OptionsMenu")
local Renderer = require("src.render.Renderer")
local SaveData = require("src.core.SaveData")

local function battle(options)
  return setmetatable({ game = { save = { options = options } } },
    { __index = BattleState })
end

T.eq(SaveData.defaultOptions().battleHud, "standard",
  "the extended HUD is opt-in")
T.check(not battle({}):extendedHUD(), "an old save keeps the standard HUD")
T.check(not battle({ battleLayout = "og", battleFit = "fixed",
  battleHud = "extended", battleBg = "white" }):extendedHUD(),
  "the extended HUD cannot activate on the OG layout")
T.check(not battle({ battleLayout = "wide", battleFit = "fixed",
  battleHud = "standard", battleBg = "white" }):extendedHUD(),
  "STANDARD keeps every WIDE element on the native canvas")

for _, bg in ipairs({ "white", "black", "world" }) do
  T.check(battle({ battleLayout = "wide", battleFit = "fixed",
    battleHud = "extended", battleBg = bg }):extendedHUD(),
    "FIXED EXTENDED supports " .. bg)
end
local fillWhite = battle({ battleLayout = "wide", battleFit = "fill",
  battleHud = "extended", battleBg = "white" })
T.check(fillWhite:extendedHUD(), "FILL EXTENDED supports the adaptive WHITE mode")
T.check(not battle({ battleLayout = "wide", battleFit = "fill",
  battleHud = "extended", battleBg = "world" }):extendedHUD(),
  "FILL WORLD falls back to the standard HUD")

local world = battle({ battleLayout = "wide", battleFit = "fixed",
  battleHud = "extended", battleBg = "world" })
T.check(world:extendedWorldHUD(), "the fixed WORLD presentation is identified")
T.eq(Game.worldBgBattleDim({ states = { {}, world, {} } }), 0,
  "extended WORLD keeps its stack hold without a dim veil")
T.check(Game.extendedWorldHUDInStack({ states = { {}, world, {} } }),
  "the renderer band scan sees WORLD under an overlay")
T.check(not Game.extendedWorldHUDInStack(nil), "the renderer band scan is nil-safe")
local black = battle({ battleLayout = "wide", battleFit = "fixed",
  battleHud = "extended", battleBg = "black" })
T.check(black:extendedBlackHUD(), "the fixed BLACK presentation is identified")
T.check(Game.uiCanvasTransparent(false, true, world),
  "a world-backed extended overlay keeps the WIDE margins transparent")
T.check(not Game.uiCanvasTransparent(false, false, black),
  "an opaque BLACK battle keeps its UI canvas opaque")
T.check(Game.uiCanvasTransparent(true, false, nil),
  "the existing overworld transparency rule is unchanged")

local options = SaveData.defaultOptions()
local game = { save = { options = options }, data = { audio = {} } }
local menu = OptionsMenu.new(game)
local rows = {}
for _, row in ipairs(menu.rows) do rows[row.id] = row end
T.check(rows.battleHud ~= nil, "the in-game options menu exposes BATTLE HUD")
rows.battleLayout.step(game)
T.eq(options.battleLayout, "wide", "BATTLE LAYOUT can enable WIDE")
T.check(rows.battleHud.step(game), "WIDE can enable EXTENDED")
T.eq(options.battleHud, "extended", "the HUD option stores EXTENDED")
options.battleFit, options.battleBg, options.battleHud =
  "fill", "world", "standard"
T.check(rows.battleHud.step(game), "FILL can enable its approved EXTENDED mode")
T.eq(options.battleBg, "white", "FILL EXTENDED normalizes its background")
T.eq(rows.battleBg.value(game), "AUTO", "the normalized background reads AUTO")
T.check(not rows.battleBg.step(game, 1), "AUTO locks the background row")
rows.battleLayout.step(game)
T.eq(options.battleHud, "standard", "switching to OG normalizes the HUD")
T.check(not rows.battleHud.step(game), "OG refuses the extended HUD")

local oldAnchors, oldBattleCanvas = Renderer.uiAnchors, Renderer.battleHUDCanvas
local oldCanvas = Renderer.canvas
local oldCentered, oldHold = Renderer.uiCentered, Renderer.uiAnchorHold
local battleCanvas, uiCanvas = {}, {}
Renderer.uiAnchors, Renderer.battleHUDCanvas = nil, battleCanvas
Renderer:setBattleUIAnchor(1, 2, 3, 4, "top")
local anchor = Renderer.uiAnchors and Renderer.uiAnchors[1]
T.check(anchor and anchor.windowClamped and not anchor.extract,
  "battle anchors clamp to the window without cutting the scene canvas")
T.eq(anchor and anchor.canvas, battleCanvas,
  "battle anchors draw from the detached HUD canvas")
Renderer.uiAnchors, Renderer.canvas = nil, uiCanvas
Renderer.uiCentered, Renderer.uiAnchorHold = false, false
Renderer:setUIAnchor(1, 2, 3, 4, "bottom")
anchor = Renderer.uiAnchors and Renderer.uiAnchors[1]
T.check(anchor and anchor.extract and not anchor.windowClamped,
  "ordinary UI anchors keep their existing extraction behavior")
Renderer.uiAnchors, Renderer.battleHUDCanvas = oldAnchors, oldBattleCanvas
Renderer.canvas = oldCanvas
Renderer.uiCentered, Renderer.uiAnchorHold = oldCentered, oldHold

T.finish("extended battle HUD contract")
