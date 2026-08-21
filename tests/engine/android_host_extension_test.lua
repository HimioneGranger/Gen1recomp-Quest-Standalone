-- GameActivity exposes an optional Android host seam without requiring any
-- host implementation (or its native libraries) in the stock build.
-- Self-contained: luajit tests/engine/android_host_extension_test.lua
local path = "mobile/android/love/src/main/java/org/love2d/android/GameActivity.java"
local file = assert(io.open(path, "rb"))
local source = file:read("*a")
file:close()

local function read(otherPath)
  local other = assert(io.open(otherPath, "rb"))
  local value = other:read("*a")
  other:close()
  return value
end

local function check(value, message)
  if not value then error(message, 2) end
end

local function position(text)
  local p = source:find(text, 1, true)
  check(p, "missing: " .. text)
  return p
end

check(source:find("protected String[] getHostLibraries()", 1, true),
  "host libraries are an overridable protected extension")
check(source:find("return new String[0];", 1, true),
  "the vanilla host library list is empty")
check(source:find("protected String getHostModule()", 1, true),
  "host module discovery is an overridable protected extension")
check(source:find('return "";', 1, true),
  "the vanilla host module name is empty")
check(source:find("public static String getHostModuleName()", 1, true) and
      source:find("self.getHostModule()", 1, true),
  "native discovery delegates to the active Android activity")

local cpp = position('libraries[0] = "c++_shared";')
local mpg = position('libraries[1] = "mpg123";')
local openal = position('libraries[2] = "openal";')
local host = position("System.arraycopy(hostLibraries, 0, libraries, 3, hostLibraries.length);")
local love = position('libraries[libraries.length - 1] = "love";')
check(cpp < mpg and mpg < openal and openal < host and host < love,
  "optional libraries load after dependencies while liblove remains last")

for _, hook in ipairs({
  "onHostCreateBeforeSDL", "onHostCreateAfterSDL", "onHostResume",
  "onHostPause", "onHostDestroy",
}) do
  check(source:find("protected void " .. hook, 1, true),
    hook .. " is a protected extension hook")
end

check(position("onHostCreateBeforeSDL(savedInstanceState);") <
      position("super.onCreate(savedInstanceState);") and
      position("super.onCreate(savedInstanceState);") <
      position("onHostCreateAfterSDL(savedInstanceState);"),
  "create hooks bracket SDL creation")
check(position("super.onResume();") < position("onHostResume();"),
  "resume hook runs after SDL resumes")
check(position("onHostPause();") < position("super.onPause();"),
  "pause hook runs before SDL pauses")
check(position("onHostDestroy();") < position("super.onDestroy();"),
  "destroy hook runs before SDL destruction")

check(not source:lower():find("openxr", 1, true),
  "generic Android activity must not require OpenXR")
check(not source:find("QuestActivity", 1, true) and
      not source:find("QuestBridge", 1, true),
  "generic Android activity must not require Quest classes")

local androidCpp = read(
  "mobile/android/love/src/jni/love/src/common/android.cpp")
local androidHeader = read(
  "mobile/android/love/src/jni/love/src/common/android.h")
local systemCpp = read(
  "mobile/android/love/src/jni/love/src/modules/system/System.cpp")
local systemHeader = read(
  "mobile/android/love/src/jni/love/src/modules/system/System.h")
local wrapSystem = read(
  "mobile/android/love/src/jni/love/src/modules/system/wrap_System.cpp")
check(androidCpp:find('"getHostModuleName"', 1, true) and
      androidHeader:find("std::string getHostModule();", 1, true),
  "generic Android JNI exposes neutral host module discovery")
check(systemCpp:find("System::getHostModule()", 1, true) and
      systemHeader:find("std::string getHostModule() const", 1, true),
  "system module carries the neutral host module name")
check(wrapSystem:find('{ "getHostModule", w_getHostModule }', 1, true),
  "Lua system bindings expose neutral host module discovery")

print("android_host_extension_test: ok")
