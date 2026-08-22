-- ROM-free regression coverage for the story commands introduced with the
-- Gen 1 Oak/rival/Pikachu script repairs.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = require("tests.love_stub")

local Commands = require("src.script.Commands")
local ctx = {
  save = { flags = {}, party = { { species = "BULBASAUR" } } },
  game = { data = { pokemon = {
    BULBASAUR = { name = "BULBASAUR" },
    PIKACHU = { name = "PIKACHU" },
  } } },
  overworld = {},
}

Commands.load_player_starter_name(ctx)
T.eq(ctx.game.stringBuffer, "BULBASAUR",
     "the party starter supplies the buffered name")
ctx.save.flags.EVENT_CHOSE_PIKACHU = true
Commands.load_player_starter_name(ctx)
T.eq(ctx.game.stringBuffer, "PIKACHU",
     "the explicit Yellow starter flag has priority")

local followerCall
package.loaded["src.world.PikachuFollower"] = {
  onMapEntered = function(game, overworld, map, restore)
    followerCall = { game, overworld, map, restore }
  end,
}
Commands.spawn_pikachu_follower(ctx)
T.eq(followerCall[1], ctx.game, "the follower bridge receives the game")
T.eq(followerCall[2], ctx.overworld,
     "the follower bridge receives the current overworld")
T.eq(followerCall[3], nil, "the follower bridge requests current-map data")
T.eq(followerCall[4], false, "the follower bridge requests a fresh spawn")

local musicCall
package.loaded["src.core.Music"] = {
  play = function(data, song, loop, opts)
    musicCall = { data, song, loop, opts }
  end,
}
local opts = { start = "rival", keep = true }
Commands.play_music(ctx, "Music_MeetRival", opts)
T.eq(musicCall[1], ctx.game.data, "the music bridge receives merged data")
T.eq(musicCall[2], "Music_MeetRival", "the music bridge keeps the cue")
T.eq(musicCall[3], nil, "the music bridge keeps default loop behavior")
T.eq(musicCall[4], opts, "the music bridge forwards all cue options")
T.eq(ctx.overworld.keepMusicOnce, true,
     "the keep option preserves music across the next map transition")

T.finish("story_command_bridges")
