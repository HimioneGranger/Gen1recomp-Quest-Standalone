-- wCmdQueue and the stone table (engine/overworld/cmd_queue.asm,
-- home/stone_queue.asm).  ROM-free: `luajit tests/gen2_cmdqueue_test.lua`.
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 cmd queue")
local check, eq = S.check, S.eq

local CmdQueue = require("src.world.gen2.CmdQueue")

-- ---- the four slots -------------------------------------------------------
do
  local q = CmdQueue.new()
  eq(CmdQueue.count(q), 0, "a fresh queue is empty")
  for i = 1, CmdQueue.CAPACITY do
    eq(CmdQueue.write(q, { kind = CmdQueue.TYPE1 }), i,
      "WriteCmdQueue fills the first free slot (" .. i .. ")")
  end
  check(CmdQueue.write(q, { kind = CmdQueue.TYPE1 }) == nil,
    "a full queue sets carry and the write is DROPPED, not overwritten")
  eq(CmdQueue.count(q), CmdQueue.CAPACITY, "four is the capacity")
  CmdQueue.clear(q)
  eq(CmdQueue.count(q), 0, "ClearCmdQueue zeroes every type byte")
end

-- DelCmdQueue answers whether it found the entry, which is the OPPOSITE of what
-- `delcmdqueue` writes to wScriptVar: `ret c` returns on the delete with
-- wScriptVar still 0, and only a miss falls through to TRUE.
do
  local q = CmdQueue.new()
  CmdQueue.write(q, { kind = CmdQueue.STONETABLE })
  check(not CmdQueue.delete(q, CmdQueue.TYPE4), "a type not in the queue misses")
  check(CmdQueue.delete(q, CmdQueue.STONETABLE), "and the one that is, hits")
  eq(CmdQueue.count(q), 0, "leaving the slot free")
  check(not CmdQueue.delete(q, CmdQueue.STONETABLE), "and only once")
end

-- ---- .IsObjectOnWarp ------------------------------------------------------
do
  local warps = { { x = 1, y = 1 }, { x = 11, y = 2 }, { x = 4, y = 7 } }
  eq(CmdQueue.warpNumberAt(warps, 11, 2), 2,
    "the answer is the warp NUMBER, 1-based, not a boolean")
  eq(CmdQueue.warpNumberAt(warps, 4, 7), 3, "counted in warp_event order")
  check(CmdQueue.warpNumberAt(warps, 9, 9) == nil, "and nil off a warp")
end

-- ---- .IsObjectInStoneTable ------------------------------------------------
do
  local rows = {
    { warp = 3, object = 2, script = "a" },
    { warp = 4, object = 3, script = "b" },
  }
  eq(CmdQueue.stoneRow(rows, 4, 3).script, "b", "both bytes have to match")
  check(CmdQueue.stoneRow(rows, 3, 3) == nil,
    "the right boulder on the wrong hole does not fall")
  check(CmdQueue.stoneRow(rows, 4, 2) == nil, "nor the wrong boulder on it")
end

-- ---- CmdQueue_StoneTable's four gates -------------------------------------
local ICE_WARPS = {
  { x = 3, y = 15 }, { x = 17, y = 3 }, { x = 11, y = 2 },
  { x = 4, y = 7 }, { x = 5, y = 12 }, { x = 12, y = 13 },
}

local function iceCtx(objects, pits)
  return {
    objects = objects,
    warps = ICE_WARPS,
    collisionAt = function(x, y)
      for _, p in ipairs(pits or {}) do
        if p[1] == x and p[2] == y then return 0x60 end -- COLL_PIT
      end
      return 0x00
    end,
  }
end

local ICE = CmdQueue.mapEntry("ICE_PATH_B1F")

do
  check(ICE ~= nil, "Ice Path B1F has a stone table")
  eq(ICE.kind, CmdQueue.STONETABLE, "written as CMDQUEUE_STONETABLE")
  eq(#ICE.rows, 4, "with a row per boulder")
  check(CmdQueue.mapEntry("NEW_BARK_TOWN") == nil,
    "and a map with no callback has none")
end

-- The happy path: boulder 1 (object id 2) pushed onto warp 3 at (11,2).
do
  local boulder = { id = 2, movement = CmdQueue.BOULDER_MOVEDATA,
    cellX = 11, cellY = 2, moving = false }
  local row = CmdQueue.stoneFall(ICE, iceCtx({ boulder }, { { 11, 2 } }))
  check(row ~= nil, "a boulder standing on its own hole falls through")
  eq(row.warp, 3, "through warp 3")

  -- ...and each of the four gates alone stops it.
  check(CmdQueue.stoneFall(ICE, iceCtx({ boulder }, {})) == nil,
    "CheckPitTile: a warp tile that is not a PIT is not a hole")
  boulder.moving = true
  check(CmdQueue.stoneFall(ICE, iceCtx({ boulder }, { { 11, 2 } })) == nil,
    "OBJECT_WALKING: a boulder mid-push does not fall early")
  boulder.moving = false
  boulder.movement = 1
  check(CmdQueue.stoneFall(ICE, iceCtx({ boulder }, { { 11, 2 } })) == nil,
    "OBJECT_MOVEMENT_TYPE: only a STRENGTH_BOULDER is checked at all")
  boulder.movement = CmdQueue.BOULDER_MOVEDATA
  boulder.visible = false
  check(CmdQueue.stoneFall(ICE, iceCtx({ boulder }, { { 11, 2 } })) == nil,
    "OBJECT_SPRITE: one already disappeared has no struct left")
end

-- A boulder on the WRONG hole stays put -- both stonetable bytes must match.
do
  local wrong = { id = 2, movement = CmdQueue.BOULDER_MOVEDATA,
    cellX = 4, cellY = 7, moving = false }
  check(CmdQueue.stoneFall(ICE, iceCtx({ wrong }, { { 4, 7 } })) == nil,
    "boulder 1 does not fall through boulder 2's hole")
end

-- HandleStoneQueue returns on the FIRST match, so two never drop together.
do
  local a = { id = 2, movement = CmdQueue.BOULDER_MOVEDATA,
    cellX = 11, cellY = 2, moving = false }
  local b = { id = 3, movement = CmdQueue.BOULDER_MOVEDATA,
    cellX = 4, cellY = 7, moving = false }
  local q = CmdQueue.new()
  CmdQueue.write(q, ICE)
  local row, obj = CmdQueue.poll(q, iceCtx({ a, b }, { { 11, 2 }, { 4, 7 } }))
  eq(obj.id, 2, "the first boulder in object order is the one that drops")
  eq(row.warp, 3, "and its own row is what runs")
end

-- An empty queue polls to nothing, which is the state every other map is in.
do
  eq(CmdQueue.poll(CmdQueue.new(), iceCtx({}, {})), nil,
    "no entry, nothing to handle")
end

-- ---- the two hand-ported tables -------------------------------------------
-- Object ids are the cart's (`object_const_def` is `const_def 2`), and the
-- Blackthorn rows are transcribed in the cart's own out-of-order warp mapping.
do
  local rows = ICE.rows
  for i, row in ipairs(rows) do
    eq(row.object, i + 1, "Ice Path boulder " .. i .. " is object id " .. (i + 1))
    eq(row.warp, i + 2, "and falls through warp " .. (i + 2))
  end

  local gym = CmdQueue.mapEntry("BLACKTHORN_GYM_2F")
  eq(#gym.rows, 3, "Blackthorn Gym 2F has three rows for its six boulders")
  eq(gym.rows[1].warp, 5, "BOULDER1 -> warp 5")
  eq(gym.rows[2].warp, 3, "BOULDER2 -> warp 3, not 4")
  eq(gym.rows[3].warp, 4, "BOULDER3 -> warp 4: the cart's own order, kept")
end

-- The script each row runs: .FinishBoulder, with .BoulderFallsThrough inlined.
do
  local script = ICE.rows[1].script
  local ops = {}
  for _, cmd in ipairs(script) do ops[#ops + 1] = cmd.op end
  eq(table.concat(ops, ","),
    "disappear,clearevent,pause,playsound,earthquake,opentext,rawtext," ..
    "waitbutton,closetext,end",
    "the order is .FinishBoulder's, with .BoulderFallsThrough inlined")
  eq(script[1].object, 2, "it disappears its own boulder")
  eq(script[2].event, 1805,
    "and clears EVENT_BOULDER_IN_ICE_PATH_1A, which is what puts the boulder " ..
    "on the floor below")
  eq(script[3].frames, 30, "pause 30")
  eq(script[5].param, 80,
    "earthquake 80: two pixels for sixteen frames, one byte carrying both")

  local gym = CmdQueue.mapEntry("BLACKTHORN_GYM_2F")
  local gymOps = {}
  for _, cmd in ipairs(gym.rows[1].script) do gymOps[#gymOps + 1] = cmd.op end
  check(not table.concat(gymOps, ","):find("clearevent"),
    "the gym's boulders clear no event: nothing appears downstairs")
end

S.finish()
