-- #1167: the Ilex Forest hidden Ether and hidden Super Potion.
--   POKEPORT_GAME=gold POKEPORT_TOUCH=0 \
--     POKEPORT_DRIVER=tests/drivers/gold_bug1167_test.lua love .
local Mon = require("src.battle.gen2.Mon")
local HiddenItems = require("src.world.gen2.HiddenItems")

local CASES = {
  { name = "ETHER", x = 27, y = 1, event = 136 },
  { name = "SUPER_POTION", x = 17, y = 7, event = 137 },
  { name = "FULL_HEAL", x = 9, y = 17, event = 138 },
}

local FACE = {
  up = { 0, 1 }, down = { 0, -1 }, left = { 1, 0 }, right = { -1, 0 },
}

return function(game)
  local function wait(n) for _ = 1, n do coroutine.yield() end end
  local function tap(btn)
    table.insert(game.input.pressQueue, btn)
    game.input.state[btn] = true
    coroutine.yield()
    game.input.state[btn] = false
    coroutine.yield()
  end

  wait(30)
  local world = game.world
  game.save.party = { Mon.new(game.data, "PIDGEY", 5) }
  world:setMap("ILEX_FOREST", 9, 18, "up")
  wait(30)
  assert(world.map.id == "ILEX_FOREST", "not in ILEX_FOREST")

  -- what the engine itself thinks it has for this map
  local listed = HiddenItems.unfound(world.map.def, world.events)
  print("[driver] engine hidden items on ILEX_FOREST:")
  for _, row in ipairs(listed) do
    print(("   (%2d,%2d) item=%s flag=%d")
      :format(row.x, row.y, tostring(row.item), row.event))
  end

  local function bagCount(name)
    local n = 0
    for _, row in ipairs((game.save.bag and game.save.bag.items) or {}) do
      if row.item == name or row.id == name then n = n + (row.count or 1) end
    end
    return n
  end

  local bad = 0
  for _, c in ipairs(CASES) do
    local got = false
    for dir, d in pairs(FACE) do
      local sx, sy = c.x + d[1], c.y + d[2]
      if world.map:isWalkable(sx, sy) then
        world:setMap("ILEX_FOREST", sx, sy, dir)
        wait(20)
        world.player.facing = dir
        local before = bagCount(c.name)
        tap("a")
        wait(60)
        for _ = 1, 240 do
          if not world:busy() then break end
          tap("a")
        end
        wait(20)
        if world.events:get(c.event) or bagCount(c.name) > before then
          got = true
          print(("[driver] OK       %-13s at (%2d,%2d) picked up facing %s")
            :format(c.name, c.x, c.y, dir))
          break
        end
      end
    end
    if not got then
      bad = bad + 1
      print(("[driver] MISSING  %-13s at (%2d,%2d)"):format(c.name, c.x, c.y))
    end
  end
  print(("[driver] %s ilex hidden items: %d missing")
    :format(bad == 0 and "PASS" or "FAIL", bad))
end
