-- #1208: the launcher's save-slot line read a Gold save with Gen 1 eyes
--   POKEPORT_GAME=gold POKEPORT_TOUCH=0 \
--     POKEPORT_DRIVER=tests/drivers/gold_bug1208_test.lua love .

local U = require("tests.drivers.util")
local SaveData = require("src.core.SaveData")
local GoldSave = require("src.core.gen2.Save")

return function(game)
  U.wait(45)
  local save = game.save
  assert(save and save.player, "gold save did not boot")

  save.player.badges = { ZEPHYR = true, HIVE = true, PLAIN = true, FOG = true,
    STORM = true, MINERAL = true, GLACIER = true, RISING = true }
  save.player.kantoBadges = { BOULDER = true, CASCADE = true }
  save.pokedex = save.pokedex or {}
  save.pokedex.caught = { [155] = true, [158] = true, [152] = true }

  local ok, err = game:writeSave()
  if not ok then
    U.log("FAIL gold writeSave:", tostring(err))
  else
    local want = GoldSave.summary(save)
    local active = SaveData.activeSlot("gold")
    local row
    for _, slot in ipairs(SaveData.listSlots("gold")) do
      if slot.id == active then row = slot end
    end
    if not (row and row.meta) then
      U.log("FAIL launcher has no slot row for", tostring(active))
    else
      U.log(("launcher: %d badges - %s - %d caught"):format(
        row.meta.badges, row.meta.timeText, row.meta.dexCount))
      U.log(("continue: %d badges - %d:%02d - %d caught"):format(
        want.badges, want.hours, want.minutes, want.caught))
      if row.meta.badges == want.badges and row.meta.dexCount == want.caught then
        U.log("PASS launcher summary matches CONTINUE for slot", tostring(active))
      else
        U.log("FAIL launcher summary disagrees with CONTINUE")
      end
    end
  end

  while true do
    coroutine.yield()
  end
end
