-- A map object's `pokemon` field (the static wild encounter kind --
-- OverworldController.lua's `d.pokemon`, handed straight to
-- BattleState.newWild with no existence check of its own) used to go
-- completely unchecked: R.maps.objects was f.opt(f.list(f.any)), so a
-- typo'd species sat in a loaded mod and only surfaced as a crash the
-- moment a player stepped up to that object.  Every other kind sharing the
-- objects array (NPCs, signs-as-objects, warps) has fields this schema
-- still does not know about, which is what f.partial is for: it types only
-- `pokemon` and leaves the rest of an object's shape alone.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")

local function manifest(id)
  return ([[{
    "id": "%s", "name": "%s", "version": "1.0.0",
    "entry": "main.lua", "api": 2
  }]]):format(id, id)
end

-- ------- a bad species id is caught as a load error, not left to crash

local BAD = {
  ["mods/bad_static_encounter/manifest.json"] = manifest("bad_static_encounter"),
  ["mods/bad_static_encounter/main.lua"] = [[
    local mod = ...
    mod.content.maps:patch("FIX_ROUTE", {
      objects = {
        { pokemon = "NOT_A_SPECIES", level = 30, text = "Gyaoo!" },
      },
    })
  ]],
}

do
  local run = T.sdk.loadMods({ "mods/bad_static_encounter" },
    { fs = T.sdk.memfs(BAD) })
  local dangling = {}
  for _, message in ipairs(run.errors) do
    if message:match("unresolved reference") then
      dangling[#dangling + 1] = message
    end
  end
  T.eq(#dangling, 1,
    "a bad static-encounter species is reported once ("
      .. table.concat(dangling, "; ") .. ")")
  T.check(dangling[1] and dangling[1]:match("maps%.FIX_ROUTE%.objects")
    and dangling[1]:match("pokemon"),
    "the report names the map, the objects field and the pokemon registry: "
      .. tostring(dangling[1]))
  run.release()
end

-- ------- a real species resolves, and an NPC-shaped object beside it (no
-- pokemon field at all, and fields this schema never named -- sprite,
-- movement, range) is untouched

local GOOD = {
  ["mods/good_static_encounter/manifest.json"] = manifest("good_static_encounter"),
  ["mods/good_static_encounter/main.lua"] = [[
    local mod = ...
    mod.content.maps:patch("FIX_ROUTE", {
      objects = {
        { index = 1, name = "FIXROUTE_TRAINER", sprite = "SPRITE_FIX_NPC",
          movement = "STAY", range = "NONE", text = "TEXT_FIXROUTE_TRAINER",
          x = 5, y = 9 },
        { pokemon = "FIXMON_A", level = 30, text = "Gyaoo!" },
      },
    })
  ]],
}

do
  local run = T.sdk.loadMods({ "mods/good_static_encounter" },
    { fs = T.sdk.memfs(GOOD) })
  T.eq(#run.errors, 0,
    "a real species and an untyped NPC object both load clean ("
      .. tostring(run.errors[1]) .. ")")
  local objects = run.data.maps.FIX_ROUTE.objects
  T.eq(#objects, 2, "both objects landed on the map")
  T.eq(objects[1].sprite, "SPRITE_FIX_NPC",
    "the NPC object's untyped fields passed through unexamined")
  T.eq(objects[2].pokemon, "FIXMON_A",
    "the static encounter's species field passed through too")
  run.release()
end

T.finish()
