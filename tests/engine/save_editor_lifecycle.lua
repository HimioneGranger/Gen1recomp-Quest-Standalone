-- ROM-free save-editor lifecycle and mobile-host guards.

package.path = "./?.lua;./?/init.lua;./tools/save-editor/?.lua;" .. package.path

local T = require("tests.harness")
love = love or require("tests.love_stub")

-- Data unload must remove generated values and their module cache entries.
do
  local Data = require("src.core.Data")
  local fake = {
    stable = true,
    constants = { stale = true },
    maps = { stale = true },
    modRegistry = { stale = true },
  }
  fake._pristineKeys = {
    stable = true, constants = true, maps = true, _pristineKeys = true,
  }
  package.loaded["data.generated.constants"] = fake.constants
  package.loaded["data.generated.maps"] = fake.maps

  Data.unloadGenerated(fake)

  T.eq(fake.stable, true, "editor unload keeps non-generated state")
  T.eq(fake.modRegistry, nil, "editor unload removes mod-added state")
  T.eq(fake.constants, nil, "editor unload removes generated constants")
  T.eq(fake.maps, nil, "editor unload removes generated maps")
  T.eq(fake._pristineKeys, nil, "editor unload resets the pristine marker")
  T.eq(package.loaded["data.generated.constants"], nil,
    "editor unload evicts generated module cache")
end

-- Mobile Lua hosts can omit io.popen. Event scraping must then return an
-- empty list, not terminate the editor.
do
  local Catalog = require("Catalog")
  local savedPopen = io.popen
  local savedFs = love.filesystem
  io.popen = nil
  love.filesystem = { getInfo = function() return nil end }

  local events = Catalog.scrapeEvents("missing", nil)
  T.eq(#events, 0, "event scrape tolerates a host without io.popen")
  events = Catalog.scrapeEvents(nil, nil, function() return nil end)
  T.eq(#events, 0, "event scrape tolerates no base directory or file list")

  io.popen = savedPopen
  love.filesystem = savedFs
end

-- A catalog can contain a move that the active data set does not define.
-- Cycle past it and refuse cleanly when no defined move exists.
do
  local Ops = require("Ops")
  local mon = { moves = {} }
  local state = {
    cat = { moves = { "MISSING", "TACKLE" } },
    data = { moves = { TACKLE = { pp = 35 } } },
    dirty = false,
  }
  T.check(Ops.cycleMove(state, mon, 1), "cycleMove finds the next defined move")
  T.eq(mon.moves[1].id, "TACKLE", "cycleMove skips an undefined catalog move")

  local none = { cat = { moves = { "MISSING" } }, data = { moves = {} } }
  T.eq(Ops.cycleMove(none, { moves = {} }, 1), false,
    "cycleMove refuses when no catalog move is defined")
  T.eq(Ops.cycleMove({ cat = { moves = {} } }, mon, 1), false,
    "cycleMove tolerates an empty catalog")
end

-- Keep the integration seam in main.lua and the cross-version reload guard
-- in App.lua under a ROM-free source contract.
do
  local function read(path)
    local file = assert(io.open(path, "rb"))
    local body = file:read("*a")
    file:close()
    return body
  end
  local main = read("main.lua")
  T.check(main:find('name:find("save%-editor")', 1, true) ~= nil,
    "launcher close evicts save-editor modules")
  local app = read("tools/save-editor/App.lua")
  T.check(app:find("not mods or App.dataVersion ~= opts.version", 1, true) ~= nil,
    "editor reloads data when the selected version changes")
end

T.finish("save_editor_lifecycle")
