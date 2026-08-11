-- Gold's card flip (engine/games/card_flip.asm _CardFlip), the `special
-- CardFlip` the Goldenrod Game Corner's second machine calls.
--
-- Three coins a go.  A 24 card deck is dealt two at a time; the player picks one
-- of the two face-down cards without seeing it, then bets on a square of a 6x8
-- board, and the card is turned over.  A card is a Pokemon (Pikachu,
-- Jigglypuff, Poliwag, Oddish) and a level (1-6), packed as level * 4 + mon --
-- which is why every win condition in the ASM is a mask on the card byte and
-- why the exact-card squares can just `cp e` against a literal 0-23.
--
-- The payout ladder, from CardFlip_CheckWinCondition:
--
--   6   a PAIR of Pokemon      (Pikachu/Jigglypuff, or Poliwag/Oddish)
--   9   a PAIR of levels       (1-2, 3-4, or 5-6)
--   12  one Pokemon
--   18  one level
--   72  the exact card
--
-- The four squares where a Pokemon pair meets a level pair are .Impossible:
-- they are on the board, the cursor can sit on them, and they always lose.
--
-- Everything that decides an outcome is a pure function here, taking a
-- `random(n) -> 0..n-1` the way src/battle/gen2 does, so a test can shuffle and
-- score thousands of hands.  The screen half is the only part that touches love.
--
-- Layout is transcribed from the ASM, not laid out by eye.  The cursor OAM
-- table is in OAM space, which sits 8px right and 16px down of the screen, so a
-- `cardflip_cursor 13, 5` anchor is screen tile (12, 3):
--
--   CardFlip_InitTilemap    fills the screen with $29 and copies
--                           CardFlipTilemap to hlcoord 9, 0 as 12 rows x 11
--                           columns -- so the odds board is (9,0)-(19,11)
--   .ChooseACard            writes CARDFLIP_LIGHT_ON at hlcoord 9, 0 plus
--                           wCardFlipNumCardsPlayed rows: twelve lights down
--                           column 9, one per hand in the deck
--   CardFlip_InitAttrPals   colours 2x2 boxes at (12,1), (14,1), (16,1) and
--                           (18,1) -- the four Pokemon headers
--   .Level1 .. .Level6      blank a discarded card at hlcoord 13, 3 / 4 / 6 /
--                           7 / 9 / 10 plus two columns per Pokemon, so the
--                           24 card cells are columns 13, 15, 17, 19 on those
--                           six rows
--   GetCoordsOfChosenCard   hlcoord 2, 0 and hlcoord 2, 6, each a 6x5 box; the
--                           level digit lands at +3 +SCREEN_WIDTH and the 3x3
--                           Pokepic one SCREEN_HEIGHT further on
--   CardFlip_PrintCoinBalance
--                           Textbox at (9,15) with a 9x1 interior, "COIN" at
--                           (10,16) and four leading-zero digits at (15,16)
--   CardFlip_UpdateCoinBalanceDisplay
--                           Textbox at (0,12) with an 18x4 interior
--
-- The cart's own art (gfx/card_flip/card_flip_1..3.2bpp.lz and
-- gfx/card_flip/card_flip.tilemap) is NOT in the cache: no `cardFlip` entry is
-- written into menu_gfx.lua yet, so the board draws as labelled cells until one
-- appears.

local Chrome = require("src.ui.gen2.Chrome")
local CoinCase = require("src.core.gen2.CoinCase")
local Sound = require("src.core.Sound")

local CardFlip = {}
CardFlip.__index = CardFlip
CardFlip.isOpaque = true

-- constants/misc_constants.asm: CARDFLIP_DECK_SIZE EQU 4 * 6.
CardFlip.DECK_SIZE = 24
CardFlip.NUM_MONS = 4
CardFlip.NUM_LEVELS = 6
-- .DeductCoins: `ld de, -3`.
CardFlip.BET = 3

-- The Pokemon order is the one .Deck's pic anchors and .Pikachu/.Jigglypuff/
-- .Poliwag/.Oddish's `and $3` comparisons agree on.
CardFlip.MONS = { [0] = "PIKACHU", [1] = "JIGGLYPUFF", [2] = "POLIWAG",
  [3] = "ODDISH" }
CardFlip.MON_LABELS = { [0] = "PI", [1] = "JI", [2] = "PO", [3] = "OD" }

-- card = level * 4 + mon.  Everywhere the ASM masks the card byte:
--   and $3   the Pokemon
--   and $1c  the level, times four
--   and $18  the level PAIR, since bit 2 is the odd/even level
function CardFlip.mon(card) return card % 4 end
function CardFlip.level(card) return math.floor(card / 4) end
function CardFlip.levelPair(card) return math.floor(card / 8) end
function CardFlip.card(level, mon) return level * 4 + mon end

-- ------------------------------------------------------------------- deck
--
-- CardFlip_ShuffleDeck, transcribed rather than replaced with a Fisher-Yates:
-- the cart fills the deck with zeroes, then drops the values 23 down to 1 into
-- random empty slots, rejecting a roll of 24-31 (`and $1f / cp
-- CARDFLIP_DECK_SIZE`) and rejecting an occupied slot.  Card 0 is never placed
-- -- the single slot still holding zero IS card 0, which is why "empty" and
-- "card 0" can share a value without breaking anything.
-- `random` is injectable, and the rejection loop is unbounded on the cart
-- because hRandomAdd is never degenerate.  A source that only ever returns one
-- number would spin here forever, so the retries are capped and the fallback is
-- a linear probe for the next empty slot: unreachable with any real RNG, and
-- the difference between a wrong shuffle and a hung game if one is handed in.
local SHUFFLE_RETRIES = 256

function CardFlip.shuffle(random)
  local deck = {}
  for i = 1, CardFlip.DECK_SIZE do deck[i] = 0 end
  local value = CardFlip.DECK_SIZE - 1
  while value > 0 do
    local slot, tries = nil, 0
    repeat
      slot = random(32)
      tries = tries + 1
    until (slot < CardFlip.DECK_SIZE and deck[slot + 1] == 0)
      or tries >= SHUFFLE_RETRIES
    if slot >= CardFlip.DECK_SIZE or deck[slot + 1] ~= 0 then
      slot = 0
      while slot < CardFlip.DECK_SIZE and deck[slot + 1] ~= 0 do
        slot = slot + 1
      end
    end
    deck[slot + 1] = value
    value = value - 1
  end
  return deck
end

-- .CheckTheCard: wDeck + numCardsPlayed * 2 + whichCard.  `which` is 0 or 1,
-- `played` is 0-based, and the deck runs out after twelve hands (.Continue's
-- `cp 12`), at which point the deck is reshuffled.
function CardFlip.dealt(deck, played, which)
  return deck[played * 2 + which + 1]
end

CardFlip.HANDS_PER_DECK = 12

-- ------------------------------------------------------------------ board
--
-- CardFlip_CheckWinCondition's jumptable, read through CollapseCursorPosition
-- (index = cursorY * 6 + cursorX).  Rows and columns are the cart's, 0-based:
--
--   x = 0        the level PAIR column, one entry per two rows
--   x = 1        the single level column
--   x = 2..5     one column per Pokemon
--   y = 0        the Pokemon PAIR row, one entry per two columns
--   y = 1        the single Pokemon row
--   y = 2..7     one row per level
--
-- and the four squares at x < 2, y < 2 are .Impossible.
CardFlip.PAYOUT_MON_PAIR = 6
CardFlip.PAYOUT_LEVEL_PAIR = 9
CardFlip.PAYOUT_MON = 12
CardFlip.PAYOUT_LEVEL = 18
CardFlip.PAYOUT_CARD = 72

CardFlip.BOARD_W = 6
CardFlip.BOARD_H = 8

-- BOARD[y][x], 0-based on both axes.
CardFlip.BOARD = {}
for y = 0, CardFlip.BOARD_H - 1 do
  local row = {}
  for x = 0, CardFlip.BOARD_W - 1 do
    local cell
    if y < 2 and x < 2 then
      cell = { kind = "impossible", payout = 0 }
    elseif y == 0 then
      -- .PikaJiggly / .PoliOddish: `and $2` splits the four Pokemon in half.
      cell = { kind = "monPair", value = math.floor((x - 2) / 2),
        payout = CardFlip.PAYOUT_MON_PAIR }
    elseif y == 1 then
      cell = { kind = "mon", value = x - 2, payout = CardFlip.PAYOUT_MON }
    elseif x == 0 then
      -- .OneTwo / .ThreeFour / .FiveSix, each reached from two rows.
      cell = { kind = "levelPair", value = math.floor((y - 2) / 2),
        payout = CardFlip.PAYOUT_LEVEL_PAIR }
    elseif x == 1 then
      cell = { kind = "level", value = y - 2, payout = CardFlip.PAYOUT_LEVEL }
    else
      cell = { kind = "card", value = CardFlip.card(y - 2, x - 2),
        payout = CardFlip.PAYOUT_CARD }
    end
    row[x] = cell
  end
  CardFlip.BOARD[y] = row
end

function CardFlip.cell(x, y)
  local row = CardFlip.BOARD[y]
  return row and row[x] or nil
end

-- What a square pays against a card, or 0.  Only one square is ever bet on, so
-- there is no stacking to worry about.
function CardFlip.payout(x, y, card)
  local cell = CardFlip.cell(x, y)
  if not cell or not card then return 0 end
  local kind = cell.kind
  if kind == "impossible" then return 0 end
  if kind == "monPair" then
    return math.floor(CardFlip.mon(card) / 2) == cell.value and cell.payout or 0
  end
  if kind == "mon" then
    return CardFlip.mon(card) == cell.value and cell.payout or 0
  end
  if kind == "levelPair" then
    return CardFlip.levelPair(card) == cell.value and cell.payout or 0
  end
  if kind == "level" then
    return CardFlip.level(card) == cell.value and cell.payout or 0
  end
  return card == cell.value and cell.payout or 0
end

-- ---------------------------------------------------------- cursor moves
--
-- ChooseCard_HandleJoypad.  The board is not a plain grid: column 0 spans two
-- rows per entry and row 0 spans two columns, so moving off a paired square
-- SNAPS the other axis even before the step (`and $e`), and moving left or up
-- out of a paired square teleports to a fixed neighbour rather than stepping.
--
-- Returns the new x, y.  Transcribed branch for branch; the `and $e` snaps and
-- the two teleports are the whole reason this is not three lines.
function CardFlip.moveCursor(x, y, direction)
  if direction == "left" then
    if y == 0 then
      -- .mon_pair_left: snap x even, then either teleport or step two.
      x = x - (x % 2)
      if x < 3 then return 1, 2 end -- .left_to_number_gp
      return x - 2, y
    end
    if y == 1 then
      -- .mon_group_left
      if x < 3 then return 1, 2 end
      return x - 1, y
    end
    if x == 0 then return x, y end
    return x - 1, y
  end

  if direction == "right" then
    if y == 0 then
      -- .mon_pair_right
      x = x - (x % 2)
      if x >= 4 then return x, y end
      return x + 2, y
    end
    if x >= 5 then return x, y end
    return x + 1, y
  end

  if direction == "up" then
    if x == 0 then
      -- .num_pair_up
      y = y - (y % 2)
      if y < 3 then return 2, 1 end -- .up_to_mon_group
      return x, y - 2
    end
    if x == 1 then
      -- .num_gp_up
      if y < 3 then return 2, 1 end
      return x, y - 1
    end
    if y == 0 then return x, y end
    return x, y - 1
  end

  if direction == "down" then
    if x == 0 then
      -- .num_pair_down
      y = y - (y % 2)
      if y >= 6 then return x, y end
      return x, y + 2
    end
    if y >= 7 then return x, y end
    return x, y + 1
  end

  return x, y
end

-- ------------------------------------------------------------------ layout
--
-- Screen tile coordinates, derived from the OAM cursor anchors (minus one tile
-- across and two down) and from the discard-blanking hlcoords.
local LIGHT_X = 9                        -- twelve hand lights, rows 0-11
local MON_COL = { [2] = 12, [3] = 14, [4] = 16, [5] = 18 }
local LEVEL_PAIR_COL, LEVEL_COL = 10, 11
local CARD_COL = { [2] = 13, [3] = 15, [4] = 17, [5] = 19 }
-- .Level1 .. .Level6's rows.  The pairs overlap by a row on the cart, which is
-- the stacked-card look; the anchors are what matter here.
local LEVEL_ROW = { [2] = 3, [3] = 4, [4] = 6, [5] = 7, [6] = 9, [7] = 10 }
local MON_PAIR_ROW, MON_ROW = 0, 1

-- GetCoordsOfChosenCard.
local CARD_BOX = { { x = 2, y = 0 }, { x = 2, y = 6 } }
local CARD_BOX_W, CARD_BOX_H = 5, 6

local COIN_BOX_X, COIN_BOX_Y, COIN_BOX_W, COIN_BOX_H = 9, 15, 11, 3
local COIN_LABEL_X, COIN_LABEL_Y = 10, 16
local COIN_VALUE_X, COIN_VALUE_Y = 15, 16

local TEXT_BOX_X, TEXT_BOX_Y, TEXT_BOX_W, TEXT_BOX_H = 0, 12, 20, 6
local TEXT_X, TEXT_Y, TEXT_LINE = 1, 14, 2

-- ------------------------------------------------------------------- text
-- data/text/common_3.asm; none of these are in the cache's text.lua, because no
-- script bytecode the extractor walks points at them.
CardFlip.TEXTS = {
  playWithThree = { "Play with three", "coins?" },
  notEnough = { "Not enough coins…" },
  chooseACard = { "Choose a card." },
  placeYourBet = { "Place your bet." },
  playAgain = { "Want to play", "again?" },
  shuffled = { "The cards have", "been shuffled." },
  yeah = { "Yeah!" },
  darn = { "Darn…" },
}

local SFX_TRANSACTION = "Sfx_Transaction"
local SFX_KINESIS = "Sfx_Kinesis"
local SFX_START = "Sfx_SlotMachineStart"
local SFX_CHOOSE = "Sfx_ChooseACard"
local SFX_MOVE = "Sfx_PokeballsPlacedOnTable"
local SFX_WIN = "Sfx_2ndPlace"
local SFX_WRONG = "Sfx_Wrong"
local SFX_PAY_DAY = "Sfx_PayDay"
local SFX_QUIT = "Sfx_QuitSlots"

-- ------------------------------------------------------------------ screen
function CardFlip:wantsFillScale() return true end
function CardFlip:drawsWidescreen() return true end

-- opts: save, random(n), onClose()
function CardFlip.new(game, opts)
  opts = opts or {}
  local self = setmetatable({}, CardFlip)
  self.game = game
  self.save = opts.save or (game and game.save)
  self.onClose = opts.onClose
  self.random = opts.random or function(n)
    if love and love.math and love.math.random then
      return love.math.random(n) - 1
    end
    return math.random(n) - 1
  end
  -- `ld a, $2 / ld [wCardFlipCursorY], a / ld [wCardFlipCursorX], a`.
  self.cursorX, self.cursorY = 2, 2
  self.played = 0
  self.discarded = {}
  self.deck = CardFlip.shuffle(self.random)
  self:playMusic()
  self:enterAsk()
  return self
end

function CardFlip:playMusic()
  local data = self.game and self.game.data
  if not data then return end
  require("src.core.Music").play(data, "Music_GameCorner")
end

function CardFlip:sfx(name)
  local data = self.game and self.game.data
  if data then Sound.play(data, name) end
end

function CardFlip:coins()
  return CoinCase.coins(self.save)
end

-- ---------------------------------------------------------------- phases
--
-- .AskPlayWithThree / .DeductCoins / .ChooseACard / .PlaceYourBet /
-- .CheckTheCard / .TabulateTheResult / .PlayAgain / .Quit.
function CardFlip:enterAsk()
  self.phase = "ask"
  self.choice = 1
  self.lines = CardFlip.TEXTS.playWithThree
end

function CardFlip:deduct()
  -- The check is `wCoins high byte non-zero, or low byte >= 3`, which is just
  -- "at least three coins".
  if self:coins() < CardFlip.BET then
    self.phase = "message"
    self.lines = CardFlip.TEXTS.notEnough
    self.after = function() self:quit() end
    return
  end
  CoinCase.takeCoins(self.save, CardFlip.BET)
  self:sfx(SFX_TRANSACTION)
  self:enterChoose()
end

function CardFlip:enterChoose()
  self.phase = "choose"
  self.which = 0 -- wCardFlipWhichCard
  self.faceUp = nil
  self.lines = CardFlip.TEXTS.chooseACard
end

function CardFlip:enterBet()
  self.phase = "bet"
  self.lines = CardFlip.TEXTS.placeYourBet
end

-- .CheckTheCard: the dealt card is turned face up and marked on the discard
-- pile, which is what blanks its cell on the odds board.
function CardFlip:flip()
  local card = CardFlip.dealt(self.deck, self.played, self.which)
  self.faceUp = card
  self.discarded[card] = true
  self:sfx(SFX_CHOOSE)
  self:tabulate()
end

function CardFlip:tabulate()
  local won = CardFlip.payout(self.cursorX, self.cursorY, self.faceUp)
  self.payoutLeft = won
  self.payoutTick = 0
  if won > 0 then
    self.phase = "payout"
    self.lines = CardFlip.TEXTS.yeah
    self:sfx(SFX_WIN)
  else
    self.phase = "result"
    self.lines = CardFlip.TEXTS.darn
    self:sfx(SFX_WRONG)
  end
end

-- .Payout's loop: one coin every two frames, the coin case checked BEFORE each
-- increment so a full case swallows the rest of the win.
function CardFlip:updatePayout()
  self.payoutTick = self.payoutTick + 1
  if self.payoutTick % 2 == 1 then return end
  if self.payoutLeft <= 0 then
    self.phase = "result"
    return
  end
  self.payoutLeft = self.payoutLeft - 1
  if self:coins() < CoinCase.MAX_COINS then
    CoinCase.giveCoins(self.save, 1)
    self:sfx(SFX_PAY_DAY)
  end
end

-- .PlayAgain -> .Continue: the hand counter advances, and only a twelfth hand
-- reshuffles.  Otherwise the card just played is blanked off the board.
function CardFlip:enterAgain()
  self.phase = "again"
  self.choice = 1
  self.lines = CardFlip.TEXTS.playAgain
end

function CardFlip:continue()
  self.played = self.played + 1
  if self.played >= CardFlip.HANDS_PER_DECK then
    self.played = 0
    self.deck = CardFlip.shuffle(self.random)
    self.discarded = {}
    self.phase = "message"
    self.lines = CardFlip.TEXTS.shuffled
    self.after = function() self:deduct() end
    return
  end
  self:deduct()
end

function CardFlip:quit()
  self.phase = "quit"
  self:sfx(SFX_QUIT)
  local data = self.game and self.game.data
  if data then require("src.core.Music").restoreMap(data) end
  if self.onClose then self.onClose() end
end

function CardFlip:update(_dt)
  local input = self.game and self.game.input
  if not input then return end
  local phase = self.phase

  if phase == "ask" or phase == "again" then
    if input:wasPressed("up") or input:wasPressed("down") then
      self.choice = self.choice == 1 and 2 or 1
      return
    end
    -- YesNoBox returning carry is .SaidNo on the first question and the
    -- .Increment into .Quit on the second: B leaves either way.
    if input:wasPressed("b") then
      self:quit()
      return
    end
    if input:wasPressed("a") then
      if self.choice ~= 1 then
        self:quit()
      elseif phase == "ask" then
        self:deduct()
      else
        self:continue()
      end
    end
    return
  end

  if phase == "message" then
    if input:wasPressed("a") or input:wasPressed("b") then
      local after = self.after
      self.after = nil
      if after then after() end
    end
    return
  end

  -- .ChooseACard's loop: the highlight alternates between the two face-down
  -- cards on its own and A locks whichever is lit.
  if phase == "choose" then
    if input:wasPressed("a") then
      self:sfx(SFX_START)
      self:enterBet()
      return
    end
    self.blink = (self.blink or 0) + 1
    if self.blink >= 4 then
      self.blink = 0
      self.which = self.which == 0 and 1 or 0
      self:sfx(SFX_KINESIS)
    end
    return
  end

  if phase == "bet" then
    for _, dir in ipairs({ "left", "right", "up", "down" }) do
      if input:wasPressed(dir) then
        local x, y = CardFlip.moveCursor(self.cursorX, self.cursorY, dir)
        if x ~= self.cursorX or y ~= self.cursorY then self:sfx(SFX_MOVE) end
        self.cursorX, self.cursorY = x, y
        return
      end
    end
    if input:wasPressed("a") then self:flip() end
    return
  end

  if phase == "payout" then
    self:updatePayout()
    return
  end

  if phase == "result" then
    -- WaitPressAorB_BlinkCursor.
    if input:wasPressed("a") or input:wasPressed("b") then self:enterAgain() end
    return
  end
end

-- ------------------------------------------------------------------- draw
function CardFlip:drawBoard()
  -- The twelve hand lights down column 9; CARDFLIP_LIGHT_ON marks the hand
  -- being played and every one before it stays off.
  for row = 0, CardFlip.HANDS_PER_DECK - 1 do
    Chrome.print(row == self.played and "o" or ".", LIGHT_X, row)
  end
  for x = 2, 5 do
    Chrome.print(CardFlip.MON_LABELS[x - 2], MON_COL[x], MON_ROW)
    -- The pair headers sit above the two Pokemon they cover.
    if x % 2 == 0 then Chrome.print("6", MON_COL[x] + 1, MON_PAIR_ROW) end
  end
  for y = 2, 7 do
    local row = LEVEL_ROW[y]
    Chrome.print(tostring(y - 1), LEVEL_COL, row)
    if y % 2 == 0 then Chrome.print("9", LEVEL_PAIR_COL, row) end
    for x = 2, 5 do
      -- A still-in-the-deck cell stands in for the card back until the art
      -- lands.  It cannot be '#': that is charmap.asm $54, the text command
      -- that places "POKé", not a one-tile glyph.
      local card = CardFlip.card(y - 2, x - 2)
      Chrome.print(self.discarded[card] and " " or "?", CARD_COL[x], row)
    end
  end
end

function CardFlip:cursorCell()
  local x, y = self.cursorX, self.cursorY
  local col
  if x == 0 then col = LEVEL_PAIR_COL
  elseif x == 1 then col = LEVEL_COL
  else col = MON_COL[x] end
  local row
  if y == 0 then row = MON_PAIR_ROW
  elseif y == 1 then row = MON_ROW
  else row = LEVEL_ROW[y] end
  return col, row
end

-- CardFlip_DisplayCardFaceUp: the level digit at the box origin + (3,1) and the
-- 3x3 Pokepic one row further down.
function CardFlip:drawCards()
  for slot = 1, 2 do
    local box = CARD_BOX[slot]
    Chrome.box(box.x, box.y, CARD_BOX_W, CARD_BOX_H)
    local chosen = (slot - 1) == self.which
    if self.faceUp and chosen then
      Chrome.print(tostring(CardFlip.level(self.faceUp) + 1), box.x + 3,
        box.y + 1)
      Chrome.print(CardFlip.MON_LABELS[CardFlip.mon(self.faceUp)],
        box.x + 1, box.y + 3)
    elseif self.phase == "choose" and chosen then
      Chrome.cursor(box.x, box.y + 3)
    end
  end
end

function CardFlip:drawPanel()
  Chrome.clear()
  self:drawBoard()
  self:drawCards()
  Chrome.textbox(COIN_BOX_X, COIN_BOX_Y, COIN_BOX_W - 2, COIN_BOX_H - 2)
  Chrome.print("COIN", COIN_LABEL_X, COIN_LABEL_Y)
  Chrome.print(Chrome.number(self:coins(), 4, true), COIN_VALUE_X, COIN_VALUE_Y)
  if self.lines then
    Chrome.textbox(TEXT_BOX_X, TEXT_BOX_Y, TEXT_BOX_W - 2, TEXT_BOX_H - 2)
    for i, line in ipairs(self.lines) do
      Chrome.print(line, TEXT_X, TEXT_Y + (i - 1) * TEXT_LINE)
    end
  end
  if self.phase == "bet" then
    local col, row = self:cursorCell()
    Chrome.cursor(col - 1, row)
  end
  if self.phase == "ask" or self.phase == "again" then
    -- YesNoBox: a 6x5 box at (14,7) with YES at (16,8) and NO at (16,10).
    Chrome.textbox(14, 7, 4, 3)
    Chrome.print("YES", 16, 8)
    Chrome.print("NO", 16, 10)
    Chrome.cursor(15, 8 + (self.choice - 1) * 2)
  end
end

function CardFlip:draw()
  self:drawPanel()
end

function CardFlip:drawWidescreen(winW, winH)
  local G = love.graphics
  G.setColor(1, 1, 1, 1)
  G.rectangle("fill", 0, 0, winW, winH)
  local scale = Chrome.fitScale(winW, winH)
  G.push()
  G.translate(math.floor((winW - 160 * scale) / 2),
    math.floor((winH - 144 * scale) / 2))
  G.scale(scale, scale)
  self:drawPanel()
  G.pop()
end

return CardFlip
