-- Versioned native import/export boundary.
--
-- Portable launcher code uses this module instead of calling optional native
-- picker functions directly. A packaged host may install one backend. The
-- default backend preserves native bridge behavior and reports false or nil
-- when a function is absent.
local ImportHost = { API_VERSION = 1 }

local backend

function ImportHost.setBackend(value)
  if value ~= nil and type(value) ~= "table" then
    error("import host backend must be a table or nil", 2)
  end
  if value and value.apiVersion ~= ImportHost.API_VERSION then
    error("unsupported import host API version", 2)
  end
  backend = value
end

function ImportHost.backend()
  return backend
end

local function native(name)
  local system = rawget(_G, "love") and love.system
  local fn = system and system[name]
  return type(fn) == "function" and fn or nil
end

function ImportHost.capabilities()
  local fn = backend and backend.capabilities
  if fn then
    local ok, reported = pcall(fn, backend)
    if not ok or type(reported) ~= "table" then reported = {} end
    return {
      open = reported.open == true,
      result = reported.result == true,
      save = reported.save == true,
      handoff = reported.handoff == true,
    }
  end
  return {
    open = native("pickFile") ~= nil,
    result = native("getPickedFile") ~= nil,
    save = native("createFile") ~= nil,
    handoff = false,
  }
end

function ImportHost.requestOpen(kind)
  local fn = backend and backend.requestOpen
  if fn then return fn(backend, kind) and true or false end
  fn = native("pickFile")
  return fn and fn(kind) and true or false
end

function ImportHost.openKinds()
  local fn = backend and backend.openKinds
  if fn then return fn(backend) end
  fn = native("pickFileKinds")
  if not fn then return nil end
  local ok, result = pcall(fn)
  return ok and result or nil
end

function ImportHost.takeOpenResult()
  local fn = backend and backend.takeOpenResult
  if fn then return fn(backend) end
  fn = native("getPickedFile")
  return fn and fn() or nil
end

function ImportHost.takeOpenError()
  local fn = backend and backend.takeOpenError
  if fn then return fn(backend) end
  fn = native("getPickError")
  return fn and fn() or nil
end

function ImportHost.requestSave(suggestedName, stagingDirectory)
  local fn = backend and backend.requestSave
  if fn then
    return fn(backend, suggestedName, stagingDirectory) and true or false
  end
  fn = native("createFile")
  return fn and fn(suggestedName, stagingDirectory) and true or false
end

function ImportHost.requestHandoff(target, context)
  local fn = backend and backend.requestHandoff
  if not fn then return false end
  return fn(backend, target, context) and true or false
end

return ImportHost
