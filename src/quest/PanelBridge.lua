-- Copies the finished LÖVE window into the native Quest OpenXR quad.
-- Inert everywhere except an Android build exporting the native bridge.

local PanelBridge = {}
local C
local elapsed = 0
local bit = require("bit")

do
  if love.system.getOS() ~= "Android" then return PanelBridge end
  local ok, ffi = pcall(require, "ffi")
  if not ok then return PanelBridge end
  pcall(ffi.cdef, [[
    void questxr_request_panel_capture(
      float focus_x, float focus_y, float focus_width, float focus_height);
    int questxr_capture_bound_panel_gl(int width, int height,
      float focus_x, float focus_y, float focus_width, float focus_height);
    void questxr_log(const char *message);
    unsigned int questxr_poll_input(void);
    unsigned int questxr_poll_held_input(void);
  ]])
  local libraries = {
    function() return ffi.C end,
    function() return ffi.load("love") end,
    function() return ffi.load("liblove.so") end,
  }
  for _, resolve in ipairs(libraries) do
    local okLib, lib = pcall(resolve)
    if okLib and lib and pcall(function()
        return lib.questxr_request_panel_capture, lib.questxr_poll_input
      end) then
      C = lib
      break
    end
  end
  if C then
    _G.QUEST_PANEL_ACTIVE = true
    _G.QUEST_XR_LOG = function(message)
      pcall(C.questxr_log, tostring(message))
    end
    pcall(C.questxr_log, "Lua fixed-buffer panel bridge linked")
  end

  -- Quest builds carry Android/OpenXR replacements for the platform-bound VR
  -- modules beside the game.  Dramaless owns its renderer, asynchronous mesher,
  -- quality policy, assets, and settings; do not overwrite those with files
  -- from the older Dramatic Shape integration.
  local replacement = love.filesystem.read("lib/VRXR.lua")
  -- Use the conductor from the Dramaless 1.6.4 base. The older Quest
  -- conductor references later modules (including Diorama.lua) that do not
  -- exist in 1.6.4 and therefore cannot be mixed into this installation.
  local questVR = love.filesystem.read("src/quest/dramaless/VR.lua")
  local questVRGL = love.filesystem.read("lib/VRGL.lua")
  if C then
    -- The conductor and source adapters are shipped by the engine and must be
    -- refreshed even when a packaging mistake omits one of the optional
    -- native-transport companions.  Gating this whole block on VRXR/VRGL left
    -- an old writable VR.lua active, which restored the 12-map preload policy
    -- and silently skipped every mesher adapter.
    local okVR = questVR and love.filesystem.write(
      "mods/DRAMALESS_SHAPE/lib/VR.lua", questVR) or false
    pcall(C.questxr_log, okVR and
      "Dramaless Quest conductor installed" or
      "Dramaless Quest conductor install failed")

    local matchedTransport = replacement and questVRGL
      and replacement:find("questxr_request_launcher_shutdown", 1, true)
    if matchedTransport then
      local okXR = love.filesystem.write(
        "mods/DRAMALESS_SHAPE/lib/VRXR.lua", replacement)
      local okVRGL = love.filesystem.write(
        "mods/DRAMALESS_SHAPE/lib/VRGL.lua", questVRGL)
      pcall(C.questxr_log, okXR and okVRGL and
        "Dramaless Shape matched Quest OpenXR transport installed" or
        "Dramaless Shape matched Quest transport install failed")
    else
      pcall(C.questxr_log,
        "Dramaless matched transport payload unavailable; retained installed transport")
    end

    -- Dramaless 1.6.4 still uploads six complete vertices per terrain quad.
    -- Apply the isolated, source-guarded Quest index adapter to the installed
    -- writable shadow. Kanto First Person can continue patching that normal
    -- Dramaless module afterward; no renderer module is replaced wholesale.
    local okLifetime, lifetimeNote = false, "mesher unavailable"
    local okLifetimePatch, MesherLifetimePatch = pcall(
      require, "src.quest.dramaless.MesherLifetimePatch")
    local okIndexed, indexedNote = false, "mesher unavailable"
    local okPatch, IndexMesherPatch = pcall(
      require, "src.quest.dramaless.IndexMesherPatch")
    local mesherPath = "mods/DRAMALESS_SHAPE/lib/ChunkMesher.lua"
    local mesher = love.filesystem.read(mesherPath)
    if okLifetimePatch and MesherLifetimePatch and mesher then
      local bounded, note = MesherLifetimePatch.apply(mesher)
      lifetimeNote = note or "unknown"
      if bounded then
        okLifetime = bounded == mesher
          or love.filesystem.write(mesherPath, bounded)
        if okLifetime then mesher = bounded end
      end
    end
    if okPatch and IndexMesherPatch and mesher then
      local indexed, note = IndexMesherPatch.apply(mesher)
      indexedNote = note or "unknown"
      if indexed then
        okIndexed = indexed == mesher
          or love.filesystem.write(mesherPath, indexed)
      end
    end
    local okStreamed, streamedNote = false, "VoxelScene unavailable"
    local okStreamPatch, NeighborStreamPatch = pcall(
      require, "src.quest.dramaless.NeighborStreamPatch")
    local scenePath = "mods/DRAMALESS_SHAPE/lib/VoxelScene.lua"
    local sceneSource = love.filesystem.read(scenePath)
    if okStreamPatch and NeighborStreamPatch and sceneSource then
      local streamed, note = NeighborStreamPatch.apply(sceneSource)
      streamedNote = note or "unknown"
      if streamed then
        okStreamed = streamed == sceneSource
          or love.filesystem.write(scenePath, streamed)
      end
    end
    pcall(C.questxr_log, okLifetime
      and ("Dramaless " .. lifetimeNote)
      or ("Dramaless lifetime seam skipped: " .. tostring(lifetimeNote)))
    pcall(C.questxr_log, okIndexed
      and ("Dramaless " .. indexedNote .. " mesher ready")
      or ("Dramaless indexed mesher skipped: " .. tostring(indexedNote)))
    pcall(C.questxr_log, okStreamed
      and ("Dramaless " .. streamedNote .. " neighbour stream ready")
      or ("Dramaless neighbour stream skipped: " .. tostring(streamedNote)))
  end
end

local function focusRect()
  if not rawget(_G, "QUEST_LAUNCHER_ACTIVE") then
    return -1, -1, 0, 0
  end
  local width, height = love.graphics.getDimensions()
  local okKit, Kit = pcall(require, "src.ui.kit.Kit")
  local target
  if okKit and Kit and Kit.focusId then
    for i = 1, Kit._navN or 0 do
      local candidate = Kit._nav[i]
      if candidate and candidate.id == Kit.focusId then
        target = candidate
        break
      end
    end
  end
  if not target then return -1, -1, 0, 0 end
  local pad = 6
  return math.max(0, target.x - pad) / width,
    math.max(0, height - target.y - target.h - pad) / height,
    math.min(width, target.w + pad * 2) / width,
    math.min(height, target.h + pad * 2) / height
end

local heldDirections = {}

local function updateGameplayDirections()
  if rawget(_G, "QUEST_LAUNCHER_ACTIVE") then return end
  local ok, held = pcall(C.questxr_poll_held_input)
  if not ok then return end
  held = tonumber(held) or 0
  for _, binding in ipairs({
    { 1, "up" }, { 2, "down" }, { 4, "left" }, { 8, "right" },
  }) do
    local down = bit.band(held, binding[1]) ~= 0
    local key = binding[2]
    if down and not heldDirections[key] then
      heldDirections[key] = true
      love.keypressed(key, key, false)
    elseif not down and heldDirections[key] then
      heldDirections[key] = nil
      love.keyreleased(key, key)
    end
  end
end

function PanelBridge.update(dt)
  elapsed = elapsed + (dt or 0)
  if not C then return end
  updateGameplayDirections()
  local ok, events = pcall(C.questxr_poll_input)
  if not ok then
    pcall(C.questxr_log, "Lua Quest input poll failed")
    return
  end
  events = tonumber(events)
  if not events or events == 0 then return end
  pcall(C.questxr_log, "Lua dispatching Quest input")
  local keys = {
    { 1, "up" }, { 2, "down" }, { 4, "left" }, { 8, "right" },
    { 16, "return" }, { 32, "escape" },
  }
  for _, binding in ipairs(keys) do
    if bit.band(events, binding[1]) ~= 0 then
      local key = binding[2]
      if key == "up" or key == "down" or key == "left" or key == "right" then
        if not rawget(_G, "QUEST_LAUNCHER_ACTIVE") then
          -- Gameplay directions are level-triggered by poll_held_input above.
          -- The event bit remains launcher-only so walking can stay held.
        else
        -- Native input arrives during update, after the previous immediate-mode
        -- frame has already built a complete navigation graph. Resolve against
        -- that graph now so the visible ring changes on the very next draw.
        local okKit, Kit = pcall(require, "src.ui.kit.Kit")
        if okKit and Kit then
          local before = tostring(Kit.focusId)
          Kit.navigate(key)
          Kit._resolveNav()
          pcall(C.questxr_log, ("Quest focus %s: %s -> %s"):format(
            key, before, tostring(Kit.focusId)))
        else
          love.keypressed(key, key, false)
          love.keyreleased(key, key)
        end
        end
      else
        local handled = false
        if key == "return" then
          local okKit, Kit = pcall(require, "src.ui.kit.Kit")
          if okKit and Kit then
            pcall(C.questxr_log, "Quest confirm focus=" .. tostring(Kit.focusId))
          end
          local handler = rawget(_G, "QUEST_LAUNCHER_CONFIRM")
          if type(handler) == "function" then
            handled = handler() and true or false
            pcall(C.questxr_log, "Quest owner confirm handled=" .. tostring(handled))
          end
        end
        if not handled then
          -- Native OpenXR polling reports rising-edge events, not SDL key-up
          -- events. Complete the synthetic tap immediately. Input keeps the
          -- queued edge for the next fixed step while clearing the held source,
          -- allowing the next Quest press to become a fresh A/B/direction edge.
          love.keypressed(key, key, false)
          love.keyreleased(key, key)
        end
      end
    end
  end
end

function PanelBridge.capture()
  if not C then return end
  local fx, fy, fw, fh = focusRect()
  if elapsed < (1 / 15) then return end
  elapsed = 0
  -- LÖVE fulfills this request from Graphics::present after it has flushed
  -- every UI batch, ended the render pass, and bound the completed framebuffer.
  pcall(C.questxr_request_panel_capture, fx, fy, fw, fh)
end

function PanelBridge.captureBound(width, height)
  if not C then return end
  elapsed = 0
  local fx, fy, fw, fh = focusRect()
  pcall(C.questxr_capture_bound_panel_gl,
    width, height, fx, fy, fw, fh)
end

return PanelBridge
