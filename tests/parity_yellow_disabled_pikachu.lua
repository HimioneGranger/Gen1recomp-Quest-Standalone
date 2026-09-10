package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local S = require("tests.harness").suite("parity Yellow disabled Pikachu")
local check, eq = S.check, S.eq
local Data = require("src.core.Data")
Data:load()
local GameVersion = require("src.core.GameVersion")
local Follower = require("src.world.PikachuFollower")
local ItemEffects = require("src.inventory.ItemEffects")
local PartyMenu = require("src.ui.PartyMenu")
local BoxMenu = require("src.ui.BoxMenu")
local TextBox = require("src.render.TextBox")

local oldVersion = GameVersion.get()
GameVersion.set("yellow")

local save = {
  player = { id = 7, name = "RED" },
  party = {
    { species = "PIKACHU", otId = 7, ot = "RED", hp = 20 },
    { species = "PIDGEY", otId = 7, ot = "RED", hp = 20 },
  },
}

check(Follower.isStarterPikachu(save, save.party[1]), "the player Pikachu is identified")
check(not Follower.isStarterPikachu(save, save.party[2]), "other party members are not starter Pikachu")

local pika = { pikachuFollower = true, cellX = 3, cellY = 4, facing = "down" }
local seel = { def = { name = "POKEMONFANCLUB_SEEL" }, cellX = 1, cellY = 4 }
local moves = {}
local ow = {
  map = { id = "POKEMON_FAN_CLUB" },
  player = { cellX = 3, cellY = 5, facing = "up" },
  npcs = { pika, seel },
  scriptMove = function(_, npc, dir, tiles, done)
    moves[#moves + 1] = { dir, tiles }
    npc.facing = dir
    if done then done() end
  end,
}

Follower.onFanClubEntered({ save = save, data = Data }, ow)
check(ow.pikachuFanClubScene, "Fan Club disables normal Pikachu following")
check(ow.pikachuMapScriptActive, "Fan Club sets the map-script flag")
eq(ow.player.facing, "down", "Fan Club resets the player direction")
eq(moves[1] and moves[1][1], "up", "Fan Club starts with slide-up displacement")
eq(moves[1] and moves[1][2], 1, "Fan Club slide-up spans one tile")
eq(moves[2] and moves[2][1], "right", "Fan Club then walks right")
eq(moves[2] and moves[2][2], 3, "Fan Club walks right three tiles")
eq(moves[3] and moves[3][1], "up", "Fan Club ends walking up")
eq(moves[3] and moves[3][2], 1, "Fan Club final up spans one tile")
eq(seel.movementStatus, 2, "Fan Club puts Seel into movement delay")
eq(seel.facing, "down", "Fan Club turns Seel down")
check(Follower.isFollowingDisabled(ow), "disabled Fan Club follower blocks starter selection")

local sleepOw = {
  map = { id = "PEWTER_POKECENTER" },
  player = { cellX = 3, cellY = 5 },
  npcs = { pika },
  pikachuPewterSleepScene = true,
}
local result = ItemEffects.use(Data, save, "POKE_FLUTE", nil, nil, nil, sleepOw)
eq(result, "flute_wake_pikachu", "Poké Flute is allowed next to sleeping Pikachu")
check(Follower.isFollowingDisabled(sleepOw), "sleeping Pikachu disables normal follower actions")

local pushed = {}
local partyGame = {
  save = save,
  overworld = sleepOw,
  stack = { push = function(_, state) pushed[#pushed + 1] = state end },
  input = { wasPressed = function(_, key) return key == "a" end },
}
PartyMenu.new(partyGame):update()
check(getmetatable(pushed[#pushed]) == TextBox,
  "sleeping Pikachu cannot be selected from the party menu")

local boxGame = {
  save = save,
  overworld = sleepOw,
  data = { pokemon = { PIKACHU = { name = "PIKACHU" }, PIDGEY = { name = "PIDGEY" } }, text = {} },
  stack = { push = function(_, state) pushed[#pushed + 1] = state end },
}
local pc = BoxMenu.new(boxGame)
pc.items[2].onSelect()
local depositList = pushed[#pushed]
depositList.onChoose(depositList.items[1], depositList)
check(getmetatable(pushed[#pushed]) == TextBox,
  "sleeping Pikachu cannot be deposited into Bill's PC")
eq(#save.party, 2, "PC refusal leaves the party unchanged")

GameVersion.set(oldVersion)
S.finish()
