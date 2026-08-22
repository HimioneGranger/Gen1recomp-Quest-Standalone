-- ROM-free stale-import palette guard from upstream
-- f5b8b6c85fb20b91de53f5f8ab274a3c799fb287.
--   luajit tests/engine/palette_missing_table.lua

package.path = "./?.lua;./?/init.lua;" .. package.path
if not _G.love then _G.love = require("tests.love_stub") end

local T = require("tests.harness").suite("missing palette table")
local check, eq = T.check, T.eq
local GameVersion = require("src.core.GameVersion")
local PaletteFX = require("src.render.PaletteFX")

local oldMode, oldVersion = PaletteFX.mode, GameVersion.get()
PaletteFX.setMode("gbc")
GameVersion.set("red")

local ok, result = pcall(PaletteFX.pal, { palettes = {} }, "MEWMON")
check(ok, "a stale palette pack without a named table does not crash")
eq(result, nil, "a stale palette pack without the requested name returns nil")

local named = { { 255, 255, 255 }, { 170, 170, 170 },
                { 85, 85, 85 }, { 0, 0, 0 } }
eq(PaletteFX.pal({ palettes = { palettes = { MEWMON = named } } }, "MEWMON"),
  named, "a complete palette pack still returns the named palette")

GameVersion.set(oldVersion)
PaletteFX.setMode(oldMode)
T.finish()
