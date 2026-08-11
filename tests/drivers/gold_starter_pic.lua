-- The starter choice at Elm's lab, which is the first `pokepic` a player meets.
--
-- maps/ElmsLab.asm, ElmsLabPokeBallScript (one per ball, Cyndaquil's at (6,3)):
--
--     turnobject ELMSLAB_ELM, DOWN
--     reanchormap
--     pokepic CYNDAQUIL
--     cry CYNDAQUIL
--     waitbutton
--     closepokepic
--     opentext
--     writetext ElmsLabText_ChooseCyndaquil
--     yesorno
--
-- The pic goes up with NO text window under it, so nothing else in that run of
-- commands consumes a button press: `waitbutton` (Script_waitbutton ->
-- WaitButton, home/text.asm) is the ONLY thing holding the frame, and it is
-- what gives the player time to look at the mon before the yes/no.  The port
-- used to treat every `waitbutton` as already-paid-for by the text box that
-- usually precedes it, so pokepic / closepokepic ran inside one VM resume and
-- the pic was created and destroyed without a single frame drawing it (#911).
--
-- This driver stands in front of the Cyndaquil ball, presses A, and counts the
-- frames where World.pokePic is actually up.  It shoots the popup, so a human
-- can see the pic and not just a number.
--
--   POKEPORT_GAME=gold POKEPORT_DRIVER=tests/drivers/gold_starter_pic.lua \
--     POKEPORT_SHOT_DIR=/tmp/gold-starter \
--     perl -e 'alarm 280; exec @ARGV' \
--     python3 -c "import pty; pty.spawn(['love','.'])"
local SHOT_DIR = os.getenv("POKEPORT_SHOT_DIR") or "/tmp/gold-starter"

-- main.lua's love.visible / love.focus handlers call Game:visible / Game:focus,
-- and src/core/Game2.lua defines neither -- so on Gold any window event (another
-- app taking the screen, which is constant when drivers share a machine) kills
-- the run before a single assertion prints.  Fixing that belongs in Game2, not
-- in a driver; surviving it belongs here, so this run swallows the two
-- callbacks.  Loaded from love.load, i.e. after main.lua has installed its own.
function love.visible() end
function love.focus() end

return function(game)
  local w = game.world
  local fails = 0

  local function wait(n) for _ = 1, n do coroutine.yield() end end

  local function ok(cond, msg)
    if cond then
      print("[starter] ok   " .. msg)
    else
      fails = fails + 1
      print("[starter] FAIL " .. msg)
    end
    return cond
  end

  local function shot(name)
    local path = SHOT_DIR .. "/" .. name .. ".png"
    game.capturePath = path
    for _ = 1, 120 do
      if not game.capturePath then break end
      coroutine.yield()
    end
    wait(1)
    local f = io.open(path, "rb")
    if f then f:close() return true end
    print("[starter] FAIL screenshot did not reach disk: " .. path)
    fails = fails + 1
    return false
  end

  local function tap(btn)
    table.insert(game.input.pressQueue, btn)
    coroutine.yield()
    game.input.state[btn] = false
  end

  os.execute('mkdir -p "' .. SHOT_DIR .. '" 2>/dev/null')
  wait(45)

  -- SCENE_ELMSLAB_NOTHING: the meet-Elm walk-in has already played, which is
  -- the state a player is in when they walk over to the balls.
  w.mapScenes.ELMS_LAB = 1
  w:setMap("ELMS_LAB", 6, 4, "up")
  wait(20)

  local shown, hidden = 0, 0
  local realShow, realHide = w.showPokePic, w.hidePokePic
  w.showPokePic = function(self, species)
    shown = shown + 1
    return realShow(self, species)
  end

  tap("a")

  -- Count the frames the pic is actually up.  The pic is a field on the world
  -- rather than a pushed state, so this is the same thing love.draw reads.
  local picFrames, sawPic = 0, false
  for i = 1, 260 do
    if w.pokePic then
      picFrames = picFrames + 1
      if not sawPic then
        sawPic = true
        shot("01_starter_popup")
      end
    end
    if sawPic and not w.pokePic then break end
    -- Press A again only once the pic has been on screen a while, so the
    -- driver measures the hold instead of ending it on frame one.
    if picFrames == 90 then tap("a") end
    if i % 4 == 0 and not sawPic then tap("a") end
    coroutine.yield()
  end

  ok(shown > 0, "the ball script ran `pokepic` (" .. shown .. " call(s))")
  ok(picFrames > 0,
    "and the pic was on screen for " .. picFrames .. " drawn frame(s)")
  ok(picFrames >= 30,
    "long enough to read: `waitbutton` holds it until the player presses A")

  -- The yes/no follows the pic, so a run that got this far is at the prompt.
  for _ = 1, 120 do
    if w.choicebox or game.stack:top() ~= game.overworld then break end
    coroutine.yield()
  end
  -- The box opens empty and types itself in over the next few frames, so a
  -- capture on the frame it appeared would photograph a blank window and
  -- prove nothing about the question.
  wait(60)
  shot("02_confirm_prompt")

  if fails > 0 then
    error(("gold starter pic: %d assertion(s) failed"):format(fails))
  end
  print("[driver] PASS gold starter pic: pokepic holds until A, then asks")
end
