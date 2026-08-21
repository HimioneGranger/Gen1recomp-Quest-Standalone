-- Normal, Test, and Diagnostic builds must remain available together with
-- stable package identities and distinct user-visible labels.

local file = assert(io.open("scripts/build_android.sh", "rb"))
local script = file:read("*a")
file:close()

local function read(path)
  local handle = assert(io.open(path, "rb"))
  local value = handle:read("*a")
  handle:close()
  return value
end

local function property(text, key)
  local prefix = key .. "="
  for line in text:gmatch("[^\r\n]+") do
    if line:sub(1, #prefix) == prefix then
      return line:sub(#prefix + 1)
    end
  end
end

local properties = read("mobile/android/gradle.properties")
local appGradle = read("mobile/android/app/build.gradle")
local mainManifest = read("mobile/android/app/src/main/AndroidManifest.xml")
local questManifest = read("mobile/android/app/src/questVr/AndroidManifest.xml")

local checks = 0
local function check(value, message)
  checks = checks + 1
  assert(value, message)
end

check(script:find('local dist_dir="$DIST/debug/$BUILD_VARIANT"', 1, true),
  "Android output directory is variant-specific")
check(script:find('gen1recomp-unplugged-$BUILD_VARIANT-$apk_name', 1, true),
  "Android APK copy has a variant-specific filename")
check(not script:find('local dist_dir="$DIST/debug"\n', 1, true),
  "shared debug output directory is not cleared")
check(script:find('zip -q -X -9 -r "$LOVE_FILE"', 1, true),
  "Android game.love packaging strips host-specific ZIP metadata")

check(property(properties, "app.name") == "Gen1Recomp VR Unplugged",
  "normal Android label stays exactly Gen1Recomp VR Unplugged")
check(script:find('DISPLAY_NAME_OVERRIDE=""', 1, true) and
      script:find('normal) ;;', 1, true),
  "normal builds use the tracked label without an override")
check(script:find('DISPLAY_NAME_OVERRIDE="Gen1Recomp Test"', 1, true),
  "test builds use the exact compact label")
check(script:find('DISPLAY_NAME_OVERRIDE="Gen1Recomp Diagnostic"', 1, true),
  "diagnostic builds use the exact compact label")
check(not script:find("Gen 1 Recomp", 1, true),
  "compatibility-split label source has no spaced Gen 1 spelling")
check(script:find('if [ -n "$DISPLAY_NAME_OVERRIDE" ]; then', 1, true) and
      script:find('gradle_args+=("-Papp.display_name=$DISPLAY_NAME_OVERRIDE")', 1, true) and
      not script:find('"-Papp.display_name=$DISPLAY_NAME_OVERRIDE" \\', 1, true),
  "only non-normal variants pass a display-name override to Gradle")

check(property(properties, "app.application_id") == "com.theboisclub.pokemonred" and
      script:find('APPLICATION_ID="com.theboisclub.pokemonred"', 1, true) and
      script:find('APPLICATION_ID+=".test"', 1, true) and
      script:find('APPLICATION_ID+=".diagnostic"', 1, true),
  "normal, test, and diagnostic package identities stay unchanged")
check(appGradle:find('applicationId project.properties["app.application_id"]', 1, true) and
      appGradle:find('project.findProperty("app.display_name")', 1, true),
  "Gradle keeps package and optional label inputs separate")
check(mainManifest:find('android:label="${NAME}"', 1, true),
  "application and launcher labels still use the shared manifest placeholder")
local _, mainLabelCount = mainManifest:gsub('android:label="${NAME}"', "")
check(mainLabelCount == 2 and not questManifest:find("android:label=", 1, true),
  "Quest flavor inherits both labels without a competing resource")

print(("android build variant output: %d checks passed"):format(checks))
