-- A boot-time fresh skeleton may request tool storage before the selected save
-- loads. It needs a unique temporary identity, but must not replace the durable
-- identity already bound to that selected save.

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")
love = love or require("tests.love_stub")

local SaveData = require("src.core.SaveData")
local SaveSerializer = require("src.core.SaveSerializer")
local GameVersion = require("src.core.GameVersion")

local realFS = love.filesystem

local function memfs(files)
  return {
    write = function(path, content) files[path] = content return true end,
    read = function(path) return files[path] end,
    remove = function(path) files[path] = nil return true end,
    createDirectory = function() return true end,
    getInfo = function(path)
      if files[path] then return { type = "file" } end
      local prefix = path .. "/"
      for key in pairs(files) do
        if key:sub(1, #prefix) == prefix then return { type = "directory" } end
      end
      return nil
    end,
    getDirectoryItems = function(path)
      local prefix, seen, out = path .. "/", {}, {}
      for key in pairs(files) do
        if key:sub(1, #prefix) == prefix then
          local child = key:sub(#prefix + 1):match("^[^/]+")
          if child and not seen[child] then
            seen[child] = true
            out[#out + 1] = child
          end
        end
      end
      table.sort(out)
      return out
    end,
  }
end

local files = {}
love.filesystem = memfs(files)
SaveData.resetSlotState()
GameVersion.set("red")

local existing = SaveData.newGame({ version = "red" })
local existingId = SaveData.ensurePlaythroughId(existing)
T.check(SaveData.save(existing), "the selected playthrough is saved")

SaveData.resetSlotState()
local skeleton = SaveData.newGame({ version = "red" })
local skeletonId = SaveData.ensurePlaythroughId(skeleton)
T.neq(skeletonId, existingId,
  "the fresh skeleton receives a distinct temporary identity")

local options = SaveSerializer.decode(files["options.lua"] or "")
local durableId = options and options.playthroughIds
  and options.playthroughIds.red and options.playthroughIds.red.slot1
T.eq(durableId, existingId,
  "the fresh skeleton does not replace the selected save binding")

local selectedId = SaveData.selectedPlaythroughId(
  { version = "red", meta = {} }, love.filesystem)
T.eq(selectedId, existingId,
  "selected playthrough lookup still resolves the saved identity")

love.filesystem = realFS
SaveData.resetSlotState()
GameVersion.set("red")

T.finish("fresh playthrough binding")
