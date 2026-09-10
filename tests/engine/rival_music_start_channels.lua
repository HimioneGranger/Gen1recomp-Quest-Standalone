-- Regression: the Gen 1 rival cue can start each chip channel at its
-- alternate entry point. The alternate request must also bypass the normal
-- same-song dedupe, while the shared registry definition stays unchanged.
-- ROM-free: ChipAudio is replaced with a recording stub.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = require("tests.love_stub")
love.audio = {}

local Source = {}
Source.__index = Source
function Source:play() self.playing = true end
function Source:stop() self.playing = false end
function Source:pause() self.playing = false end
function Source:isPlaying() return self.playing end
function Source:setLooping(value) self.looping = value end
function Source:setVolume(value) self.volume = value end
function Source:setFilter() end

local starts = {}
package.loaded["src.core.ChipAudio"] = {
  playMusic = function(_data, header, allowLoops)
    starts[#starts + 1] = { header = header, allowLoops = allowLoops }
    return setmetatable({}, Source)
  end,
  stopMusic = function() end,
  holdMusic = function() end,
}

local Music = require("src.core.Music")
local song = { bank = 2, address = 17050 }
local data = { audio = { songs = { Music_MeetRival = song } } }

Music.play(data, "Music_MeetRival", true, { start = "rival" })
T.eq(#starts, 1, "the alternate rival cue starts once")
T.eq(starts[1].header.startChannels[1].address, 0x71a2,
     "channel 1 uses the rival entry point")
T.eq(starts[1].header.startChannels[2].address, 0x721d,
     "channel 2 uses the rival entry point")
T.eq(starts[1].header.startChannels[3].address, 0x72b5,
     "channel 3 uses the rival entry point")
T.eq(song.startChannels, nil, "the shared registry definition is not mutated")

Music.play(data, "Music_MeetRival", true)
T.eq(#starts, 2, "changing the start mode bypasses same-song dedupe")
T.eq(starts[2].header, song, "the normal cue uses the shared definition")
Music.play(data, "Music_MeetRival", true)
T.eq(#starts, 2, "an unchanged start mode still deduplicates")

local ChipSynth = require("src.core.ChipSynth")
local header = {
  chip = {
    blob = "",
    channels = {
      { number = 1, address = 0x4000 },
      { number = 2, address = 0x4100 },
    },
  },
  startChannels = { { number = 1, address = 0x4200 } },
}
local engine = ChipSynth.newEngine({ audio = {} }, header)
T.eq(engine.channels[1].address, 0x4200,
     "the synth applies a requested channel entry point")
T.eq(engine.channels[2].address, 0x4100,
     "the synth preserves channels with no override")

T.finish("rival_music_start_channels")
