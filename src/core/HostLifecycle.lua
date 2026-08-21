-- Versioned optional host lifecycle observer.
local HostLifecycle = { API_VERSION = 1 }

local backend

function HostLifecycle.setBackend(value)
  if value ~= nil and type(value) ~= "table" then
    error("host lifecycle backend must be a table or nil", 2)
  end
  if value and value.apiVersion ~= HostLifecycle.API_VERSION then
    error("unsupported host lifecycle API version", 2)
  end
  backend = value
end

local function notify(name, ...)
  local fn = backend and backend[name]
  if fn then return fn(backend, ...) end
end

function HostLifecycle.focus(value)
  return notify("focus", value and true or false)
end

function HostLifecycle.visible(value)
  return notify("visible", value and true or false)
end

function HostLifecycle.handoff(target, context)
  return notify("handoff", target, context)
end

function HostLifecycle.mustExit()
  return notify("mustExit") == true
end

function HostLifecycle.shutdown()
  return notify("shutdown")
end

return HostLifecycle
