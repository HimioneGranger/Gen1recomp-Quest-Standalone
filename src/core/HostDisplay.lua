-- Optional native-host display lifecycle.
--
-- The engine always owns simulation and drawing. A packaged host may install
-- one backend to observe per-frame updates and prepare/finalize a render target
-- around an otherwise unchanged draw. With no backend installed every method
-- is a no-op, which is the normal desktop and mobile path.
--
-- Backend methods are optional:
--   backend:update(dt)
--   backend:beginFrame(kind, subject)
--   backend:endFrame(kind, subject)
--
-- `kind` is "editor", "touch_editor", "launcher", or "game". `subject` is
-- the object whose existing draw method runs between beginFrame and endFrame.
local HostDisplay = { API_VERSION = 1 }

local backend

function HostDisplay.installPackagedBackend()
  local ok, packaged = pcall(require, "src.host.PackagedDisplay")
  if not ok or type(packaged) ~= "table"
      or type(packaged.detect) ~= "function" then
    return false
  end
  local detected = packaged.detect()
  if detected == nil then return false end
  HostDisplay.setBackend(detected)
  return true
end

function HostDisplay.setBackend(value)
  if value ~= nil and type(value) ~= "table" then
    error("host display backend must be a table or nil", 2)
  end
  if value and value.apiVersion ~= HostDisplay.API_VERSION then
    error("unsupported host display API version", 2)
  end
  backend = value
end

function HostDisplay.update(dt)
  local fn = backend and backend.update
  if fn then return fn(backend, dt) end
end

function HostDisplay.beginFrame(kind, subject)
  local fn = backend and backend.beginFrame
  if fn then return fn(backend, kind, subject) end
end

function HostDisplay.endFrame(kind, subject)
  local fn = backend and backend.endFrame
  if fn then return fn(backend, kind, subject) end
end

function HostDisplay.cancelFrame(kind, subject, reason)
  local fn = backend and backend.cancelFrame
  if fn then return fn(backend, kind, subject, reason) end
end

-- Bracket one draw with exactly one end-or-cancel callback. A backend that
-- starts native work and then throws is still offered the cleanup path.
function HostDisplay.render(kind, subject, draw)
  if type(draw) ~= "function" then
    error("host display draw must be a function", 2)
  end
  local ok, result = xpcall(function()
    HostDisplay.beginFrame(kind, subject)
    return draw()
  end, debug.traceback)
  if not ok then
    pcall(HostDisplay.cancelFrame, kind, subject, result)
    error(result, 0)
  end
  local ended, endResult = xpcall(function()
    return HostDisplay.endFrame(kind, subject)
  end, debug.traceback)
  if not ended then
    pcall(HostDisplay.cancelFrame, kind, subject, endResult)
    error(endResult, 0)
  end
  return result
end

return HostDisplay
