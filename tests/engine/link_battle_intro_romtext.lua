-- Link battles must use imported trainer-intro text when it is present.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local Data = T.fixtures.fresh()
local Link = require("tests.modkit.link")
local LinkBattle = require("src.link.LinkBattle")
local Net = require("src.link.Net")
local Protocol = require("src.link.Protocol")

Link.prepare(Data)
local gameA, gameB = Link.pair(Data, "FIXMON_A", "FIXMON_B", {
  nameA = "RED", nameB = "BLUE", level = 10,
})
local packedA = Protocol.packParty(gameA.save.party)
local packedB = Protocol.packParty(gameB.save.party)

local function build()
  return LinkBattle.newHost(gameA, select(1, Net.loopbackPair()), {
    myParty = packedA,
    theirParty = packedB,
    theirName = "BLUE",
    seed = 11,
    verdict = "full",
    strict = true,
  })
end

Data.text._TrainerWantsToFightText = "FAKE {RAM:wStringBuffer} challenges!"
T.eq(build().introText, "FAKE BLUE challenges!",
  "link battle intro uses imported ROM text")

Data.text._TrainerWantsToFightText = nil
T.eq(build().introText, "BLUE wants\nto battle!",
  "link battle intro keeps the baseline English fallback")

T.finish("link battle intro ROM text")
