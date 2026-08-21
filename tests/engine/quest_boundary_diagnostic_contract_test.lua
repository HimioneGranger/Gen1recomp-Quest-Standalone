-- The app observes Quest Guardian boundary/reference-space changes without
-- forcing Stationary or Roomscale. Self-contained contract test.
local function read(path)
  local file = assert(io.open(path, "rb"))
  local value = file:read("*a")
  file:close()
  return value
end

local bridge = read("mobile/android/love/src/jni/questxr_bridge/questxr_bridge.c")

assert(bridge:find("space_info.referenceSpaceType = XR_REFERENCE_SPACE_TYPE_LOCAL;", 1, true),
  "launcher must preserve its LOCAL app reference space")
assert(bridge:find("boundary diagnostic app-space=LOCAL", 1, true),
  "startup diagnostics must record the app space and current STAGE bounds")
assert(bridge:find("boundary diagnostic reference-space change", 1, true),
  "reference-space changes must record their type, pose validity, and STAGE bounds")
assert(not bridge:find("xrCreateReferenceSpace(session, &space_info, &space_stationary", 1, true),
  "diagnostics must not force a Stationary boundary")

print("quest_boundary_diagnostic_contract_test: 4 checks passed")
