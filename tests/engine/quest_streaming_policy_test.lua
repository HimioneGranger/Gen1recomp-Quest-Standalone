-- Quest startup and speculative major-map work must remain bounded by the
-- physical device profile rather than expanding into a regional bake.
--   luajit tests/engine/quest_streaming_policy_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
local check, eq = T.check, T.eq
local Policy = require("src.quest.dramaless.StreamingPolicy")

eq(Policy.PRELOAD_HOPS, 1, "startup walks only the immediate connection ring")
eq(Policy.PRELOAD_MAP_CAP, 6, "startup retains at most current plus five maps")
eq(Policy.PRELOAD_FULL_CAP, 1, "only one neighbour may receive a full promotion")

check(Policy.allowMajorPreload(16384),
  "Saffron 128px from the Route 8 gate is close enough to prefetch")
check(Policy.allowMajorPreload(512 * 512),
  "the exact prefetch boundary remains eligible")
check(not Policy.allowMajorPreload(893025),
  "Lavender does not speculatively rebuild distant Saffron")
check(not Policy.allowMajorPreload(nil),
  "an unknown distance never starts speculative work")

check(not Policy.dropPreviousFor("connection"),
  "walking connections retain one neighborhood for a quick reversal")
check(Policy.dropPreviousFor("fly"),
  "Fly releases the unrelated previous neighborhood")
check(not Policy.dropPreviousFor("warp"),
  "door warps retain the warm return neighborhood")

T.finish("Quest streaming policy")
