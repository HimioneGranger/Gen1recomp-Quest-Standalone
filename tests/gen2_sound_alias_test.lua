-- Gen 2 sfx name resolution and the fanfare duck rule, ROM-free.
--   luajit tests/gen2_sound_alias_test.lua
-- Also dofile'd by tests/run_tests.lua.  Fixtures only: no Gold cache, no
-- audio device.  Covers the two contracts a Gold session leans on:
--   * a shared UI module naming a pokered sfx ("Press_AB") reaches the Gen 2
--     label through Sound.resolve, and the play/stop/isPlaying trio agree on
--     the key the source ended up cached under;
--   * a header read that could not run yet is retried, never remembered as
--     "this sfx claims no channels" (which would leave a four-channel jingle
--     playing over the map music for the rest of the session).
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 sound alias")
local check, eq = S.check, S.eq

if not _G.love then _G.love = require("tests.love_stub") end

-- Minimal audio device: enough for the file-def branch of Sound.play.
local playing = {}
local Source = {}
Source.__index = Source
function Source:play() playing[self] = true end
function Source:stop() playing[self] = nil end
function Source:isPlaying() return playing[self] == true end
function Source:setVolume(v) self.volume = v end
function Source:setPitch(p) self.pitch = p end

local built = 0
local savedAudio = love.audio
love.audio = {
  newSource = function(file)
    built = built + 1
    return setmetatable({ file = file }, Source)
  end,
}

local Sound = require("src.core.Sound")

-- === resolution ===

-- A Gen 1 cache answers to the name the shared UI already uses, so the alias
-- table must stay out of the way there.
local gen1 = { audio = { fanfares = {}, sfx = { Press_AB = "sfx/press_ab.wav" } } }
eq(Sound.resolve(gen1, "Press_AB"), "Press_AB",
  "a name the cache already has resolves to itself")

-- A Gold cache is keyed by pokegold's labels, so the same call has to hop.
local gold = {
  audio = { fanfares = {}, sfx = { Sfx_ReadText2 = "sfx/readtext2.wav" } },
}
eq(Sound.resolve(gold, "Press_AB"), "Sfx_ReadText2",
  "the A-press beep hops to the Gen 2 label")
eq(Sound.resolve(gold, "Sfx_ReadText2"), "Sfx_ReadText2",
  "a Gen 2 name is passed through untouched")
eq(Sound.resolve(gold, "Nothing_Named_This"), "Nothing_Named_This",
  "an unknown name is returned as-is")

-- Only names a Gold-reachable shared module actually plays belong in the
-- table; a row nothing calls is a wrong mapping waiting to be believed.
for name, target in pairs(Sound.GEN2_ALIASES) do
  eq(type(target), "string", ("alias %s names an sfx"):format(name))
  eq(target:sub(1, 4), "Sfx_",
    ("alias %s targets a pokegold label"):format(name))
end
eq(Sound.GEN2_ALIASES.Press_AB, "Sfx_ReadText2",
  "Press_AB is the alias the shared TextBox / ChoiceBox need")

-- === play / stop / isPlaying agree on the resolved key ===

local src = Sound.play(gold, "Press_AB")
check(src ~= nil, "the aliased sfx plays")
eq(built, 1, "one source built")
check(Sound.isPlaying("Press_AB"),
  "isPlaying finds the source under the raw name the caller used")
Sound.stop("Press_AB")
check(not Sound.isPlaying("Press_AB"),
  "stop reaches the same source (the elevator pattern: play X then stop X)")

check(not Sound.isPlaying("Never_Played"), "an unknown name reads as silent")
Sound.stop("Never_Played") -- must not raise

-- The Gen 1 side of the same call keeps its own key.
local g1src = Sound.play(gen1, "Press_AB")
check(g1src ~= nil and g1src ~= src, "a Gen 1 cache builds its own source")
check(Sound.isPlaying("Press_AB"), "and is found under its own name")
Sound.stop("Press_AB")

-- === the Gen 2 sfx priority gate (home/audio.asm PlaySFX) ===

-- Ids run highest priority first (constants/sfx_constants.asm), so a LOWER id
-- still sounding makes PlaySFX drop the request (`cp e / jr c, .done`), and an
-- id at or below wCurSFX takes the channels over because _PlaySFX zeroes
-- ch5-ch8 before it loads the new header.  Sfx never layer on this path.
local gate = {
  audio = {
    fanfares = {},
    sfxOrder = { "Sfx_Dummy", "Sfx_Tackle", "Sfx_Elevator" },
    sfx = {
      Sfx_Tackle = { file = "sfx/tackle.wav", generation = 2 },
      Sfx_Elevator = { file = "sfx/elevator.wav", generation = 2 },
    },
  },
}

local tackle = Sound.play(gate, "Sfx_Tackle")
check(tackle ~= nil, "the tackle sounds")
check(Sound.play(gate, "Sfx_Elevator") == nil,
  "SproutTower3FRivalScene: the elevator rumble is dropped, not layered")
check(tackle:isPlaying(), "and the tackle is left alone")

tackle:stop() -- the sound ends; wCurSFX only bites while a channel is on
local elevator = Sound.play(gate, "Sfx_Elevator")
check(elevator ~= nil, "with the channels free the same sfx does play")
check(Sound.play(gate, "Sfx_Tackle") ~= nil,
  "a higher-priority id is not dropped")
check(not elevator:isPlaying(), "_PlaySFX cut the sound that held the channels")

-- Battle animations reach PlayStereoSFX instead, which has no gate and never
-- writes wCurSFX (engine/battle_anims/anim_commands.asm anim_sound).
check(Sound.playStereo(gate, "Sfx_Elevator") ~= nil,
  "an animation sound plays over whatever is sounding")
check(tackle:isPlaying(), "and does not stop it either")
check(Sound.play(gate, "Sfx_Elevator") == nil,
  "the animation sound did not become the priority to beat")
tackle:stop()
elevator:stop()

-- === a header that could not be read yet is retried ===

local ChipSynth = require("src.core.ChipSynth")
local realChannels = ChipSynth.effectChannels
local calls = 0
ChipSynth.effectChannels = function()
  calls = calls + 1
  if calls == 1 then error("program banks not readable yet") end
  if calls == 2 then return nil end       -- effectChannels' own "not knowable"
  return { 5, 6, 7, 8 }
end

local jingle = {
  audio = { fanfares = {},
            sfx = { Sfx_TestJingle = { address = 0x4000, generation = 2 } } },
}
check(not Sound.ducksMusic(jingle, "Sfx_TestJingle"),
  "a header read that raised does not duck")
eq(calls, 1, "one attempt so far")
check(not Sound.ducksMusic(jingle, "Sfx_TestJingle"),
  "nor does one that answered nil")
eq(calls, 2, "the failure was retried, not remembered as zero channels")
check(Sound.ducksMusic(jingle, "Sfx_TestJingle"),
  "the read that worked ducks the music: four channels leave the song none")
eq(calls, 3, "three attempts")
check(Sound.ducksMusic(jingle, "Sfx_TestJingle"),
  "still ducks")
eq(calls, 3, "and THAT answer is cached, so the header is read once")

ChipSynth.effectChannels = realChannels
Sound.invalidate()
love.audio = savedAudio

S.finish()
