-- ROM-free launcher profile, dependency, and Quest async-install contract.
--   luajit tests/engine/launcher_profile_dependency_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local SaveData = require("src.core.SaveData")
local LauncherMods = require("src.mods.LauncherMods")
local RomImporter = require("src.import.RomImporter")

local savedSaveOptions = SaveData.saveOptions
local savedPrepare = LauncherMods._prepareBundleInner
local savedInstall = LauncherMods._installZipInner
local savedCheck = LauncherMods.checkDependencies

local saves = 0
SaveData.saveOptions = function()
  saves = saves + 1
  return true
end

local options = {
  activeProfile = "P1",
  modProfiles = {
    {
      name = "P1",
      enabled = { one = true },
      enabledByVersion = { red = { one = true } },
    },
  },
}
local duplicate = LauncherMods.duplicateProfile("P1", options)
T.eq(duplicate.name, "P1 (Copy)", "duplicate gets a stable distinct name")
T.eq(options.activeProfile, "P1 (Copy)", "duplicate becomes active")
T.check(duplicate.enabled ~= options.modProfiles[1].enabled,
  "duplicate owns an independent enabled table")
T.check(LauncherMods.renameProfile("P1 (Copy)", "Travel", options),
  "active duplicate can be renamed")
T.eq(options.activeProfile, "Travel", "active name follows rename")
T.check(LauncherMods.deleteProfile("Travel", options),
  "active duplicate can be removed")
T.eq(#options.modProfiles, 1, "delete keeps the original profile")
T.eq(options.activeProfile, "P1", "delete activates the remaining profile")
T.check(saves >= 3, "each profile mutation is persisted")

local checked
LauncherMods._prepareBundleInner = function()
  return nil, "this archive is already a mod package"
end
LauncherMods._installZipInner = function()
  return true, "needs_helper", {
    id = "needs_helper",
    dependencySpecs = { { id = "helper" } },
  }
end
LauncherMods.checkDependencies = function(manifest)
  checked = manifest
  return {
    hasIssues = true,
    targetMod = manifest,
    deps = { { id = "helper", status = "missing" } },
  }
end

local importer = setmetatable({ workState = "idle" }, { __index = RomImporter })
importer:_installMod("fixture.zip")
local worker = importer.modWorker
T.check(type(worker) == "thread", "Quest importer creates its bounded worker")
T.check(coroutine.resume(worker), "worker reaches its initial yield")
T.check(coroutine.resume(worker), "worker completes the direct install")
T.eq(checked.id, "needs_helper", "async install checks the returned manifest")
T.eq(importer._modDepResolver.deps[1].status, "missing",
  "async install opens the same missing-dependency result")
T.check(importer.modNotice and importer.modNotice.ok,
  "async install keeps the Quest success notice")

SaveData.saveOptions = savedSaveOptions
LauncherMods._prepareBundleInner = savedPrepare
LauncherMods._installZipInner = savedInstall
LauncherMods.checkDependencies = savedCheck

T.finish("launcher profile dependency")
