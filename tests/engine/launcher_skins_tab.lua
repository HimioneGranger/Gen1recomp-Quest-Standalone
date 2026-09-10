-- Launcher SKINS tab (#1386): the tab next to Find that lists skins, imports
-- a dropped .zip and opens the desktop Skin Studio.  The rendered panel is
-- exercised by tests/drivers/launcher_skins_tab_shot.lua; this pins the
-- archive installer and the launcher wiring around it.
--   luajit tests/engine/launcher_skins_tab.lua

package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local T = require("tests.harness")
local check, eq = T.check, T.eq

local TouchSkin = require("src.core.TouchSkin")

local function read(path)
  local f = assert(io.open(path, "r"))
  local src = f:read("*a")
  f:close()
  return src
end

-- ------------------------------------------------------ archive installer

eq(select(1, TouchSkin.installArchive("skin.zip", nil)), nil,
   "an empty archive is refused")
eq(select(1, TouchSkin.installArchive("skin.zip", "")), nil,
   "a zero-byte archive is refused")
eq(select(1, TouchSkin.installArchive("notes.txt", "data")), nil,
   "a non-zip is refused")
eq(select(1, TouchSkin.installArchive("", "data")), nil,
   "a nameless drop is refused")

-- A zip carrying no skin file must not leave a stray archive behind: the
-- list would keep trying to mount it on every visit to the tab.
local junk = "PK\3\4 not really a skin"
local id, err = TouchSkin.installArchive("bogus.zip", junk)
eq(id, nil, "a zip with no skin.lua or .cfg is refused")
check(tostring(err):find("bogus.zip", 1, true) ~= nil,
      "and the error names the file")
eq(love.filesystem.read(TouchSkin.USER_ROOT .. "/bogus.zip"), nil,
   "the rejected archive is cleaned up, not left to fail on every listing")

-- the id a good archive would land under is the file name without .zip
check(TouchSkin.find("bogus") == nil, "a refused archive lists nothing")

-- ------------------------------------------------------- launcher wiring

local view = read("src/import/LauncherView.lua")
local imp = read("src/import/RomImporter.lua")

check(view:find('id = "skins"', 1, true) ~= nil,
      "LauncherView registers a skins tab")
check(view:find("drawSkinGlyph", 1, true) ~= nil,
      "the skins tab draws its own glyph rather than shipping an asset")
-- the tab has to be next to Find, which is what the request was
local findAt = view:find('{ id = "find"', 1, true)
local skinsAt = view:find('{ id = "skins"', 1, true)
check(findAt and skinsAt and skinsAt > findAt,
      "the skins tab sits immediately after Find")
check(view:find("not PlatformProfile.isQuestStandalone()", 1, true) ~= nil,
      "the flat-display skins tab does not alter the Quest launcher")
check(view:find('imp.tab == "skins"', 1, true) ~= nil,
      "the panel dispatch routes the skins tab")
check(view:find("buildSkinsPanel", 1, true) ~= nil, "and a panel builds it")
-- the panel must not offer the studio when the host did not supply it
check(view:find("if imp.onOpenSkinStudio then", 1, true) ~= nil,
      "the Studio button is hidden without a host hook (mobile)")
-- the studio boots a game on Play, so it needs a cartridge, not the tab id
check(view:find("imp.modScope or \"red\"", 1, true) ~= nil,
      "the studio is handed a real game version, never the skins tab id")

check(imp:find('if self.tab == "skins" then', 1, true) ~= nil,
      "a dropped zip on the skins tab installs a skin")
check(imp:find("_installSkinZip", 1, true) ~= nil, "skin zip installer exists")
check(imp:find("_installMod", 1, true) ~= nil,
      "and a zip elsewhere still installs a mod")
check(imp:find('order[#order + 1] = "skins"', 1, true) ~= nil,
      "shoulder-button tab cycling reaches the skins tab")
check(imp:find('id == "skins"', 1, true) ~= nil
    and imp:find("isQuestStandalone()", 1, true) ~= nil,
      "Quest tab switching refuses the flat-display skins route")
local switch = imp:match("function RomImporter:_switchTab%(id%)(.-)\nend")
check(switch and switch:find("_ensureSkins(true)", 1, true) ~= nil,
      "switching to the tab re-reads the skin list")

T.finish("launcher_skins_tab")
