-- Offline reachability over the extracted Gold cache.
--
--   luajit tools/goldwalk/mapgraph.lua path CHERRYGROVE_CITY ILEX_FOREST
--   luajit tools/goldwalk/mapgraph.lua map ROUTE_32
--   luajit tools/goldwalk/mapgraph.lua reach ROUTE_32 18 6
--   luajit tools/goldwalk/mapgraph.lua exits ROUTE_32
--   luajit tools/goldwalk/mapgraph.lua audit            (every map's exits)
--   luajit tools/goldwalk/mapgraph.lua graph > tests/drivers/gold/map_regions.lua
--
-- The route bot's planner works from the live world, which means every question
-- about the map graph used to cost a run.  This answers the same questions from
-- the cache in milliseconds: which exits of a map are reachable from which
-- others, whether a connection's border is actually walkable, and what the real
-- shortest path between two maps is.  `path` is the ground truth the bot's
-- travel is measured against; `reach` is what says whether a warp cell can be
-- walked to from where the player lands.
--
-- Surf is modelled as an option (`--surf`) rather than a fact, because whether
-- water counts as passable is exactly the difference between a route that needs
-- HM03 and one that does not.

package.path = "./?.lua;./?/init.lua;" .. package.path

local Permissions = require("src.world.gen2.Permissions")

local CACHE = os.getenv("GOLD_CACHE")
  or ((os.getenv("HOME") or "") .. "/Library/Application Support/LOVE/gold-dev/gold")

local maps = assert(loadfile(CACHE .. "/data/generated/maps.lua"))()
local tilesets = assert(loadfile(CACHE .. "/data/generated/tilesets.lua"))()

local SURF = false
for _, a in ipairs(arg) do if a == "--surf" then SURF = true end end

-- ---------------------------------------------------------------------------
-- geometry
-- ---------------------------------------------------------------------------

local function tilesetOf(def)
  -- Extracted tilesets are keyed both ways depending on the table; try id then
  -- name so this does not depend on which the extractor happened to write.
  return tilesets[def.tilesetId] or tilesets[(def.tilesetId or 0) + 1]
      or tilesets[def.tileset]
end

local function cellCollision(def, cx, cy)
  local w, h = def.width, def.height
  local bx, by = math.floor(cx / 2), math.floor(cy / 2)
  local id
  if bx < 0 or by < 0 or bx >= w or by >= h then
    id = def.borderBlock or 0
  else
    id = def.blocks[by * w + bx + 1] or 0
  end
  if id == 0 then return 0xff end
  local ts = tilesetOf(def)
  local quad = ts and ts.collision and ts.collision[id + 1]
  if not quad then return 0xff end
  return quad[(cy % 2) * 2 + (cx % 2) + 1] or 0xff
end

local function inBounds(def, cx, cy)
  return cx >= 0 and cy >= 0 and cx < def.width * 2 and cy < def.height * 2
end

-- Warp cells are holes in the floor, not floor.
--
-- Stepping onto one leaves the map, so a flood fill that walks THROUGH warps
-- draws a map that cannot be walked.  Route 33 is the case that proves it: its
-- northern strip and its southern strip touch at exactly one cell, (11,9), and
-- that cell is the Union Cave entrance.  Treat it as floor and Route 33 is one
-- connected map, its west border reaches Azalea Town proper, and the planner
-- confidently routes a walk that ends in a cave.  Treat it as a hole and the
-- truth appears: you reach southern Route 33, and therefore Azalea, only by
-- coming out of Union Cave.
-- ...but only when the tile itself is a warp.  CheckWarpTile reads the
-- COLLISION, so a `warp_event` sitting on plain floor never fires -- and
-- Ecruteak Gym is full of those: several of its thirty floor-hole coordinates
-- are ordinary floor, and they are the safe path between the pits.  Treating
-- the coordinate as the hole cut that gym in two and hid Morty.
local function warpIndexAt(def, cx, cy)
  for i, w in ipairs(def.warps or {}) do
    if w.x == cx and w.y == cy then
      local coll = cellCollision(def, cx, cy)
      if Permissions.isWarpCollision(coll)
          or Permissions.carpetDirection(coll) ~= nil then
        return i
      end
      return nil
    end
  end
  return nil
end

local function floorAt(def, cx, cy)
  if not inBounds(def, cx, cy) then return false end
  local coll = cellCollision(def, cx, cy)
  if Permissions.isWalkable(coll) then return true end
  if SURF and Permissions.isWater(coll) then return true end
  return false
end

local function passable(def, cx, cy)
  if not floorAt(def, cx, cy) then return false end
  return warpIndexAt(def, cx, cy) == nil
end

-- Movement is DIRECTED, and the fill has to be too.
--
-- Two cart mechanics make cells one-way (see Permissions.stepPermitted /
-- ledgeFacings): Gold's side-wall arms -- standing on an UP_WALL you may not
-- move up, and nobody may step DOWN onto one -- and ledge hops, where a
-- refused step off a HOP tile jumps TWO cells in its own directions and never
-- comes back.  Burned Tower B1F is the map that forced this: its fall-landing
-- pockets drain into the main floor only through hop-down ledges, so an
-- undirected fill called them sealed and the planner teleported out.
--
-- A "region" is therefore a strongly connected component -- the cells that can
-- all reach EACH OTHER -- and a region's usable exits are computed over its
-- forward closure (everything it can reach, one-way drains included).
local DELTA4 = { { 0, -1, "up" }, { 0, 1, "down" },
                 { -1, 0, "left" }, { 1, 0, "right" } }

local function collOf(def)
  return function(x, y) return cellCollision(def, x, y) end
end

-- Successors of (x, y): ordinary steps plus ledge hops, exactly the engine's
-- order (a hop fires only when the single step is refused).
local function stepsFrom(def, x, y)
  local out = {}
  local co = collOf(def)
  local hop = Permissions.ledgeFacings(cellCollision(def, x, y))
  for _, d in ipairs(DELTA4) do
    local nx, ny, dir = x + d[1], y + d[2], d[3]
    if Permissions.stepPermitted(co, x, y, dir) and passable(def, nx, ny) then
      out[#out + 1] = { nx, ny }
    elseif hop and hop[dir] then
      local hx, hy = x + d[1] * 2, y + d[2] * 2
      if passable(def, hx, hy) then out[#out + 1] = { hx, hy } end
    end
  end
  return out
end

-- Can (x, y) step or hop onto (tx, ty)?  Used by the backward fill.
local function stepsOnto(def, x, y, tx, ty)
  if not passable(def, x, y) then return false end
  for _, s in ipairs(stepsFrom(def, x, y)) do
    if s[1] == tx and s[2] == ty then return true end
  end
  return false
end

-- Forward-reachable set from (sx,sy) (the honest "what can I reach from
-- here"), keyed y*4096+x.
local function region(def, sx, sy)
  local key = function(x, y) return y * 4096 + x end
  local seen = { [key(sx, sy)] = true }
  local queue, head = { { sx, sy } }, 1
  while head <= #queue do
    local c = queue[head]; head = head + 1
    for _, s in ipairs(stepsFrom(def, c[1], c[2])) do
      local k = key(s[1], s[2])
      if not seen[k] then
        seen[k] = true
        queue[#queue + 1] = s
      end
    end
  end
  return seen
end

-- Everything that can REACH (sx,sy): the same fill over reversed edges.  A
-- predecessor is an adjacent cell stepping in, or a cell two out hopping in.
local function regionBackward(def, sx, sy)
  local key = function(x, y) return y * 4096 + x end
  local seen = { [key(sx, sy)] = true }
  local queue, head = { { sx, sy } }, 1
  while head <= #queue do
    local c = queue[head]; head = head + 1
    for _, d in ipairs(DELTA4) do
      for _, dist in ipairs({ 1, 2 }) do
        local px, py = c[1] + d[1] * dist, c[2] + d[2] * dist
        local k = py * 4096 + px
        if not seen[k] and stepsOnto(def, px, py, c[1], c[2]) then
          seen[k] = true
          queue[#queue + 1] = { px, py }
        end
      end
    end
  end
  return seen
end

-- The strongly connected component of (sx,sy): forward ∩ backward.
local function scc(def, sx, sy)
  local fwd = region(def, sx, sy)
  local bwd = regionBackward(def, sx, sy)
  local out = {}
  for k in pairs(fwd) do
    if bwd[k] then out[k] = true end
  end
  return out
end

local DIR_DELTA = { north = { 0, -1 }, south = { 0, 1 },
                    west = { -1, 0 }, east = { 1, 0 } }

-- Border cells of `def` on the given side that a player could stand on.
local function borderCells(def, dir)
  local w, h = def.width * 2, def.height * 2
  local out = {}
  if dir == "north" then
    for x = 0, w - 1 do if passable(def, x, 0) then out[#out + 1] = { x, 0 } end end
  elseif dir == "south" then
    for x = 0, w - 1 do
      if passable(def, x, h - 1) then out[#out + 1] = { x, h - 1 } end
    end
  elseif dir == "west" then
    for y = 0, h - 1 do if passable(def, 0, y) then out[#out + 1] = { 0, y } end end
  else
    for y = 0, h - 1 do
      if passable(def, w - 1, y) then out[#out + 1] = { w - 1, y } end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- the graph
-- ---------------------------------------------------------------------------
-- A node is (map, region): two warps on the same map that cannot walk to each
-- other are genuinely different places, which is the fact a map-only graph
-- misses and the bot's planner pays for at run time.

-- A warp you can LEAVE through, as opposed to one you can only arrive on.
--
-- Half the warp_events in a multi-floor interior sit on plain floor: they are
-- the landing spot of a ladder on the other side, and CheckWarpTile will never
-- fire on them because the collision is not a warp.  Offering them as exits is
-- how the Olivine lighthouse trapped the bot -- 3F's seven-cell pocket has
-- three warps in it, two of them (8 and 9, both `coll=00`) arrival-only, and
-- the planner kept choosing those instead of the one real ladder at (9,5).
local function firesAsExit(def, w)
  local coll = cellCollision(def, w.x, w.y)
  return Permissions.isWarpCollision(coll)
      or Permissions.carpetDirection(coll) ~= nil
end

local function exitsOf(id)
  local def = maps[id]
  if not def then return {} end
  local out = {}
  for i, w in ipairs(def.warps or {}) do
    if w.destMap and maps[w.destMap] and firesAsExit(def, w) then
      out[#out + 1] = { kind = "warp", index = i, x = w.x, y = w.y,
                        to = w.destMap, destWarp = w.destWarp }
    end
  end
  for dir, conn in pairs(def.connections or {}) do
    if conn.mapId and maps[conn.mapId] then
      out[#out + 1] = { kind = "edge", dir = dir, to = conn.mapId,
                        offset = conn.offset or 0 }
    end
  end
  return out
end

-- Where does an exit deposit the player on the destination map?
local function landingOf(id, exit)
  local def = maps[id]
  local destDef = maps[exit.to]
  if not destDef then return nil end
  if exit.kind == "warp" then
    local w = (destDef.warps or {})[exit.destWarp]
    if w then return w.x, w.y end
    -- destWarp out of range happens on a few one-way warps; fall back to the
    -- first warp so the graph still has an anchor.
    local first = (destDef.warps or {})[1]
    return first and first.x, first and first.y
  end
  local dw, dh = destDef.width * 2, destDef.height * 2
  local d = DIR_DELTA[exit.dir]
  if not d then return nil end
  -- The connection strip lands you on the far border, offset in blocks.
  if exit.dir == "north" then return nil, dh - 1 end
  if exit.dir == "south" then return nil, 0 end
  if exit.dir == "west" then return dw - 1, nil end
  return 0, nil
end

-- Can a player standing in region `reg` on `id` USE this exit?
--
-- A warp's own cell is a hole, so it is never inside a region: what matters is
-- whether the region touches it.  A connection is usable if the region reaches
-- any cell of that border.
local function exitReachable(id, exit, reg)
  local def = maps[id]
  if exit.kind == "warp" then
    if reg[exit.y * 4096 + exit.x] then return true end
    for _, d in ipairs({ { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }) do
      if reg[(exit.y + d[2]) * 4096 + (exit.x + d[1])] then return true end
    end
    return false
  end
  for _, c in ipairs(borderCells(def, exit.dir)) do
    if reg[c[2] * 4096 + c[1]] then return true end
  end
  return false
end

-- Every distinct standing region of a map, keyed by a representative cell.
--
-- `cells` is the strongly connected component (mutual reachability -- what
-- "standing in this region" means), `forward` its full forward closure (what
-- a player standing there can get to, one-way drains included).  Exits are
-- judged over `forward`; landings are matched against `cells`.
local function regionsOf(id)
  local def = maps[id]
  local seen, out = {}, {}
  local w, h = def.width * 2, def.height * 2
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      local k = y * 4096 + x
      if not seen[k] and passable(def, x, y) then
        local comp = scc(def, x, y)
        for rk in pairs(comp) do seen[rk] = true end
        out[#out + 1] = { x = x, y = y, cells = comp,
                          forward = region(def, x, y) }
      end
    end
  end
  return out
end

-- ---------------------------------------------------------------------------
-- commands
-- ---------------------------------------------------------------------------

-- The region graph, in memory.  `graph` prints it and `path` searches it, so
-- the tool's answer and the bot's plan cannot drift apart.
local function buildGraph()
  local ids = {}
  for id in pairs(maps) do ids[#ids + 1] = id end
  table.sort(ids)

  local regions = {}
  for _, id in ipairs(ids) do regions[id] = regionsOf(id) end

  local function regionsAt(id, x, y)
    local out, seen = {}, {}
    local function add(cx, cy)
      for index, r in ipairs(regions[id] or {}) do
        if r.cells[cy * 4096 + cx] and not seen[index] then
          seen[index] = true
          out[#out + 1] = index
        end
      end
    end
    add(x, y)
    if #out == 0 then
      for _, d in ipairs({ { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }) do
        add(x + d[1], y + d[2])
      end
    end
    return out
  end

  local graph = {}
  for _, id in ipairs(ids) do
    local list = {}
    for _, r in ipairs(regions[id]) do
      local size = 0
      for _ in pairs(r.cells) do size = size + 1 end
      local links = {}
      for _, e in ipairs(exitsOf(id)) do
        if exitReachable(id, e, r.forward) then
          local landings = {}
          if e.kind == "warp" then
            local lx, ly = landingOf(id, e)
            if lx and ly then landings = regionsAt(e.to, lx, ly) end
          else
            local destDef = maps[e.to]
            local destW, destH = destDef.width * 2, destDef.height * 2
            local offset = (e.offset or 0) * 2
            local seen = {}
            for _, c in ipairs(borderCells(maps[id], e.dir)) do
              if r.forward[c[2] * 4096 + c[1]] then
                local lx, ly
                if e.dir == "north" then
                  lx, ly = c[1] - offset, destH - 1
                elseif e.dir == "south" then
                  lx, ly = c[1] - offset, 0
                elseif e.dir == "west" then
                  lx, ly = destW - 1, c[2] - offset
                else
                  lx, ly = 0, c[2] - offset
                end
                lx = math.max(0, math.min(destW - 1, lx))
                ly = math.max(0, math.min(destH - 1, ly))
                for _, k in ipairs(regionsAt(e.to, lx, ly)) do
                  if not seen[k] then
                    seen[k] = true
                    landings[#landings + 1] = k
                  end
                end
              end
            end
          end
          for _, k in ipairs(landings) do
            if e.kind == "warp" then
              links[#links + 1] = { k = "w", i = e.index, x = e.x, y = e.y,
                                    to = e.to, r = k }
            else
              links[#links + 1] = { k = "e", d = e.dir, to = e.to, r = k }
            end
          end
        end
      end
      list[#list + 1] = { x = r.x, y = r.y, size = size, exits = links }
    end
    if #list > 0 then graph[id] = list end
  end
  return graph, ids
end

local cmd = arg[1]

local function requireMap(id)
  if not maps[id] then
    io.stderr:write(("no such map: %s\n"):format(tostring(id)))
    os.exit(1)
  end
  return maps[id]
end

if cmd == "map" then
  local id = arg[2]
  local def = requireMap(id)
  print(("%s  %dx%d blocks (%dx%d cells)  tileset %s")
    :format(id, def.width, def.height, def.width * 2, def.height * 2,
            tostring(def.tileset)))
  print("connections:")
  for dir, conn in pairs(def.connections or {}) do
    local cells = borderCells(def, dir)
    print(("  %-6s -> %-28s offset %-4d  %d walkable border cells")
      :format(dir, tostring(conn.mapId), conn.offset or 0, #cells))
  end
  print("warps:")
  for i, w in ipairs(def.warps or {}) do
    print(("  %2d (%3d,%3d) -> %-28s warp %s")
      :format(i, w.x, w.y, tostring(w.destMap), tostring(w.destWarp)))
  end
  local regs = regionsOf(id)
  print(("regions: %d"):format(#regs))
  for i, r in ipairs(regs) do
    local n = 0
    for _ in pairs(r.cells) do n = n + 1 end
    local names = {}
    for _, e in ipairs(exitsOf(id)) do
      if exitReachable(id, e, r.forward) then
        names[#names + 1] = (e.kind == "warp"
          and ("w%d->%s"):format(e.index, e.to)
          or ("%s->%s"):format(e.dir, e.to))
      end
    end
    print(("  region %d from (%d,%d): %4d cells, exits: %s")
      :format(i, r.x, r.y, n,
              #names > 0 and table.concat(names, " ") or "(none)"))
  end

elseif cmd == "reach" then
  local id, x, y = arg[2], tonumber(arg[3]), tonumber(arg[4])
  local def = requireMap(id)
  local reg = region(def, x, y)
  local n = 0
  for _ in pairs(reg) do n = n + 1 end
  print(("from (%d,%d) on %s: %d reachable cells"):format(x, y, id, n))
  for _, e in ipairs(exitsOf(id)) do
    local ok = exitReachable(id, e, reg)
    print(("  %-4s %-30s %s")
      :format(ok and "ok" or "NO",
              e.kind == "warp"
                and ("warp %d (%d,%d) -> %s"):format(e.index, e.x, e.y, e.to)
                or ("%s edge -> %s"):format(e.dir, e.to),
              ""))
  end

elseif cmd == "exits" then
  local id = arg[2]
  requireMap(id)
  for _, e in ipairs(exitsOf(id)) do
    if e.kind == "warp" then
      print(("warp %2d (%3d,%3d) -> %s"):format(e.index, e.x, e.y, e.to))
    else
      print(("%-6s edge      -> %s (offset %d, %d walkable border cells)")
        :format(e.dir, e.to, e.offset, #borderCells(maps[id], e.dir)))
    end
  end

elseif cmd == "path" then
  -- Shortest walkable path over (map, region) nodes.  This is what the bot's
  -- travel SHOULD find; a discrepancy is a planner bug, not a map bug.
  local from, to = arg[2], arg[3]
  requireMap(from); requireMap(to)
  local startDef = maps[from]
  local startCell
  if arg[4] and arg[5] then
    startCell = { tonumber(arg[4]), tonumber(arg[5]) }
  else
    local w = (startDef.warps or {})[1]
    startCell = w and { w.x, w.y } or { 0, 0 }
  end

  -- Node identity: map id + a canonical cell of the region we are standing in.
  local regionCache = {}
  local function regionAt(id, x, y)
    local key = ("%s#%d,%d"):format(id, x, y)
    if regionCache[key] then return regionCache[key] end
    local reg = region(maps[id], x, y)
    regionCache[key] = reg
    return reg
  end
  local function canon(id, reg)
    local best
    for k in pairs(reg) do if not best or k < best then best = k end end
    return ("%s@%s"):format(id, tostring(best))
  end

  local startReg = regionAt(from, startCell[1], startCell[2])
  local startKey = canon(from, startReg)
  local dist = { [startKey] = 0 }
  local prev = {}
  local queue = { { id = from, reg = startReg, key = startKey, x = startCell[1],
                    y = startCell[2] } }
  local head = 1
  local found
  while head <= #queue do
    local node = queue[head]; head = head + 1
    if node.id == to then found = node break end
    for _, e in ipairs(exitsOf(node.id)) do
      if exitReachable(node.id, e, node.reg) then
        -- Where the exit puts us.  A warp names one cell.  A CONNECTION is a
        -- strip, not a cell, and which cell you land on is decided by where
        -- along the border you crossed -- so every region that touches the far
        -- border is a landing this exit can produce.  Modelling it as a single
        -- cell was wrong in a way that mattered: Azalea Town's east border is
        -- touched by two regions, one of them a 27-cell pocket with no exit but
        -- the way back, and picking that one made the whole of Azalea look
        -- unreachable from Route 33.
        local landings = {}
        local lx, ly = landingOf(node.id, e)
        if lx and ly then
          landings[#landings + 1] = { lx, ly }
        else
          local opposite = ({ north = "south", south = "north",
                              west = "east", east = "west" })[e.dir]
          for _, c in ipairs(borderCells(maps[e.to], opposite)) do
            landings[#landings + 1] = c
          end
        end
        for _, c in ipairs(landings) do
          -- floorAt, not passable: a warp's landing is usually ON the far
          -- warp's own tile (a door mat), and `passable` calls every warp
          -- tile a hole -- which silently dropped every door landing and made
          -- `path` report NO ROUTE into any interior.  The region fill from a
          -- warp cell expands through its standable neighbours, so seeding on
          -- the mat is fine.
          if floorAt(maps[e.to], c[1], c[2]) then
            local reg = regionAt(e.to, c[1], c[2])
            local key = canon(e.to, reg)
            if dist[key] == nil then
              dist[key] = dist[node.key] + 1
              prev[key] = { node = node, exit = e }
              queue[#queue + 1] = { id = e.to, reg = reg, key = key,
                                    x = c[1], y = c[2] }
            end
          end
        end
      end
    end
  end

  if not found then
    print(("NO WALKABLE ROUTE %s -> %s%s")
      :format(from, to, SURF and " (even with surf)" or " (try --surf)"))
    os.exit(2)
  end
  local chain = {}
  local node = found
  while prev[node.key] do
    local step = prev[node.key]
    table.insert(chain, 1, { from = step.node.id, exit = step.exit })
    node = step.node
  end
  print(("%s -> %s : %d hops%s")
    :format(from, to, #chain, SURF and " (surf allowed)" or ""))
  for i, hop in ipairs(chain) do
    local e = hop.exit
    print(("  %2d %-30s %s"):format(i, hop.from,
      e.kind == "warp" and ("warp %d (%d,%d) -> %s"):format(e.index, e.x, e.y, e.to)
                       or ("%s edge -> %s"):format(e.dir, e.to)))
  end

elseif cmd == "graph" then
  -- Emit the region graph the bot plans over.
  --
  --   luajit tools/goldwalk/mapgraph.lua graph > tests/drivers/gold/map_regions.lua
  --
  -- A node is (map, region): a map's walkable cells split by whatever the
  -- player cannot walk across, including its own warp tiles.  That split is the
  -- thing a map-id graph cannot say and the bot kept paying for -- "Route 33
  -- connects west to Azalea Town" is true of one half of Route 33 and false of
  -- the other, and "Azalea Town connects east to Route 33" is true of the town
  -- and of a 27-cell dead end that only looks like the town from outside.
  local graph, ids = buildGraph()
  local out = {}
  out[#out + 1] = "-- GENERATED by tools/goldwalk/mapgraph.lua graph."
  out[#out + 1] = "-- Region-aware map graph for the Gold route bot: see that"
  out[#out + 1] = "-- tool's `graph` command for what a region is and why the"
  out[#out + 1] = "-- bot cannot plan without one.  Regenerate after any change"
  out[#out + 1] = "-- to the extractor's map output."
  out[#out + 1] = "return {"
  for _, id in ipairs(ids) do
    local regs = graph[id]
    if regs then
      out[#out + 1] = ("  [%q] = {"):format(id)
      for _, r in ipairs(regs) do
        local links = {}
        for _, e in ipairs(r.exits) do
          if e.k == "w" then
            links[#links + 1] = ("{k=\"w\",i=%d,x=%d,y=%d,to=%q,r=%d}")
              :format(e.i, e.x, e.y, e.to, e.r)
          else
            links[#links + 1] = ("{k=\"e\",d=%q,to=%q,r=%d}")
              :format(e.d, e.to, e.r)
          end
        end
        out[#out + 1] = ("    { x = %d, y = %d, size = %d, exits = { %s } },")
          :format(r.x, r.y, r.size, table.concat(links, ", "))
      end
      out[#out + 1] = "  },"
    end
  end
  out[#out + 1] = "}"
  print(table.concat(out, "\n"))

elseif cmd == "audit" then
  -- Every connection whose border has no walkable cell on one side: those are
  -- the edges the bot will try, fail, and price -- and each one is either a map
  -- the player is meant to reach through a gate instead, or an extractor bug.
  local bad = 0
  local ids = {}
  for id in pairs(maps) do ids[#ids + 1] = id end
  table.sort(ids)
  for _, id in ipairs(ids) do
    local def = maps[id]
    for dir, conn in pairs(def.connections or {}) do
      local cells = borderCells(def, dir)
      if #cells == 0 then
        bad = bad + 1
        print(("%-30s %-6s -> %-30s NO walkable border cell")
          :format(id, dir, tostring(conn.mapId)))
      end
    end
  end
  print(("%d connections have an unwalkable near border"):format(bad))

else
  print("usage: mapgraph.lua {map|reach|exits|path|audit} [args] [--surf]")
end
