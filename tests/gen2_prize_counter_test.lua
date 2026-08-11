-- The Game Corner's prize counters are MAP SCRIPT, not a screen.
--
--   luajit tests/gen2_prize_counter_test.lua   (ROM-free; the cache half SKIPs
--                                               without a gold cache)
--
-- GoldenrodGameCornerTMVendorScript and GoldenrodGameCornerPrizeMonVendorScript
-- (pokegold maps/GoldenrodGameCorner.asm), and their two Celadon twins, are
-- `opentext` / `checkitem` / `loadmenu` / `verticalmenu` / `checkcoins` /
-- `giveitem` / `givepoke` / `takecoins` and nothing else -- every one of which
-- src/script/gen2/Vm.lua already runs.  So talking to a vendor runs the
-- extracted bytecode, and no engine screen is reached: an id in
-- src/ui/Screens.lua for one would only ever have been resolved by a mod
-- replacing a screen the game never pushes.
--
-- What this pins is the reachable path (the real script, driven to a real
-- transaction with no unknown opcodes left over) and the registry (no id for
-- something the VM owns).
package.path = "./?.lua;./?/init.lua;" .. package.path

local S = require("tests.harness").suite("gen2 prize counter")
local check, eq = S.check, S.eq

love = require("tests.love_stub")

local Screens = require("src.ui.Screens")
local Vm = require("src.script.gen2.Vm")
local Events = require("src.world.gen2.Events")

-- ---- the registry ---------------------------------------------------------
do
  local registered = {}
  for _, id in ipairs(Screens.GEN2_IDS) do registered[id] = true end
  eq(registered.Gen2PrizeMenu, nil,
    "no Gen2PrizeMenu id: the prize counters are script")
  eq(registered.Gen2IntroStub, nil,
    "and no Gen2IntroStub: Gen2GoldSilverIntro is the intro")
  check(registered.Gen2SlotMachine,
    "the slot machine next door IS an engine screen and keeps its id")
  check(registered.Gen2CardFlip, "so does card flip")
  check(registered.Gen2GoldSilverIntro, "and so does the real intro")
  -- Every remaining id has to resolve, or the list is worse than the two rows
  -- taken out of it.
  local missing = {}
  for _, id in ipairs(Screens.GEN2_IDS) do
    local ok = pcall(Screens.get, {}, id)
    if not ok then missing[#missing + 1] = id end
  end
  eq(#missing, 0, "every id still on the list resolves to a module")
  Screens.invalidate()
end

-- ---- the counter, driven ---------------------------------------------------
--
-- The transaction arm of a TM counter, in the cart's own order: the coin check
-- first, then the question, then the PACK, and only then the coins actually
-- come off.  Built as a command list rather than lifted out of the cache so
-- this half runs with no gold cache at all; the cache half below asserts that
-- the extracted script is the same shape.
do
  local HAVE_MORE, HAVE_LESS = 0, 2
  local TM_THUNDER, PRICE = 0xd4, 5500

  local function vendorScript()
    return {
      generation = 2,
      ["s:tm"] = {
        { op = "checkcoins", args = { PRICE % 256, math.floor(PRICE / 256) } },
        { op = "ifequal", value = HAVE_LESS, script = "s:broke" },
        { op = "yesorno" },
        { op = "iffalse", script = "s:cancel" },
        { op = "giveitem", item = TM_THUNDER, quantity = 1 },
        { op = "iffalse", script = "s:noroom" },
        { op = "takecoins", args = { PRICE % 256, math.floor(PRICE / 256) } },
        { op = "end" },
      },
      ["s:broke"] = { { op = "end" } },
      ["s:cancel"] = { { op = "end" } },
      ["s:noroom"] = { { op = "end" } },
    }
  end

  local function run(opts)
    local state = { coins = opts.coins, given = nil, arm = nil }
    local vm = Vm.new(vendorScript(), {}, Events.new(), {
      showText = function(_, onDone) if onDone then onDone() end end,
      yesorno = function(onChoose) onChoose(opts.yes ~= false) end,
      getCoins = function() return state.coins end,
      setCoins = function(n) state.coins = n end,
      giveItem = function(item, qty)
        if opts.fullPack then return false end
        state.given = { item = item, qty = qty }
        return true
      end,
    })
    vm:start("s:tm")
    for _ = 1, 40 do vm:update() end
    state.running = vm:running()
    state.unknown = vm.unknownOps
    return state
  end

  local bought = run({ coins = 6000 })
  eq(bought.coins, 6000 - PRICE, "the counter takes the price in coins")
  eq(bought.given and bought.given.item, TM_THUNDER, "and hands over the TM")
  check(not bought.running, "with the script run to its end")
  eq(next(bought.unknown), nil, "and no opcode fell through the VM")

  local broke = run({ coins = 100 })
  eq(broke.coins, 100, "HAVE_LESS takes the not-enough-coins arm")
  eq(broke.given, nil, "and nothing is handed over")

  local said = run({ coins = 6000, yes = false })
  eq(said.coins, 6000, "answering NO cancels before the coins move")
  eq(said.given, nil, "and before the item does")

  -- `giveitem / iffalse NoRoomForPrize`: a full PACK is discovered AFTER the
  -- question, which is the item counter's own order and the reason the coins
  -- are still there.
  local full = run({ coins = 6000, fullPack = true })
  eq(full.coins, 6000, "a full PACK costs nothing")
  eq(full.given, nil, "and gives nothing")
end

-- ---- the extracted scripts -------------------------------------------------
do
  local cache = os.getenv("GOLD_CACHE")
  if not cache then
    local home = os.getenv("HOME") or ""
    cache = home .. "/Library/Application Support/LOVE/gold-dev/gold"
  end
  local mapChunk = loadfile(cache .. "/data/generated/maps.lua")
  local scriptChunk = loadfile(cache .. "/data/generated/scripts.lua")
  if not (mapChunk and scriptChunk) then
    check(true, "no gold cache: the extracted vendor scripts (SKIP)")
  else
    local maps, scripts = mapChunk(), scriptChunk()
    local room = maps.GOLDENROD_GAME_CORNER
    check(room ~= nil, "the cache carries GOLDENROD_GAME_CORNER")

    -- The two vendors, found the way a player finds them: an object whose own
    -- script opens a menu and checks the coin case.
    local vendors = {}
    for _, obj in ipairs((room or {}).objects or {}) do
      local cmds = obj.scriptKey and scripts[obj.scriptKey]
      if type(cmds) == "table" then
        local ops = {}
        for _, cmd in ipairs(cmds) do ops[cmd.op] = true end
        if ops.loadmenu and ops.verticalmenu and ops.checkitem then
          vendors[#vendors + 1] = { key = obj.scriptKey, cmds = cmds }
        end
      end
    end
    eq(#vendors, 2, "two prize counters stand in the room")

    -- Follow every arm the counters jump to, so the transaction opcodes are
    -- asserted where they actually live rather than only in the entry script.
    local reached, queue = {}, {}
    for _, vendor in ipairs(vendors) do queue[#queue + 1] = vendor.key end
    local ops = {}
    while #queue > 0 do
      local key = table.remove(queue)
      if not reached[key] then
        reached[key] = true
        for _, cmd in ipairs(scripts[key] or {}) do
          ops[cmd.op] = (ops[cmd.op] or 0) + 1
          local target = cmd.script or cmd.target
          if type(target) == "string" and scripts[target] then
            queue[#queue + 1] = target
          end
        end
      end
    end
    for _, op in ipairs({ "loadmenu", "verticalmenu", "checkcoins", "takecoins",
        "giveitem", "givepoke", "yesorno", "checkitem" }) do
      check((ops[op] or 0) > 0,
        "the extracted counters use " .. op .. ", which the VM runs")
    end

    -- And nothing in them reached the extractor's own failure rows, which is
    -- what an opcode the VM would have to hand to a screen would look like.
    eq(ops.unknown, nil, "with no unknown command in any arm")
    eq(ops.truncated, nil, "and nothing truncated")
  end
end

S.finish()
