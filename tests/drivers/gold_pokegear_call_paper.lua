-- Eyeball driver: the paper a textbox sits on while the Pokegear holds the
-- screen.  A call's text box is a plain src/render/TextBox.lua state pushed
-- OVER the gear, and the gear's own box (Pokegear:textbox) already lays the
-- card's cream paper down first, because every tile the box is built from is
-- font-page ($79-$7e frame, ' ' $7f interior) and TownMapPals hands every tile
-- id >= $60 to BG palette 0, whose colour 0 is `RGB 28, 31, 20`
-- (pokegold engine/pokegear/pokegear.asm TownMapPals, gfx/pokegear/pokegear.pal).
-- The two shots below have to agree: if the second one shows a pure white band
-- across the bottom of the card where the first shows cream, the pushed box is
-- still hard-filling white.
--
--   POKEPORT_IDENTITY=gold-dev POKEPORT_GAME=gold \
--     POKEPORT_SHOTS=/tmp/gearpaper \
--     POKEPORT_DRIVER=tests/drivers/gold_pokegear_call_paper.lua \
--     perl -e 'alarm 300; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
local U = require("tests.drivers.util")

local SHOTS = os.getenv("POKEPORT_SHOTS") or "/tmp/gearpaper"

return function(game)
  local function tap(button, frames)
    game.input.pressQueue[#game.input.pressQueue + 1] = button
    game.input.state[button] = true
    U.wait(2)
    game.input.state[button] = false
    U.wait(frames or 4)
  end

  U.wait(45)
  local w = game.world
  assert(w and w.map, "gold world did not boot")

  -- Joey (contact 15) is the shortest reachable call: he lives on ROUTE_30, so
  -- his number is dialable from ROUTE_31 and his SCRIPT1 talks straight away.
  local Phone = require("src.core.gen2.Phone")
  assert(w:setMap("ROUTE_31", 8, 6, "down"), "setMap failed for ROUTE_31")
  U.wait(3)
  Phone.addContact(game.save, 15)
  w:setEngineFlag(2, true) -- ENGINE_PHONE_CARD
  w:setEngineFlag(4, true) -- ENGINE_POKEGEAR
  game:openStartMenuItem("pokegear")
  U.wait(3)
  local gear = game.stack:top()
  assert(gear and gear.cards, "the Pokegear did not open")
  gear.mode = "card"
  for index, card in ipairs(gear.cards) do
    if card.id == "phone" then gear.cardIndex = index end
  end
  U.wait(3)

  -- Reference: the gear's OWN box, drawn through Pokegear:textbox.  Its
  -- interior is the cream paper, and it is the colour the call box must match.
  U.shot(game, SHOTS .. "/01-gear-own-box.png")

  tap("a", 3) -- CALL / DELETE / CANCEL on Joey's slot
  tap("a", 3) -- CALL

  -- The first page of the call, i.e. a pushed TextBox over the card.
  for _ = 1, 240 do
    local top = game.stack and game.stack:top()
    if top and top.pages and top ~= gear then break end
    U.wait(1)
  end
  U.shot(game, SHOTS .. "/02-call-textbox.png")
  U.log("compare 01 and 02: the band behind the call text must be the same",
    "cream as the gear's own box, not white")
  love.event.quit(0)
end
