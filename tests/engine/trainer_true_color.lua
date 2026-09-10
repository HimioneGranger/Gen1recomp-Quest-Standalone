-- Gen 1 trainers.trueColor: the same 4-shade opt-out used by pokemon and
-- sprites, now on trainer portraits. ROM-free.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local BattleState = require("src.battle.BattleState")
local Schemas = require("src.mods.Schemas")
local OakSpeech = require("src.ui.OakSpeech")

local spec = Schemas.REGISTRIES.trainers
T.check(spec.fields.trueColor ~= nil,
  "Gen 1 trainers schema lists trueColor")
T.check(Schemas.check(spec, "trainers", "OPP_BROCK",
                      { trueColor = true }, "patch"),
  "a trueColor patch validates")
T.check(not Schemas.check(spec, "trainers", "OPP_BROCK",
                          { trueColor = "yes" }, "patch"),
  "trueColor rejects a non-boolean")

T.eq(BattleState.trainerTrueColor(nil, nil), false,
  "no trainer is not trueColor")
T.eq(BattleState.trainerTrueColor(nil, { pic = "a.png" }), false,
  "a vanilla portrait is not trueColor")
T.eq(BattleState.trainerTrueColor(nil, { trueColor = true }), true,
  "the record's own flag wins")
T.eq(BattleState.trainerTrueColor(nil, { trueColor = false }), false,
  "explicit false stays false")

local data = {
  trainers = {
    BASE = { pic = "base.png", trueColor = true },
    VANILLA = { pic = "vanilla.png" },
  },
}
T.eq(BattleState.trainerTrueColor(data, { basePic = "BASE" }), true,
  "a basePic reuse inherits the base flag")
T.eq(BattleState.trainerTrueColor(data,
      { basePic = "BASE", trueColor = false }), false,
  "explicit false on the subclass beats the base")
T.eq(BattleState.trainerTrueColor(data, { basePic = "VANILLA" }), false,
  "reusing a vanilla base stays shaded")

local game = {
  data = { trainers = { OPP_BROCK = { pic = "brock.png", trueColor = true } } },
}
local _, _, oakTc = OakSpeech.resolvePic(game,
  { type = "trainer", id = "OPP_BROCK" })
T.eq(oakTc, true, "OakSpeech reports a trainer record's trueColor")

T.finish("trainer true color")
