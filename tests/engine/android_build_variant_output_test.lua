-- Normal, Test, and Diagnostic builds must remain available together.

local file = assert(io.open("scripts/build_android.sh", "rb"))
local script = file:read("*a")
file:close()

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
check(script:find('touch -t 202608210000.00 "$stamp_dir/src/core/Version.lua"', 1, true),
  "Android version stamp uses a fixed ZIP entry time")

print(("android build variant output: %d checks passed"):format(checks))
