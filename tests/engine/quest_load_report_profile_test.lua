-- Quest suppresses a mod-set-only notice, but never hides recovery evidence.
-- Self-contained: luajit tests/engine/quest_load_report_profile_test.lua
package.path = "./?.lua;./?/init.lua;" .. package.path

local SaveData = require("src.core.SaveData")

local function report(overrides)
  local value = {
    lostMons = {}, lostItems = {}, remappedMaps = {},
    restoredMons = {}, restoredItems = {}, recovered = nil,
    modsDiff = { added = { "example" }, removed = {}, changed = {} },
  }
  for key, item in pairs(overrides or {}) do value[key] = item end
  return value
end

assert(SaveData.shouldShowLoadReport(report(), false),
  "desktop and generic Android retain the mod-set notice")
assert(not SaveData.shouldShowLoadReport(report(), true),
  "Quest does not interrupt spawn for a mod-set-only notice")

for name, change in pairs({
  lost_mon = { lostMons = { "mon" } },
  lost_item = { lostItems = { "item" } },
  remapped_map = { remappedMaps = { "map" } },
  restored_mon = { restoredMons = { "mon" } },
  restored_item = { restoredItems = { "item" } },
  recovered_save = { recovered = "backup" },
}) do
  assert(SaveData.shouldShowLoadReport(report(change), true),
    "Quest must show material load report: " .. name)
end

local empty = report({ modsDiff = { added = {}, removed = {}, changed = {} } })
assert(not SaveData.shouldShowLoadReport(empty, false),
  "an empty report stays silent on every platform")

print("quest_load_report_profile_test: ok")
