-- Automated joypad input (home/joypad.asm GetJoypad .auto, StartAutoInput,
-- StopAutoInput).  ROM-free: `luajit tests/gen2_autoinput_test.lua`.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 auto input")
local check, eq = S.check, S.eq

love = require("tests.love_stub")

local AutoInput = require("src.core.gen2.AutoInput")
local Input = require("src.core.Input")
local Vm = require("src.script.gen2.Vm")

-- ---- the ring itself ------------------------------------------------------
-- Stream format is [input][duration], the duration counts EXTRA frames, and a
-- duration of $ff parks on the pair forever with the input forced to NO_INPUT.
do
  local ring = AutoInput.new()
  check(not ring:isActive(), "a fresh ring is not armed")
  check(ring:start({ AutoInput.PAD_A, 0x02, AutoInput.PAD_B, 0x00, 0xff }),
    "start arms a raw byte stream")
  check(ring:isActive(), "and the ring reports the controller as taken")

  -- StartAutoInput leaves wAutoInputLength at 0, so the first frame already
  -- reads the stream: A is held for 1 + 2 frames.
  eq(ring:advance(), AutoInput.PAD_A, "frame 1 reads A out of the stream")
  eq(ring:advance(), AutoInput.PAD_A, "frame 2 is inside A's duration")
  eq(ring:advance(), AutoInput.PAD_A, "frame 3 is the last of A's duration")
  eq(ring:advance(), AutoInput.PAD_B, "frame 4 takes the next pair")
  -- duration 0 means exactly one frame, so the terminator lands next.
  local mask, ended = ring:advance()
  eq(mask, AutoInput.NO_INPUT, "the $ff terminator reads as NO_INPUT")
  check(ended, "and reports the stream as finished")
  check(not ring:isActive(), "StopAutoInput has run by then")
end

do
  -- "A duration of $ff will end the stream indefinitely": the input is
  -- overwritten with NO_INPUT and the address is NOT advanced, so the same
  -- pair is re-read every 256 frames and the stream never terminates.
  local ring = AutoInput.new()
  ring:start({ AutoInput.PAD_A, 0xff })
  eq(ring:advance(), AutoInput.NO_INPUT,
    "a $ff duration overwrites its own input")
  for _ = 1, 0xff do ring:advance() end
  eq(ring:advance(), AutoInput.NO_INPUT, "and re-arms itself on the same pair")
  check(ring:isActive(), "a $ff duration never hands control back")
end

-- ---- the four streams the ROM actually has --------------------------------
do
  -- engine/events/catch_tutorial_input.asm DudeAutoInput_A: 0x50 blank frames,
  -- one frame of A, then park.
  local ring = AutoInput.new()
  ring:start("DUDE_A")
  local quiet = true
  for _ = 1, 0x51 do
    if ring:advance() ~= AutoInput.NO_INPUT then quiet = false end
  end
  check(quiet, "DUDE_A waits 0x51 frames before answering")
  eq(ring:advance(), AutoInput.PAD_A, "then presses A on frame 0x52")
  eq(ring:advance(), AutoInput.NO_INPUT, "and releases it the frame after")
  check(ring:isActive(), "DUDE_A parks rather than terminating")

  -- engine/events/catch_tutorial.asm CatchTutorial.AutoInput is nothing but a
  -- lockout: NO_INPUT held for as long as the demo lasts.
  local lock = AutoInput.new()
  lock:start("CATCH_TUTORIAL")
  eq(lock:advance(), AutoInput.NO_INPUT, "the tutorial stream presses nothing")
  check(lock:isActive(), "but it does hold the controller")
end

do
  -- A `dba` from an autoinput command resolves against the four StartAutoInput
  -- call sites in ../pokegold-symbols/pokegold.sym.
  local ring = AutoInput.new()
  check(ring:startPointer(0x70, 0x4e04),
    "70:4e04 is DudeAutoInput_RightA")
  eq(ring:advance(), AutoInput.NO_INPUT, "which opens with eight blank frames")
  for _ = 1, 8 do ring:advance() end
  eq(ring:advance(), AutoInput.PAD_RIGHT, "then taps RIGHT")

  local unknown = AutoInput.new()
  check(not unknown:startPointer(0x3e, 0x4000),
    "a pointer with no stream behind it arms nothing")
  check(not unknown:isActive(),
    "rather than taking the controller away with no way back")
end

-- ---- through src/core/Input.lua -------------------------------------------
-- The point of the port: a canned frame has to look like a real press to the
-- per fixed-step edge detection, the same way the touch overlay's does.
do
  Input:init()
  local ring = AutoInput.new()
  ring:start({ AutoInput.PAD_A, 0x01, 0xff }, Input)

  ring:step(Input)
  Input:step()
  check(Input:isDown("a"), "an auto frame holds A")
  check(Input:wasPressed("a"), "and reads as an edge on the step it lands")

  ring:step(Input)
  Input:step()
  check(Input:isDown("a"), "A stays held through its duration")
  check(Input:wasPressed("a"),
    "hJoyPressed is latched for the whole duration, not just its first frame")

  ring:step(Input)
  Input:step()
  check(not Input:isDown("a"), "the terminator releases A")
  check(not ring:isActive(), "and stops the ring")
end

do
  -- While a stream is armed GetJoypad never reads hJoypadDown, so a player
  -- leaning on a key cannot steer the DUDE.
  Input:init()
  local ring = AutoInput.new()
  ring:start({ AutoInput.PAD_A, 0x00, AutoInput.NO_INPUT, 0x02, 0xff }, Input)

  Input:keypressed("left")
  ring:step(Input)
  Input:step()
  check(not Input:isDown("left"), "a physically held key is discarded")
  check(Input:isDown("a"), "only the stream's own button is down")

  ring:step(Input)
  Input:step()
  check(not Input:isDown("a"), "and the stream's next pair presses nothing")
  check(not Input:isDown("left"), "with the player still locked out")
end

do
  -- The handback: the frame the terminator lands on still belongs to the
  -- stream, and the step after it is the player's again.  love_stub has no
  -- keyboard, so the restore is asserted by the ring reporting the controller
  -- released rather than by the key coming back.
  Input:init()
  local ring = AutoInput.new()
  ring:start({ 0xff }, Input)
  check(ring:step(Input), "the terminator frame is still an auto frame")
  check(not ring:isActive(), "StopAutoInput ran on it")
  check(not ring:step(Input), "the next step is the player's")
  check(not ring:step(Input), "and stays that way")
end

-- ---- the script side ------------------------------------------------------
do
  -- Script_autoinput: three GetScriptByte calls, bank first, then the low and
  -- high halves of the address.  It does not write wScriptVar.
  local seen
  local vm = Vm.new({
    ["s:t"] = {
      { op = "setval", value = 5 },
      { op = "autoinput", args = { 0x70, 0x0e, 0x4e } },
      { op = "end" },
    },
  }, {}, nil, {
    autoInput = function(bank, address) seen = { bank, address } end,
  })
  vm:start("s:t")
  eq(seen and seen[1], 0x70, "the bank is the first operand byte")
  eq(seen and seen[2], 0x4e0e, "and the address is little-endian after it")
  eq(vm.scriptVar, 5, "autoinput leaves wScriptVar alone")
end

do
  -- Script_catchtutorial farcalls CatchTutorial, which brackets StartBattle in
  -- StartAutoInput / StopAutoInput, and only then falls into Script_reloadmap.
  local order = {}
  local vm = Vm.new({
    ["s:t"] = {
      { op = "catchtutorial", args = { 3 } },
      { op = "end" },
    },
  }, {}, nil, {
    autoInputStream = function(name) order[#order + 1] = "start:" .. name end,
    stopAutoInput = function() order[#order + 1] = "stop" end,
    reloadMap = function() order[#order + 1] = "reload" end,
  })
  vm:start("s:t")
  eq(table.concat(order, ","), "start:CATCH_TUTORIAL,stop,reload",
    "the lockout closes before the map reload, as in the asm")
end

S.finish()
