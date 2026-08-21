-- Semantic port of upstream fbdfc1c0 for this branch's separate ChoiceBox.
package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.harness")

package.loaded["src.render.TextBox"] = {
  new = function(_, text, onDone, opts)
    return { kind = "text", text = text, onDone = onDone, opts = opts }
  end,
}
package.loaded["src.ui.ChoiceBox"] = {
  new = function(_, onChoose)
    return { kind = "choice", onChoose = onChoose }
  end,
}

local M = assert(loadfile("data/scripts/story2.lua"))()
local clerk = M.MUSEUM_1F.talk.TEXT_MUSEUM1F_SCIENTIST1

local translated = {
  _Museum1FScientist1TakePlentyOfTimeText = "TAKE-TRANSLATED",
  _Museum1FScientist1WouldYouLikeToComeInText = "PROMPT-TRANSLATED",
  _Museum1FScientist1ThankYouText = "THANKS-TRANSLATED",
  _Museum1FScientist1DontHaveEnoughMoneyText = "POOR-TRANSLATED",
  _Museum1FScientist1ComeAgainText = "RETURN-TRANSLATED",
}

local pushed
local function mkGame(cash, text)
  pushed = {}
  return {
    data = { text = text or translated },
    save = { money = cash, flags = {} },
    stack = { push = function(_, box) pushed[#pushed + 1] = box end },
  }
end

local function choose(game, yes)
  clerk(game, nil, nil, function() end)
  T.eq(pushed[1].text, translated._Museum1FScientist1WouldYouLikeToComeInText,
    "the admission prompt uses its translated label")
  pushed[1].onDone()
  T.eq(pushed[2].kind, "choice", "the accepted separate choice flow remains")
  pushed[2].onChoose(yes)
  return pushed[3]
end

local game = mkGame(3000)
game.save.flags.EVENT_BOUGHT_MUSEUM_TICKET = true
clerk(game, nil, nil, function() end)
T.eq(pushed[1].text, translated._Museum1FScientist1TakePlentyOfTimeText,
  "ticket holders get the translated take-your-time line")

game = mkGame(3000)
T.eq(choose(game, true).text, translated._Museum1FScientist1ThankYouText,
  "a paid ticket gets the translated thank-you line")
T.eq(game.save.money, 2950, "the translation port keeps the ticket charge")

game = mkGame(20)
T.eq(choose(game, true).text,
  translated._Museum1FScientist1DontHaveEnoughMoneyText,
  "insufficient funds use the translated refusal line")

game = mkGame(3000)
T.eq(choose(game, false).text, translated._Museum1FScientist1ComeAgainText,
  "declining uses the translated return line")

game = mkGame(3000, {})
game.save.flags.EVENT_BOUGHT_MUSEUM_TICKET = true
clerk(game, nil, nil, function() end)
T.check(pushed[1].text:find("Take your time", 1, true) ~= nil,
  "an empty catalog keeps the English fallback")

T.finish("museum 1F clerk translations")
