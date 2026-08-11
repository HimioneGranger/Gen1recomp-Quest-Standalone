-- Route-bot core for the Gold port.
--
-- Interprets tests/drivers/gold/route.lua -- objectives derived from
-- docs/gold-walkthrough/asm-walk -- against a live game, through the adapter in
-- tests/drivers/gold/adapter.lua.  Nothing here names a Gen 2 module; swap the
-- adapter and this drives Gen 1.
--
-- The shape differs from the Gen 1 bot on purpose.  tests/drivers/route.lua
-- interprets PokeBotBad's tile-by-tile waypoints, so its route says "walk to
-- (8,30), then (8,24)".  The asm-walk has no walking paths at all -- it has
-- OBJECTIVES ("warp 1 at (6,3)", "talk to ELMSLAB_ELM at (5,2)") plus the
-- EVENT_* each one sets.  So the route here is a list of goals and ALL the
-- navigation is the bot's problem: local BFS inside a map, and a second BFS
-- over the map graph to reach the map an objective names.  That is more work
-- here and far less work per route row, and it means a map whose geometry the
-- port gets slightly wrong is routed around rather than fatal.
--
-- Three feedback memories exist because a planner that cannot learn will retry
-- the same failing step until the watchdog kills it.  All three are lessons
-- the Gen 1 bot paid for first (see tests/drivers/route.lua's header):
--
--   walls  BFS plans over a static tile test that knows nothing about ledges,
--          directional blocks or an NPC parked in a doorway.  A step the
--          engine refuses is remembered so the next plan avoids it, and
--          forgotten the moment we do stand there -- otherwise a wandering
--          NPC blacklists a corridor permanently.
--   seams  a map-graph edge that did not work gets PRICED, never banned.
--          Banning severed the Gen 1 map graph outright: crossing a seam is
--          flaky, so the only road north out of a town could reach two
--          failures and become impossible.  An expensive seam is still taken
--          when it is the only way through.
--   deaths per-map blackout counts, so the bot gets more careful about a place
--          that keeps killing it instead of walking back in at 3 HP.

local Bot = {}
Bot.__index = Bot

local A = dofile("tests/drivers/gold/adapter.lua")
Bot.adapter = A

-- The region-aware map graph, generated from the extracted cache by
-- tools/goldwalk/mapgraph.lua.  See Bot:planTravel for what it buys.
local REGIONS = dofile("tests/drivers/gold/map_regions.lua")

-- Declared up here rather than beside the pathfinder because Bot:turnAway --
-- the escape hatch for an NPC whose conversation keeps restarting -- walks it
-- too, and a `local` further down the file is not in scope there: DELTA
-- resolved to the global nil and `pairs(nil)` crashed the run out of
-- clearDialogue, which is a fatal error in the one place that exists to
-- recover from a stuck conversation.
local DELTA = {
  up    = {  0, -1 },
  down  = {  0,  1 },
  left  = { -1,  0 },
  right = {  1,  0 },
}

-- ---------------------------------------------------------------------------
-- frame plumbing
-- ---------------------------------------------------------------------------
-- Everything in this file runs inside main.lua's driver coroutine: one yield is
-- one logic step.  POKEPORT_SPEED only changes how many of those main.lua runs
-- per rendered frame, so nothing here needs to know the multiplier.

local frames = 0

function Bot:wait(n)
  for _ = 1, (n or 1) do
    frames = frames + 1
    self.silentFrames = self.silentFrames + 1
    -- Silent-stall backstop.  Every loop in this file waits through here, so a
    -- run that stops logging but keeps spinning still passes through this
    -- counter on the frames it burns.  The talkative case is caught by the
    -- repeat detector in :say().
    if self.silentFrames > self.stallFrames then
      error({ botStall = true,
              why = ("no progress for %d frames"):format(self.silentFrames) })
    end
    coroutine.yield()
  end
end

function Bot:frames() return frames end

-- ---------------------------------------------------------------------------
-- logging + stuck detection
-- ---------------------------------------------------------------------------

function Bot:say(...)
  local parts = {}
  for i = 1, select("#", ...) do
    parts[#parts + 1] = tostring((select(i, ...)))
  end
  local line = table.concat(parts, " ")
  print(("[gold %6d] %s"):format(frames, line))
  if self.logFile then
    self.logFile:write(("%6d %s\n"):format(frames, line))
    self.logFile:flush()          -- a long run is normally ended by killing the
                                  -- process, and a block-buffered tail loses
                                  -- exactly the part worth reading
  end
  self:recordLine(line)
end

-- "Stuck" from the outside looks like the log repeating itself.  Every retry
-- loop below narrates each attempt, so the same line cycling N times without a
-- new objective means we are trying the same thing and getting the same
-- result.  Detected here rather than per-loop so no loop can forget to.
function Bot:recordLine(line)
  local h = self.history
  h[#h + 1] = line
  if #h > 200 then table.remove(h, 1) end
  local repeats = 0
  for i = #h, 1, -1 do
    if h[i] == line then
      repeats = repeats + 1
      if repeats >= self.stuckRepeats then
        error({ botStall = true,
                why = ("repeated %q %d times"):format(line, repeats) })
      end
    end
    if #h - i > 40 then break end   -- only look at the recent window: the same
                                    -- line an hour ago is not a loop
  end
end

-- Called whenever something genuinely advanced, which is what makes both
-- detectors safe to be aggressive.
function Bot:progress()
  self.silentFrames = 0
  self.history = {}
end

-- ---------------------------------------------------------------------------
-- memories
-- ---------------------------------------------------------------------------

local function wallKey(mapId, x, y)
  return ("%s#%d,%d"):format(tostring(mapId), x, y)
end

function Bot:noteWall(mapId, x, y)
  self.walls[wallKey(mapId, x, y)] = (self.walls[wallKey(mapId, x, y)] or 0) + 1
end

-- Standing on a cell proves it passable after all.  Keeps a temporary blocker
-- (an NPC mid-stroll, a tree before we have CUT) out of the permanent record.
function Bot:clearWall(mapId, x, y)
  self.walls[wallKey(mapId, x, y)] = nil
end

function Bot:wallCost(mapId, x, y)
  local n = self.walls[wallKey(mapId, x, y)] or 0
  return n * 40         -- a price, not a ban: a refused cell that is the only
                        -- way through is still taken, just last
end

local function seamKey(from, to) return tostring(from) .. ">" .. tostring(to) end

function Bot:noteSeam(from, to)
  local k = seamKey(from, to)
  self.seams[k] = (self.seams[k] or 0) + 1
end

function Bot:clearSeam(from, to)
  self.seams[seamKey(from, to)] = nil
end

function Bot:seamCost(from, to)
  return (self.seams[seamKey(from, to)] or 0) * 8
end

-- ---------------------------------------------------------------------------
-- input helpers
-- ---------------------------------------------------------------------------

function Bot:tap(button, hold)
  A.press(self.g, button)
  self:wait(hold or 2)
  A.release(self.g, button)
  self:wait(2)
end

-- Wait out anything that has taken control (script, text box, cutscene move),
-- mashing A so text advances.  `answers` is a queue consumed by choice boxes:
-- "yes" presses A, "no" presses B.  Everything unanswered defaults to YES,
-- which is what ChoiceBox starts its cursor on.
function Bot:clearDialogue(answers, budget)
  local queue = {}
  for i, v in ipairs(answers or {}) do queue[i] = v end
  local pressed = 0
  local restarts, wasBusy = 0, true
  for _ = 1, (budget or 4000) do
    local busy = A.busy(self.g)

    -- Re-trigger guard.  Our own A press is what closes the last page, and if
    -- the player is still facing the NPC the very next press runs
    -- World:interact and starts the SAME conversation again -- so a bot stood
    -- in front of a chatty NPC talks to them forever.  (Seen on every run:
    -- "See for yourself. He's w..." in Ilex Forest, for seconds at a time.)
    -- Count how often the box comes back after closing; once it is clearly a
    -- loop, turn away so an A press cannot reach them, and stop.
    if busy and not wasBusy then
      restarts = restarts + 1
      if restarts >= 2 then
        self:say("dialogue: conversation keeps restarting -- turning away")
        self:turnAway()
        return true
      end
    end
    wasBusy = busy

    if not busy then
      if pressed > 0 then self:progress() end
      return true
    end
    if A.inBattle(self.g) then
      self:fightBattle()
    elseif A.namingScreenUp(self.g) then
      -- Take the default name rather than typing one letter per A press.
      self:say("dialogue: naming screen -- accepting the species name")
      A.dismissNaming(self.g)
      self:progress()
    elseif A.partyMenuUp(self.g) then
      -- A forced switch: pick a mon that can still fight, or back out.
      if A.chooseHealthyPartyMon(self.g) then
        self:say("battle: sending out the next healthy mon")
        self:tap("a")
      else
        self:tap("b")
      end
      self:progress()
    else
      local answer = table.remove(queue, 1)
      self:tap(answer == "no" and "b" or "a")
      pressed = pressed + 1
      -- Advancing a cutscene IS progress.  Without this the silent-stall
      -- backstop counted a long scene as a hang and killed the run inside it --
      -- Sprout Tower's rival encounter runs well past the 5000-frame budget.
      -- Nothing is lost by trusting the loop's own `budget` instead: it is
      -- bounded, and it reports rather than spins.
      self:progress()
    end
  end
  self:say(("dialogue: still busy after %d presses -- %s")
    :format(pressed, A.busyReason(self.g)))
  return false
end

-- Face a direction with nothing talkable in it, so a stray A press cannot
-- reopen the conversation we just escaped.  Prefers a direction whose facing
-- cell holds no NPC; falls back to any.
function Bot:turnAway()
  local map = A.map(self.g)
  local x, y = A.pos(self.g)
  if not (map and x) then return end
  for dir, d in pairs(DELTA) do
    if not A.npcAt(self.g, x + d[1], y + d[2]) and dir ~= A.facing(self.g) then
      self:face(dir)
      return
    end
  end
end

-- ---------------------------------------------------------------------------
-- battles
-- ---------------------------------------------------------------------------
-- Deliberately dumb: FIGHT and the first move, every turn.  The route walks
-- where the walkthrough walks and levels normally, so it does not need the
-- speedrun's frame-perfect tactics -- and a wrong-but-simple battle policy
-- fails visibly (the party faints) rather than subtly.

function Bot:fightBattle()
  local start = frames
  local mapBefore = A.mapId(self.g)
  -- One switch per battle: after it the fighter is out and the weakling has
  -- already banked its participation.
  self.switchedThisBattle = false
  -- One status cure per battle (see A.statusCure): re-inflicted paralysis is
  -- not worth chasing with the Champion's FULL RESTOREs.
  self.curedStatusThisBattle = false
  self:say("battle: fighting")
  local overruns = 0
  local lastMessage, lastPhase
  while A.inBattle(self.g) do
    local phase = A.battlePhase(self.g)

    -- Narrate the battle.  A wedged fight is otherwise a black box: the run
    -- reports "no end" and nothing about the cause.  Logging the message box
    -- and the phase as they change turns that into the engine's own words --
    -- which is how the catch tutorial and the out-of-PP stall were both
    -- identified.  Only on CHANGE, so a 3000-frame fight is a handful of lines
    -- and the repeat detector in :say() is not tripped by ordinary combat.
    local message = A.battleMessage(self.g)
    if message ~= lastMessage or phase ~= lastPhase then
      lastMessage, lastPhase = message, phase
      if message then
        self:say(("battle: [%s] %s"):format(tostring(phase), tostring(message)))
      end
    end

    if phase == "choose-forget" then
      -- A level-up move on a full set (AskLearnMove).  The masher's blind A
      -- would drop slot 1 -- often an HM or the good move.  Point the cursor at
      -- the weakest non-HM move first, or keep the four if the newcomer is no
      -- upgrade.  The whole endgame turns on this: a starter that never learns
      -- a move past its level-1 attack cannot out-damage Clair or the Elite
      -- Four, so it laps forever.  Handled and looped WITHOUT falling through to
      -- the unconditional A below -- a stray A on this phase drops slot 1.
      local button = A.resolveForgetMenu(self.g)
      if button then
        self:say(("battle: forget menu -- %s")
          :format(button == "a" and "dropping weakest move" or "keeping moveset"))
        self:tap(button)
      else
        self:tap("a")           -- still on the "wants to learn" prompt line
      end
      self:progress()
    elseif phase == "menu" then
      -- Pin the cursor before every confirm.  Without this a failed escape
      -- leaves the menu parked on RUN and the masher spends the rest of the
      -- fight re-attempting a run it has already been refused.
      --
      -- The catch tutorial is the exception and it wedged a whole run: it has
      -- no player mon, so FIGHT drops into an empty move list that A cannot
      -- submit and B is the only way out of.  PACK is its real path.
      -- Catching rides inside the ordinary battle handler, because a wild
      -- encounter can start anywhere -- mid-walk, mid-travel -- and every one
      -- of those paths already funnels through here.  (It briefly lived in
      -- tryRun by accident, which shares the same `local phase` line: the bot
      -- then only ever threw a ball when a battle OVERRAN, so 88 encounters
      -- produced zero throws.)
      if self.catchWanted and A.isWildBattle(self.g)
          and self.catchWanted[A.enemySpecies(self.g)]
          and A.hasItem(self.g, self.catchBall) then
        -- Throw at full health and never attack a species we came to catch: by
        -- the time the bot wants a SLOWPOKE its starter is ~L15 and one EMBER
        -- kills a L6 target outright, so "soften first" threw nothing at all.
        self:say(("battle: throwing a %s at %s (hp %.2f)")
          :format(self.catchBall, tostring(A.enemySpecies(self.g)),
                  A.enemyHpFraction(self.g)))
        A.throwBall(self.g, self.catchBall)
        self:progress()
        self:wait(2)
      elseif self.switchTrain and not self.switchedThisBattle
          and not A.battleIsTutorial(self.g)
          and A.leadIsWeakest(self.g) then
        -- Switch training: the weakling has been SENT OUT, which is all it
        -- needs to be a participant.  Hand the fight to whoever can win it
        -- before the weakling is hit; the incoming mon takes this turn's
        -- attack, so the participant survives and collects its share.
        self.switchedThisBattle = true
        if A.openBattleParty(self.g) then
          self:wait(2)
          if A.chooseStrongestPartyMon(self.g) then
            self:say("battle: switch-training -- handing over to the fighter")
            self:tap("a")
          else
            self:tap("b")
          end
          self:progress()
          self:wait(2)
        end
      elseif A.statusCure(self.g) and not self.curedStatusThisBattle then
        -- Cure a turn-costing status (paralysis is the one that matters) with
        -- a FULL_RESTORE.  Once per battle: re-inflicted paralysis is a lost
        -- cause to keep curing, and the FULL_RESTOREs are the Champion's.  This
        -- is the whole difference in the Clair fight -- a paralyzed Fire lead
        -- loses the KINGDRA attrition war; a cured one outspeeds and wins.
        local cure = A.statusCure(self.g)
        self.curedStatusThisBattle = true
        self:say(("battle: curing %s with a %s")
          :format(tostring(A.leadStatus(self.g)), cure))
        A.useItem(self.g, cure)
        self:progress()
        self:wait(2)
      elseif A.leadHpFraction(self.g) < 0.6
          and A.bestHeal(self.g, A.leadHpFraction(self.g))
          and not A.battleIsTutorial(self.g) then
        -- Drink something before the mon that is carrying the run faints.
        -- 0.6, not 0.35: the Elite Four hit hard enough to cross a third of a
        -- health bar in one turn, so a 35% trigger is a trigger that fires
        -- after the mon is already dead.
        -- The policy had no items in it at all, so every leader from Whitney
        -- on had to be out-levelled instead -- hundreds of thousands of frames
        -- of grinding to buy what a SUPER POTION buys in one turn.
        --
        -- WHICH item is A.bestHeal's problem, and it is rationed: the trigger
        -- stays generous, but between 0.35 and 0.6 it hands back the weakest
        -- thing that still heals a quarter of the bar, keeping the FULL
        -- RESTOREs for the room where the run actually ends.
        local item = A.bestHeal(self.g, A.leadHpFraction(self.g))
        self:say(("battle: using a %s (hp %.2f)")
          :format(item, A.leadHpFraction(self.g)))
        A.useItem(self.g, item)
        self:progress()
        self:wait(2)
      else
        A.setBattleMenu(self.g, A.battleIsTutorial(self.g)
          and A.BATTLE_MENU_PACK or A.BATTLE_MENU_FIGHT)
      end
    elseif phase == "moves" then
      -- Pick a move that can actually be used, hardest-hitting first.  Slot 1
      -- is not a safe default: at 0 PP the turn silently never happens, and
      -- with no Struggle in the port that is a battle which can never end.
      if not A.pickBattleMove(self.g) then
        if A.playerMoveCount(self.g) == 0 then
          self:tap("b")            -- tutorial-style empty list: back out
        end
        -- Otherwise every move is dry, and that is now the engine's business,
        -- not the bot's: Battle:playerAttack substitutes STRUGGLE for a mon
        -- with nothing left to spend, exactly as the cart does.  So confirm
        -- whatever the cursor is on and let the turn happen.
        --
        -- The bot used to try to ESCAPE here and abort the run when a trainer
        -- refused -- which was right while the port had no Struggle and is
        -- wrong now: escaping a wild fight it could win by struggling is how
        -- a run ends up circling a route forever, never leveling and never
        -- fainting.
      end
    end
    -- The forget branch already pressed its own button and must NOT get the
    -- masher's A -- a stray A on that phase is a blind slot-1 drop.
    if phase ~= "choose-forget" then
      self:tap("a")
    end
    -- A battle IS progress.  Without this the silent-stall backstop in :wait()
    -- counted the whole fight as "nothing happening" and killed the run
    -- mid-fight -- and because the next route row then found the battle still
    -- up, every following row stalled the same way.  The battle's own budget
    -- below is what catches a genuinely wedged fight.
    self:progress()
    if frames - start > self.battleFrames then
      overruns = overruns + 1
      start = frames
      self:say(("battle: %d frames with no end (phase=%s, lead hp=%.2f, party=%d)")
        :format(overruns * self.battleFrames, tostring(A.battlePhase(self.g)),
                A.leadHpFraction(self.g), A.partySize(self.g)))
      -- A battle that will not end is usually one neither side can win.  The
      -- masher always picks the first move, so a starter holding TACKLE that
      -- meets a GASTLY is in a stalemate: Normal cannot touch Ghost, and the
      -- Ghost's own status moves do no damage back -- the log shows lead HP
      -- frozen for tens of thousands of frames.  Running is the correct answer
      -- and costs nothing on a wild fight; on a trainer it simply fails and we
      -- go back to mashing.
      -- Never try to escape a battle we are deliberately spending balls on:
      -- the overrun handler was cutting catch attempts short, which is why five
      -- throws at one SLOWPOKE ended with the bot fighting it instead.
      if self.catchWanted and A.isWildBattle(self.g)
          and self.catchWanted[A.enemySpecies(self.g)] then
        self:say("battle: overrunning, but this is a catch -- keeping at it")
      elseif not self:tryRun() then
        self:say("battle: could not run (trainer?), continuing")
      end
      if overruns >= 3 then
        self:say("battle: giving up on this fight")
        return false
      end
    end
  end
  self:progress()
  -- A wipe is not an error: the engine revives the party and warps to the
  -- spawn point, so a blackout is really a slow free heal.  It only becomes a
  -- problem when it keeps happening in the same place, which is what the
  -- per-map count is for -- and what tells a human WHERE the route is too hard
  -- rather than just that it stalled.
  if not A.partyHealthy(self.g) then
    local where = mapBefore or "?"
    self.deaths[where] = (self.deaths[where] or 0) + 1
    self:say(("battle: party wiped on %s (%d here)")
      :format(tostring(where), self.deaths[where]))
  end
  self:say("battle: done")
end

function Bot:deathsAt(mapId)
  return self.deaths[mapId or ""] or 0
end

-- Escape a wild battle.  Returns true once the battle is gone, false if it is
-- still up after a fair number of attempts -- which is what a trainer battle
-- looks like, since RUN is refused there.
function Bot:tryRun()
  for _ = 1, 80 do
    if not A.inBattle(self.g) then
      self:progress()
      return true
    end
    if A.partyMenuUp(self.g) then
      if A.chooseHealthyPartyMon(self.g) then self:tap("a") else self:tap("b") end
      self:progress()
    end

    local phase = A.battlePhase(self.g)

    -- Catching rides inside the ordinary battle handler rather than a separate
    -- one, because a wild encounter can start anywhere -- mid-walk, mid-travel
    -- -- and every one of those paths already funnels into here.  `catchWanted`
    -- is set for the duration of a `catch` route row.
    if phase == "menu" then
      A.setBattleMenu(self.g, A.BATTLE_MENU_RUN)
      self:tap("a")
    elseif phase == "moves" then
      self:tap("b")            -- back out of the move list to the main menu
    else
      self:tap("a")            -- a message is up; advance it
    end
  end
  return not A.inBattle(self.g)
end

-- ---------------------------------------------------------------------------
-- local pathfinding
-- ---------------------------------------------------------------------------
-- Dijkstra rather than plain BFS, because the wall memory is a COST and not a
-- wall: a cell the engine refused twice should be avoided if there is any other
-- way round and still used when there is not.

-- src/world/gen2/Player.lua: a walk is 16 frames, a turn-in-place 4.
local TURN_FRAMES = 4

-- Map connections are keyed by COMPASS word ("west"); the pad is named by
-- SCREEN direction ("left").  Normalising at the boundary is deliberate: the
-- first run held a button called "west", which no input source has ever heard
-- of, so the bot walked at the east edge of New Bark Town waiting for Route 29
-- to appear.  Everything below this line speaks pad directions only.
local BUTTON_DIR = {
  up = "up", down = "down", left = "left", right = "right",
  north = "up", south = "down", west = "left", east = "right",
}

function Bot.button(dir) return BUTTON_DIR[dir] end

-- Can we get onto the water at all right now?  Cached per attempt because
-- partyMoveUser walks the party and re-checks the badge every call, and the
-- planner asks about thousands of cells.
function Bot:canSurf()
  if self.surfKnown == nil then
    self.surfKnown = A.surfUser(self.g) ~= nil
  end
  return self.surfKnown
end

function Bot:forgetSurf() self.surfKnown = nil end

function Bot:passable(map, x, y, goalX, goalY)
  if x == goalX and y == goalY then
    -- The goal is exempt from the walkability test.  Half the objectives in
    -- the route are cells the player can never STAND on -- a door tile, an
    -- item ball, an NPC -- and the caller either warps off it or only needs to
    -- be adjacent.  Reachability is what the search decides; what happens on
    -- arrival is the action's business.
    return map:inBounds(x, y)
  end
  if not A.walkable(self.g, map, x, y) then
    -- Water is passable to a party that can SURF, even while we are still on
    -- foot: the step onto it is what starts the surf, exactly as it does for a
    -- player pressing A at the shore.  Without this the planner drew the coast
    -- as a wall, so Cianwood, Route 27, the Whirl Islands and the Dragon's Den
    -- were all "unreachable" and only a teleport got the route past them.
    if not (self:canSurf() and A.isWater(map, x, y)) then return false end
  end
  if A.npcAt(self.g, x, y) then return false end
  -- A warp TILE is not a cell you pass through, it is a cell you LEAVE THE MAP
  -- on.  Planning a route across one produces a path that is a lie: the walk
  -- ends somewhere else entirely, several steps before it meant to.  That is
  -- how the Route 46 gate trapped the bot -- it lands you on the warp back, so
  -- every plan out of Route 46 stepped over the neighbouring warp tile and
  -- returned to the gate, twice a second, until the loop guard fired.  A warp
  -- may still be a DESTINATION, which is the exemption above.
  --
  -- The test is the TILE, not the warp_event coordinate: CheckWarpTile reads
  -- the collision, so a warp_event on plain floor never fires.  Ecruteak Gym is
  -- the map that proves it -- several of its thirty hole coordinates are
  -- ordinary floor, and they are the safe path between the pits, so refusing
  -- all of them cut the gym in half and put Morty out of reach.
  if A.isWarpTile(map, x, y) then return false end
  return true
end

-- Where a single press of `dir` from (x, y) comes to rest.
--
-- Ice (COLL_ICE) keeps the player moving in the same direction until they land
-- on a non-ice cell or bump something -- CheckStandingOnIce / .CheckForced in
-- the engine.  The planner's graph is therefore over REST positions, not over
-- every walkable cell: a press is one edge, and its endpoint is wherever the
-- slide stops.  Off ice this is ordinary adjacency (one cell).
function Bot:slideRest(map, x, y, dir, goalX, goalY)
  local d = DELTA[dir]
  if not d then return nil end
  local cx, cy = x + d[1], y + d[2]
  -- GetMovementPermissions can veto the leave (standing on a side-wall tile)
  -- or the entry (Gold's neighbour arm: no stepping DOWN onto an UP_WALL).
  -- A refused step off a LEDGE tile is not a dead end but a two-cell hop
  -- (.TryJump): Burned Tower B1F's landing pockets drain only this way.
  if not A.stepPermitted(map, x, y, dir)
      or not self:passable(map, cx, cy, goalX, goalY) then
    local hop = A.ledgeFacings(map, x, y)
    if hop and hop[dir] then
      local hx, hy = x + d[1] * 2, y + d[2] * 2
      if self:passable(map, hx, hy, goalX, goalY) then
        return hx, hy, 2
      end
    end
    return nil
  end
  local steps = 1
  while A.isIce(map, cx, cy) do
    -- The slide re-runs the same permission test per cell, which is what
    -- rests it on the last ice cell above an UP_WALL strip -- the rest
    -- position Ice Path 1F's HM07 pocket is entered from.
    if not A.stepPermitted(map, cx, cy, dir) then break end
    local nx, ny = cx + d[1], cy + d[2]
    if not self:passable(map, nx, ny, goalX, goalY) then break end
    cx, cy, steps = nx, ny, steps + 1
  end
  return cx, cy, steps
end

-- Cheapest path from the player to (goalX, goalY) as a list of press
-- directions, or nil.  Cost is cells travelled plus the wall memory's price.
-- On ice each press may cover several cells and only REST positions are nodes,
-- so a cell the player would slide past is not a place the path can ask to
-- stand -- which is what made every Ice Path boulder push report
-- "could not stand at (x,y) to push" when the planner still thought ice was
-- ordinary floor.
function Bot:planPath(goalX, goalY)
  local sx, sy = A.pos(self.g)
  if not sx then return nil end
  return self:planPathFrom(sx, sy, goalX, goalY)
end

-- The same search from an arbitrary start.  enterWarp's step-off needs it:
-- next to a one-way door the two candidate cells are on DIFFERENT SIDES of
-- the map (Blackthorn's Ice Path exit has the cliff corridor above and the
-- hop into town below), and only a path check can say which one still
-- reaches the target.
function Bot:planPathFrom(sx, sy, goalX, goalY)
  local map = A.map(self.g)
  if not map then return nil end
  local mapId = map.id
  if not sx then return nil end
  if sx == goalX and sy == goalY then return {} end

  local function key(x, y) return y * 4096 + x end
  local dist = { [key(sx, sy)] = 0 }
  local prev = {}
  -- A binary heap is overkill for maps this size (the biggest Johto map is
  -- well under 4k cells) and a linear scan keeps the code readable.
  local open = { { x = sx, y = sy, d = 0 } }
  local seen = {}

  while #open > 0 do
    local bi, best = 1, open[1]
    for i = 2, #open do
      if open[i].d < best.d then bi, best = i, open[i] end
    end
    table.remove(open, bi)
    local bk = key(best.x, best.y)
    if not seen[bk] then
      seen[bk] = true
      if best.x == goalX and best.y == goalY then
        local path, cx, cy = {}, goalX, goalY
        while not (cx == sx and cy == sy) do
          local step = prev[key(cx, cy)]
          if not step then return nil end
          table.insert(path, 1, step.dir)
          cx, cy = step.x, step.y
        end
        return path
      end
      for dir, _ in pairs(DELTA) do
        local nx, ny, steps = self:slideRest(map, best.x, best.y, dir,
                                             goalX, goalY)
        if nx then
          -- Water is passable but not free: getting on it costs a field move
          -- and a prompt, so a dry route of similar length should win.
          local nd = best.d + steps + self:wallCost(mapId, nx, ny)
                   + ((not A.surfing(self.g) and A.isWater(map, nx, ny))
                      and 3 or 0)
          local nk = key(nx, ny)
          if nd < (dist[nk] or math.huge) then
            dist[nk] = nd
            prev[nk] = { x = best.x, y = best.y, dir = dir }
            open[#open + 1] = { x = nx, y = ny, d = nd }
          end
        end
      end
    end
  end
  return nil
end

-- Turn in place to face `dir`, without stepping.
--
-- Pressing a direction you are not already facing TURNS and does not step
-- (Player:tryMove:52 -- the turnArmed arm returns "turned" before the
-- collision check).  A bot that treats that first press as a step reads the
-- turn as a refusal and learns a wall that is not there, so turning is its own
-- operation.  turnArmed only re-arms on a frame with no direction held
-- (World:step:6427), which is why the release matters.
function Bot:face(dir)
  if A.facing(self.g) == dir then return end
  A.hold(self.g, dir)
  self:wait(2)
  A.releaseDirs(self.g)
  self:wait(TURN_FRAMES + 4)     -- let turnTimer expire and turnArmed re-arm
end

-- Exactly one cell in `dir`.
--
-- The subtlety that cost the first run: World:step starts the NEXT step in the
-- same frame the previous one lands (it falls through p:update() straight into
-- movePlayer with heldDir still set), so a held direction walks a whole
-- corridor until something blocks it.  The first version of this held until
-- the cell changed and only then released -- which meant every "step" ran to
-- the far wall, and walkTo ping-ponged between the two ends of Mom's kitchen
-- forever.  So: hold only long enough for movePlayer to fire once, release,
-- and let the in-flight step finish on its own.
--
-- The engine's own verdict ("moved" / "blocked" / "edge") never reaches a
-- driver, so the observable equivalent is whether the cell changed.  A step
-- that did not move is what feeds wall memory.
function Bot:stepDir(dir)
  local mapId = A.mapId(self.g)

  self:face(dir)
  if A.busy(self.g) or A.mapId(self.g) ~= mapId then
    -- Something took the world between planning and stepping.  Reporting it as
    -- "moved" is right -- the caller must re-plan either way -- but it used to
    -- be SILENT, and a walk whose every step bailed here looked in the log like
    -- a walk that never happened: no refusals, no movement, 330 frames a try.
    if A.mapId(self.g) == mapId then
      self:say(("step %s deferred: %s"):format(dir, A.busyReason(self.g)))
    end
    return true
  end

  local x0, y0 = A.pos(self.g)

  -- Stepping from the shore onto water is not a step, it is a field move.
  -- World:useFieldMove reads the tile the player is FACING, so the face above
  -- is already the argument; all that is left is to ask, answer the "Want to
  -- SURF?" prompt, and let the queued script put us afloat.  The step itself is
  -- then the ordinary one below.
  local map0 = A.map(self.g)
  local d0 = DELTA[dir]
  if map0 and not A.surfing(self.g) and self:canSurf()
      and A.isWater(map0, x0 + d0[1], y0 + d0[2]) then
    self:say(("surf: entering the water at (%d,%d)")
      :format(x0 + d0[1], y0 + d0[2]))
    if A.startSurf(self.g) then
      self:wait(8)
      self:clearDialogue({ "yes" }, 3000)
      self:progress()
      -- The surf script walks the player onto the water itself, so the cell has
      -- already changed and there is nothing left to step.
      local sx, sy = A.pos(self.g)
      if sx ~= x0 or sy ~= y0 then return true end
    end
  end

  -- A whirlpool bars the step the way the shore bars a walk, and the way
  -- through is HM06 (GLACIERBADGE gated): Script_UsedWhirlpool swaps the
  -- facing block for plain water, after which the ordinary step below just
  -- works.  Route 27's crossing and the Dragon Fang pocket are both behind
  -- one of these.
  if map0 and A.surfing(self.g)
      and A.isWhirlpool(map0, x0 + d0[1], y0 + d0[2])
      and A.whirlpoolUser(self.g) then
    self:say(("whirlpool: clearing (%d,%d)"):format(x0 + d0[1], y0 + d0[2]))
    self:face(dir)
    if A.useWhirlpool(self.g) then
      self:wait(8)
      self:clearDialogue({ "yes" }, 3000)
      self:progress()
    end
  end

  -- A waterfall is climbed by the field move, not by steps:
  -- Script_UsedWaterfall forces UP one cell at a time until the player is off
  -- the falls, so by the time it returns the position has jumped several
  -- cells and the current plan is stale.  Report moved and let the caller
  -- re-plan from the top.  (Coming DOWN rides the current automatically --
  -- .CheckTile -- so only the upward press needs the move.)
  if map0 and dir == "up" and A.surfing(self.g)
      and A.isWaterfall(map0, x0, y0 - 1)
      and A.waterfallUser(self.g) then
    self:say(("waterfall: climbing from (%d,%d)"):format(x0, y0))
    self:face(dir)
    if A.useWaterfall(self.g) then
      self:wait(8)
      self:clearDialogue({ "yes" }, 6000)
      for _ = 1, 900 do
        if not A.moving(self.g) and not A.busy(self.g) then break end
        self:wait(1)
      end
      local cx, cy = A.pos(self.g)
      if cx ~= x0 or cy ~= y0 then
        self:progress()
        return true
      end
    end
  end

  A.hold(self.g, dir)
  self:wait(2)                   -- one fixed step under the hold is one
                                 -- movePlayer call; a second is a no-op
                                 -- because the player is already moving
  A.releaseDirs(self.g)

  -- Let the press finish.  Off ice that is one STEP_FRAMES landing.  On ice
  -- CheckForced keeps starting the next cell after release, so "not moving"
  -- only becomes true at the REST position -- allow enough frames for a long
  -- Ice Path corridor (a cell is 16 frames; 40 cells is well under this).
  for _ = 1, 700 do
    if A.busy(self.g) or A.mapId(self.g) ~= mapId then break end
    if not A.moving(self.g) then break end
    self:wait(1)
  end
  self:wait(1)

  local x1, y1 = A.pos(self.g)
  local d = DELTA[dir]
  local wantX, wantY = x0 + d[1], y0 + d[2]
  local moved = A.mapId(self.g) ~= mapId or x1 ~= x0 or y1 ~= y0
  if A.mapId(self.g) ~= mapId then
    self:progress()
    return true
  end
  if not moved then
    -- The engine refused the first cell.  That is a real wall.
    self:noteWall(mapId, wantX, wantY)
    return false
  end
  -- A press that moved is a success even when it did not stop on the adjacent
  -- cell: ice slides, and planPath already asked for the REST position.  The
  -- old one-cell check priced every ice corridor as a wall and made the Ice
  -- Path unsolvable on foot.
  --
  -- The remaining case is a script that PUT us somewhere else after a normal
  -- step -- Route 32's Miracle Seed man at (18,8) follows the player, walks
  -- them two cells back north, and re-runs on every pass.  Pricing the cell
  -- we were shoved off makes the parallel column at x=19 win next time.
  -- A ledge hop is the other press that legitimately overshoots the adjacent
  -- cell: .TryJump lands two cells out, and calling that "a script moved us"
  -- priced the wall past every ledge and buried the hop under wall memory.
  local hop = map0 and A.ledgeFacings(map0, x0, y0)
  if hop and hop[dir] and x1 == x0 + d[1] * 2 and y1 == y0 + d[2] * 2 then
    self:clearWall(mapId, x1, y1)
    self:progress()
    return true
  end
  if not (x1 == wantX and y1 == wantY) and not A.isIce(A.map(self.g), wantX, wantY)
      and not A.isIce(A.map(self.g), x0, y0) then
    self:noteWall(mapId, wantX, wantY)
    self:say(("step %s from (%d,%d) ended at (%d,%d), not (%d,%d) -- a script "
              .. "moved us"):format(dir, x0, y0, x1, y1, wantX, wantY))
  else
    self:clearWall(mapId, x1, y1)
  end
  self:progress()
  return true
end

-- Walk to a cell on the current map.  Re-plans after every step: NPCs move,
-- scripts fire, and a plan made six steps ago is a guess about a world that
-- has since changed.
function Bot:walkTo(goalX, goalY, opts)
  opts = opts or {}
  local map0 = A.mapId(self.g)
  local lastX, lastY, stuckAttempts = nil, nil, 0
  for attempt = 1, (opts.attempts or 60) do
    if A.busy(self.g) then
      -- Sit out whatever took over -- but remember where we were standing when
      -- it started, because a script that MOVES the player is the one kind of
      -- obstacle the tile test can never see.
      --
      -- Route 32's Miracle Seed man is the case that mattered.  His coord event
      -- at (18,8) follows the player, walks them two cells back north, and is
      -- guarded by an item flag rather than a scene, so it re-runs on every
      -- pass -- faithfully, since on the cart the way past is the parallel
      -- column at x=19.  The bot could not see any of that: the step onto
      -- (18,8) succeeded, so the cell looked fine, and the shove happened later
      -- while dialogue was being cleared.  It re-planned the same path forever,
      -- which left the only road to Azalea, Ilex Forest and Goldenrod
      -- impassable and made every run reach that half of Johto by teleport.
      --
      -- Pricing the cell we were shoved OFF is the general form of the fix, and
      -- it prices only the specific tile that did it.  Three notes rather than
      -- one because arriving on the cell clears the memory, and the arrival is
      -- exactly what triggers the shove.
      local bx, by = A.pos(self.g)
      local bmap = A.mapId(self.g)
      local bmapObj = A.map(self.g)
      local leftWarp = bmapObj and bx and A.isWarpTile(bmapObj, bx, by)
      self:say(("walk: waiting on %s"):format(A.busyReason(self.g)))
      self:clearDialogue(opts.answers)
      local ax, ay = A.pos(self.g)
      if bx and ax and bmap == A.mapId(self.g) and (ax ~= bx or ay ~= by) then
        -- Same-map warps (GOLDENROD_UNDERGROUND's basement door at (18,6) ->
        -- (21,31), and the pair back) change the cell but not the map id.
        -- Treating that as a Miracle-Seed-style shove priced the door as a
        -- wall, so every later hop onto it "did not take" and the switch-room
        -- region-1 travel fell back to TELEPORT.
        if leftWarp then
          self:say(("walk: same-map warp moved us off (%d,%d) to (%d,%d)")
            :format(bx, by, ax, ay))
          if opts.stopOnMapChange then return true end
        else
          self:say(("walk: a script moved us off (%d,%d) to (%d,%d) -- avoiding it")
            :format(bx, by, ax, ay))
          for _ = 1, 3 do self:noteWall(bmap, bx, by) end
        end
      end
    end
    -- Leaving the map ends this walk either way.  It is a SUCCESS when the
    -- caller was walking into a warp or a seam, and a failure otherwise -- and
    -- "otherwise" is usually a blackout, which teleports the player to their
    -- spawn point mid-route.  Without this the planner kept solving for Route
    -- 29 coordinates while stood in the bedroom and logged "no path" forever.
    if A.mapId(self.g) ~= map0 then
      if opts.stopOnMapChange then return true end
      self:say(("walk abandoned: left %s for %s")
        :format(tostring(map0), tostring(A.mapId(self.g))))
      return false
    end
    local x, y = A.pos(self.g)
    if not x then return false end
    if x == goalX and y == goalY then return true end
    local path = self:planPath(goalX, goalY)
    if not path then
      -- Boxed in by somebody who is about to walk away.
      --
      -- NPCs are priced as walls, which is right for planning and wrong as a
      -- verdict: they MOVE. A door tile makes it fatal, because a door is set
      -- into a building and has exactly one cell in front of it -- so one
      -- wandering NPC standing there leaves the player with no path at all.
      -- Mahogany Gym is the case: the bot stepped out onto warp 3 at (6,13),
      -- an NPC was on (6,14), and every route row for the next 400k frames
      -- failed. The run had seven badges at the time.
      --
      -- So before believing "no path", check whether the only thing in the way
      -- is a person, and if so stand still and ask again. This is the same
      -- reasoning ops.talk already uses on a failed approach.
      local map = A.map(self.g)
      local blockedByNpc = false
      if map then
        for _, d in pairs(DELTA) do
          local nx, ny = x + d[1], y + d[2]
          if A.npcAt(self.g, nx, ny) and A.walkable(self.g, map, nx, ny) then
            blockedByNpc = true
          end
        end
      end
      if blockedByNpc and (opts.npcWaits or 0) < 4 then
        self:say(("walkTo (%d,%d): boxed in at (%d,%d) by an NPC -- waiting")
          :format(goalX, goalY, x, y))
        self:wait(60)
        if A.busy(self.g) then self:clearDialogue(opts.answers) end
        local retry = {}
        for k, v in pairs(opts) do retry[k] = v end
        retry.npcWaits = (opts.npcWaits or 0) + 1
        return self:walkTo(goalX, goalY, retry)
      end
      self:say(("walkTo (%d,%d): no path from (%d,%d) on %s")
        :format(goalX, goalY, x, y, tostring(A.mapId(self.g))))
      return false
    end
    if #path == 0 then return true end

    -- Give up early when an attempt ends exactly where it began.  Re-planning
    -- is only worth doing if something changed, and a plan that cannot take its
    -- first step will produce the same plan forever: Route 32's Pokecenter is
    -- 98 cells away past a one-way drop, and the bot spent ~800k frames --
    -- most of a run -- re-deriving that same 98-step path from the same cell.
    -- Failing in a few hundred frames instead is what makes the whole route
    -- finish, and it is logged rather than silently capped.
    if x == lastX and y == lastY then
      stuckAttempts = stuckAttempts + 1
      if stuckAttempts >= 3 then
        self:say(("walkTo (%d,%d): no progress from (%d,%d) in %d attempts")
          :format(goalX, goalY, x, y, stuckAttempts))
        return false
      end
    else
      stuckAttempts = 0
    end
    lastX, lastY = x, y

    self:say(("walk (%d,%d)->(%d,%d) %d steps [try %d] %s")
      :format(x, y, goalX, goalY, #path, attempt,
              table.concat(path, "", 1, math.min(8, #path)):gsub("up", "^")
                :gsub("down", "v"):gsub("left", "<"):gsub("right", ">")))
    -- Walk the plan, but abandon it the moment the world disagrees: a warp, a
    -- trip-wire script or a trainer's sight line all invalidate it.
    for _, dir in ipairs(path) do
      if A.busy(self.g) or A.mapId(self.g) ~= map0 then break end
      if not self:stepDir(dir) then
        -- Name the cell the engine refused.  Wall memory alone is silent, so a
        -- walk that cannot start looked identical in the log to one that had no
        -- path at all -- and the two have completely different causes (a tile
        -- the static test thinks is walkable versus a genuine dead end).
        local bx, by = A.pos(self.g)
        local d = DELTA[dir]
        self:say(("step %s refused: (%d,%d) -> (%d,%d) on %s%s")
          :format(dir, bx, by, bx + d[1], by + d[2], tostring(map0),
                  A.npcAt(self.g, bx + d[1], by + d[2]) and " [npc]" or ""))
        break
      end
      local cx, cy = A.pos(self.g)
      if cx == goalX and cy == goalY then break end
    end
    if opts.stopOnMapChange and A.mapId(self.g) ~= map0 then return true end
  end
  return false
end

-- Stand next to (x,y) and face it.  Used by every talk / item-ball / hidden
-- item objective, none of which can stand on their target.
function Bot:approachAndFace(x, y, allowed)
  local map = A.map(self.g)
  if not map then return false end
  -- `allowed` restricts which way we may be FACING when we press A.  Normally
  -- irrelevant, but the Ilex Forest Farfetch'd chase branches on it: each
  -- FarfetchdPositionN script scalls FarfetchdCryAndCheckFacing, and facing the
  -- wrong way sends the bird BACKWARDS round the loop instead of onwards, so a
  -- bot that approaches from whichever side is nearest can herd forever.
  local allow
  if allowed then
    allow = {}
    for _, dir in ipairs(allowed) do allow[dir] = true end
  end

  local best
  local function consider(sx, sy, dir)
    if allow and not allow[dir] then return end
    -- Same water rule as Bot:passable / borderStandable: a stand cell on the
    -- lake is legal once the party can SURF, even while we are still on the
    -- shore.  A.walkable alone refuses water until FieldMoves.isSurfing is
    -- already true, which made every water NPC (the Red Gyarados at
    -- LAKE_OF_RAGE 18,22 is the one that matters) report "nowhere to stand"
    -- from land -- so 10.33 never started the fight, Lance never appeared,
    -- and the Mahogany Mart staircase scene never armed.
    if not A.walkable(self.g, map, sx, sy)
        and not (self:canSurf() and A.isWater(map, sx, sy)) then
      return
    end
    if A.npcAt(self.g, sx, sy) then return end
    local path = self:planPath(sx, sy)
    if path and (not best or #path < best.len) then
      best = { x = sx, y = sy, dir = dir, len = #path }
    end
  end

  for dir, d in pairs(DELTA) do
    -- Directly alongside: stand here, face `dir` to look at (x,y).
    consider(x - d[1], y - d[2], dir)
    -- ...or two cells back across a COUNTER.  A Pokecenter nurse and a Mart
    -- clerk have no walkable neighbour at all: the tile in front of them is the
    -- counter, and the cart reaches them by doubling an A press's range over
    -- one (CheckFacingObject).  Without this the bot decided a Pokecenter had
    -- "nowhere to stand" and could never heal.
    local mid = { x - d[1], y - d[2] }
    if map:inBounds(mid[1], mid[2])
        and A.isCounter(map, mid[1], mid[2]) then
      consider(x - d[1] * 2, y - d[2] * 2, dir)
    end
  end
  if not best then
    local px, py = A.pos(self.g)
    self:say(("approach (%d,%d): nowhere to stand (at %s %d,%d surf=%s size=%d)")
      :format(x, y, tostring(A.mapId(self.g)), px or -1, py or -1,
              tostring(self:canSurf()), self:regionSize(256)))
    return false
  end
  if not self:walkTo(best.x, best.y) then return false end
  self:face(best.dir)
  return true
end

-- Stand on a warp cell and actually go through it.
--
-- Doors, staircases, caves and panels warp on arrival, so walking on is the
-- whole job.  A CARPET does not: World:checkCarpetWhileStanding wants the
-- player stopped on the tile with that carpet's own direction held, and until
-- it gets that it will happily let the bot stand in the doorway all day.  The
-- tile itself says which kind it is, so ask it rather than guess -- the first
-- run guessed "hold whatever we are facing", which walked straight back off
-- the mat and ping-ponged either side of the front door.
function Bot:enterWarp(x, y, dest)
  local from = A.mapId(self.g)
  local startX, startY = A.pos(self.g)

  -- Get off the warp we arrived on before aiming at a different one.
  --
  -- A ladder drops you ONTO a warp tile, and the arrival cooldown holds it
  -- until you step away.  Walking straight to another warp from there means
  -- the first step is off one warp and, in a tight room, often onto a second
  -- -- which fires, and puts us back where we started.  The Olivine
  -- lighthouse's 3F pocket is seven cells with three warps in it, and the bot
  -- spent every attempt bouncing between 3F and 4F: 21 hops, nothing gained.
  -- Standing on plain floor first costs one step and makes the walk ordinary.
  do
    local map = A.map(self.g)
    local px, py = A.pos(self.g)
    if map and px and A.isWarpTile(map, px, py)
        and not (px == x and py == y) then
      -- Prefer the side of the door the TARGET is on.  Next to a one-way
      -- passage the candidates are not interchangeable: coming out of the Ice
      -- Path onto Blackthorn's cliff, UP is the corridor that cannot reach
      -- town and DOWN is the ledge hop that can, and stepping off the wrong
      -- way turned a correct region plan into "warp not reachable from here".
      local fallback
      local chosen
      for dir, d in pairs(DELTA) do
        local nx, ny = px + d[1], py + d[2]
        if map:inBounds(nx, ny) and A.walkable(self.g, map, nx, ny)
            and not A.isWarpTile(map, nx, ny)
            and not A.npcAt(self.g, nx, ny) then
          fallback = fallback or dir
          if self:planPathFrom(nx, ny, x, y) then chosen = dir break end
        end
      end
      local dir = chosen or fallback
      if dir then
        self:say(("warp: stepping off the arrival tile (%d,%d) first")
          :format(px, py))
        self:stepDir(dir)
      end
      if A.mapId(self.g) ~= from then return false end
    end
  end
  -- Unreachable from here is a fact, not a failure to keep retrying: inside a
  -- tower it means this ladder is in another region of the floor.  But an NPC
  -- parked in a one-wide corridor is a fact that can change -- an engaged
  -- trainer stands wherever the fight happened, and on Radio Tower 2F that
  -- was the only lane to the stairs -- so wait a few beats before giving up,
  -- the same way walkTo waits when it is boxed in.
  local plannable = self:planPath(x, y)
  for _ = 1, 4 do
    if plannable then break end
    self:wait(60)
    plannable = self:planPath(x, y)
  end
  if not plannable then
    self:say(("warp (%d,%d) on %s is not reachable from here")
      :format(x, y, tostring(from)))
    return false
  end
  self:walkTo(x, y, { stopOnMapChange = true })
  if A.mapId(self.g) ~= from then return A.mapId(self.g) == (dest or A.mapId(self.g)) end
  do
    -- walkTo returns on a same-map warp via stopOnMapChange; catch it here
    -- before the "already standing on it" re-arm walks us back through the
    -- door the other way.
    local nx, ny = A.pos(self.g)
    if nx and (nx ~= x or ny ~= y) and (dest == nil or dest == from)
        and (nx ~= startX or ny ~= startY) then
      self:say(("warp (%d,%d): same-map warp landed at (%d,%d)")
        :format(x, y, nx, ny))
      self:clearDialogue()
      return true
    end
  end

  self:wait(12)                        -- an immediate warp takes on arrival
  if A.mapId(self.g) ~= from then
    self:clearDialogue()
    return dest == nil or A.mapId(self.g) == dest
  end

  -- Standing ON the tile already and not warping means the arrival cooldown is
  -- holding it: World:clearWarpCooldownIfLeft only releases once the player has
  -- stepped OFF the warp they arrived on, which is what stops a door bouncing
  -- you straight back where you came from.  A bot that walks "to" a cell it is
  -- already on moves zero steps, so it waits on a warp that will never fire --
  -- Ilex Forest's north door did exactly this, forever.  Step off and back on.
  local px, py = A.pos(self.g)
  if px == x and py == y then
    self:say(("warp (%d,%d): already standing on it, stepping off to re-arm")
      :format(x, y))
    for _, dir in ipairs(A.DIRS) do
      if self:stepDir(dir) then break end
    end
    if A.mapId(self.g) ~= from then
      self:clearDialogue()
      return dest == nil or A.mapId(self.g) == dest
    end
    self:walkTo(x, y, { stopOnMapChange = true })
    self:wait(12)
    if A.mapId(self.g) ~= from then
      self:clearDialogue()
      return dest == nil or A.mapId(self.g) == dest
    end
  end

  local map = A.map(self.g)
  local want = map and A.carpetDir(map, x, y)
  -- The tile's own answer first, then the compass, because a mis-decoded
  -- collision should cost a few frames rather than the whole route.  Built by
  -- append rather than as a literal: `{ want, "down", ... }` with a nil `want`
  -- is an array whose first element is nil, and ipairs then walks NONE of it --
  -- which quietly disabled every retry on any tile that is not a carpet.
  local tries = {}
  if want then tries[#tries + 1] = want end
  for _, dir in ipairs({ "down", "up", "left", "right" }) do
    tries[#tries + 1] = dir
  end
  for _, dir in ipairs(tries) do
    if dir then
      -- Must be standing still ON the cell: a step in progress fails
      -- checkCarpetWhileStanding's first test.
      local cx, cy = A.pos(self.g)
      if cx ~= x or cy ~= y then
        self:walkTo(x, y, { stopOnMapChange = true })
        if A.mapId(self.g) ~= from then break end
      end
      A.hold(self.g, dir)
      self:wait(TURN_FRAMES + 8)       -- turn first if needed, then the hold
                                       -- is seen while stationary
      A.releaseDirs(self.g)
      self:wait(10)
      if A.mapId(self.g) ~= from then break end
    end
  end

  self:clearDialogue()
  local now = A.mapId(self.g)
  if now ~= from then
    return dest == nil or now == dest
  end
  -- Same-map warp: the basement door on GOLDENROD_UNDERGROUND is a warp
  -- whose destination is the same map id at a different cell ((18,6) <->
  -- (21,31)).  The map-id test above cannot see it, and calling that a miss
  -- made every region-1 travel into the switch room TELEPORT after the key
  -- was used -- the hop had already landed in region 5, then enterWarp
  -- reported failure and the planner tried the door again from the wrong half.
  local nx, ny = A.pos(self.g)
  if nx and (nx ~= x or ny ~= y)
      and (dest == nil or dest == from)
      and (nx ~= startX or ny ~= startY or startX == x) then
    self:say(("warp (%d,%d): same-map warp landed at (%d,%d)")
      :format(x, y, nx, ny))
    return true
  end
  self:say(("warp (%d,%d) on %s did not take"):format(x, y, tostring(from)))
  return false
end

-- ---------------------------------------------------------------------------
-- the map graph
-- ---------------------------------------------------------------------------
-- Warps and connections form a directed graph over map ids.  The route only
-- names the map an objective lives on, so this is what turns "be on
-- CIANWOOD_CITY" into the twelve hops that actually get there.

function Bot:mapDefs()
  local w = A.world(self.g)
  return (w and w.maps) or {}
end

-- Does this map's own border on `dir` have a single cell we could stand on?
--
-- Twenty-one of Johto and Kanto's map connections do not: New Bark Town's east
-- edge onto Route 27, Route 41's west edge onto Cianwood, Azalea Town's west
-- edge onto Route 34 and eighteen more.  Some are water (crossable once we can
-- SURF, which is why the test asks the CURRENT movement mode rather than a
-- fixed one) and some are simply scenery -- the real way through is a gate
-- building next to them.  Either way the connection exists in the map data, so
-- the planner kept choosing it, crossEdge kept spending a thousand frames
-- pushing at a wall, and the seam price only made it the second choice rather
-- than no choice.  Asking the map costs one row scan and settles it.
--
-- tools/goldwalk/mapgraph.lua's `audit` lists them all from the cache.
function Bot:borderStandable(mapId, dir)
  local key = ("%s#%s#%s"):format(tostring(mapId), tostring(dir),
                                  A.surfing(self.g) and "surf" or "foot")
  local cached = self.borders[key]
  if cached ~= nil then return cached end
  local map = A.map(self.g)
  if not (map and map.id == mapId) then return true end   -- not here; cannot
                                                          -- ask, so allow
  local w, h = map.widthCells, map.heightCells
  local ok = false
  local function look(x, y)
    if ok then return end
    if A.walkable(self.g, map, x, y)
        or (self:canSurf() and A.isWater(map, x, y)) then
      ok = true
    end
  end
  if dir == "up" then
    for x = 0, w - 1 do look(x, 0) end
  elseif dir == "down" then
    for x = 0, w - 1 do look(x, h - 1) end
  elseif dir == "left" then
    for y = 0, h - 1 do look(0, y) end
  else
    for y = 0, h - 1 do look(w - 1, y) end
  end
  self.borders[key] = ok
  return ok
end

-- Every way off `mapId`: each warp cell, and each connected edge.
function Bot:exitsOf(mapId)
  local defs = self:mapDefs()
  local def = defs[mapId]
  if not def then return {} end
  local out = {}
  -- On the map we are STANDING on we can ask the tile whether a warp would
  -- actually fire, and drop the ones that cannot.  Half the warp_events in a
  -- multi-floor interior sit on plain floor: they are the landing spot of a
  -- ladder on the far side, and CheckWarpTile never fires on them.  The
  -- Olivine lighthouse's 3F pocket has two of those and one real ladder, and
  -- the planner kept picking the phantoms.  A remote map's collision is not
  -- available here -- that is what map_regions.lua is generated for.
  local liveMap = A.map(self.g)
  local canAsk = liveMap ~= nil and liveMap.id == mapId
  for i, warp in ipairs(def.warps or {}) do
    if warp.destMap and defs[warp.destMap]
        and not (canAsk and not A.isWarpTile(liveMap, warp.x, warp.y)) then
      out[#out + 1] = { kind = "warp", to = warp.destMap,
                        x = warp.x, y = warp.y, index = i }
    end
  end
  for dir, conn in pairs(def.connections or {}) do
    local to = conn.mapId
    local button = BUTTON_DIR[dir]
    if to and defs[to] and button then
      out[#out + 1] = { kind = "edge", to = to, dir = button }
    end
  end
  return out
end

-- A single exit's identity, so one bad ladder can be priced without
-- condemning every route between the same two maps.
local function exitKey(mapId, exit)
  return ("%s#%s"):format(tostring(mapId),
    exit.kind == "warp" and ("w" .. exit.index) or ("e" .. exit.dir))
end

-- Is this map a cul-de-sac -- a house, a shop, a speech room -- whose every
-- exit leads to the same one map?
--
-- A map like that can never be an intermediate step on a route between two
-- OTHER maps, but the planner had no way to know that, and the cost of not
-- knowing was the single worst behaviour in the log: after a genuine seam
-- failed, the per-trip exit bans left the real roads out of a town banned,
-- the cheapest remaining "path" ran through a building, and the bot toured
-- every house in Cherrygrove and Violet -- 61 hops, 50k frames -- before the
-- loop guard gave up and a teleport covered for it.  Excluding cul-de-sacs
-- from EXPANSION (never from being the target) removes the whole class.
function Bot:isCulDeSac(mapId)
  local cached = self.culDeSac[mapId]
  if cached ~= nil then return cached end
  local only, count = nil, 0
  for _, exit in ipairs(self:exitsOf(mapId)) do
    if exit.to ~= mapId then
      if only == nil then only = exit.to end
      if exit.to ~= only then
        self.culDeSac[mapId] = false
        return false
      end
      count = count + 1
    end
  end
  -- No exits at all is not a cul-de-sac, it is a bug in the extract; treat it
  -- as impassable either way.
  local verdict = count > 0
  self.culDeSac[mapId] = verdict
  return verdict
end

function Bot:noteBadExit(mapId, exit)
  local k = exitKey(mapId, exit)
  self.badExits[k] = (self.badExits[k] or 0) + 1
end

function Bot:exitCost(mapId, exit)
  -- 40 rather than 25: a failed exit costs a thousand frames to discover, and
  -- at 25 a two-hop alternative never beat re-trying the same broken ladder --
  -- the log has Route 35's south edge chosen, failed and re-chosen three times
  -- in a row before the price finally added up.
  return (self.badExits[exitKey(mapId, exit)] or 0) * 40
end

-- Cheapest sequence of hops from the current map to `target`.
--
-- Two things here are not the obvious map-to-map BFS, and Sprout Tower is why.
-- Its floors are several DISCONNECTED regions joined only through other floors:
-- arriving on 2F by the west ladder leaves you walled off from the ladder up to
-- 3F, which is reachable only from 2F's other entrance.  A graph whose nodes
-- are maps cannot see that, so it kept choosing an exit it could not walk to
-- and the planner span.  The Olivine Lighthouse -- six floors of exactly this
-- shape, and the actual destination of this route -- would have done the same.
--
--   1. Exits of the CURRENT map are filtered by whether their cell is
--      reachable from where the player is standing right now.  That is the
--      region information the map-node graph lacks, and it is free: we can
--      only ever be standing in one region.
--   2. The current map is NOT marked visited, so a route may legitimately
--      leave and come back -- 2F -> 1F -> 2F is how you change region, and a
--      plain BFS would refuse to consider it.
--
-- Per-exit pricing then makes repeated attempts try a DIFFERENT ladder rather
-- than the same one, so the search converges instead of oscillating.
-- How much this trip has already seen of a map.
--
-- This replaced a per-trip exit BAN, and the replacement is the fix for the
-- worst navigation failure in the log.  The ban's intent was right -- stop the
-- bot bouncing between a gate's two warps forever -- but its unit was wrong: it
-- banned exits that had WORKED, and a long trip that backtracks after a failed
-- seam legitimately re-uses the road it came in on.  After six maps most of the
-- real roads out of a town were banned, the cheapest surviving "route" ran
-- through the buildings, and the bot toured every house in Cherrygrove and
-- Violet before the loop guard gave up.
--
-- Pricing the MAP instead says the true thing: coming back somewhere we have
-- already been is usually wrong and occasionally necessary.  Twelve is more
-- than any detour worth taking around a working road and less than the cost of
-- the tour.
function Bot:visitCost(visits, mapId)
  -- Four, not twelve.  A revisit has to cost LESS than the detour that avoids
  -- it or the planner buys the detour: stood in Azalea Town's east pocket with
  -- Ilex Forest two warps away through the town, a 12-per-visit price made
  -- "back into Azalea" (1 hop + 12) look worse than "north through Route 32,
  -- Goldenrod and Route 34" (7 hops), and the bot walked half of Johto rather
  -- than step back through a door it had just used.  Repeat visits still add
  -- up, which is all the ping-pong guard needs.
  return ((visits and visits[mapId]) or 0) * 4
end

-- Which region of the current map are we standing in?
--
-- Flood fill from the player with warp cells treated as holes -- the same rule
-- the generator used -- then see which of the map's recorded representative
-- cells the fill contains.  Standing ON a warp belongs to no region, so the
-- fill starts from the neighbours instead and may legitimately answer with
-- several: that is what coming out of Union Cave onto Route 33's (11,9) does,
-- and it is the whole reason the southern half of that route is reachable at
-- all.
function Bot:currentRegions()
  local map = A.map(self.g)
  local mapId = A.mapId(self.g)
  local list = REGIONS[mapId or ""]
  local px, py = A.pos(self.g)
  if not (map and list and px) then return nil end

  -- The same warp test the generator used, or the fill draws a different map
  -- from the one the graph was built on and matches no region at all -- at
  -- which case planTravelRegions silently returns nil and the whole
  -- region-aware planner is off.
  local starts = {}
  if not A.isWarpTile(map, px, py) then
    starts[#starts + 1] = { px, py }
  else
    for _, d in pairs(DELTA) do
      local nx, ny = px + d[1], py + d[2]
      if map:inBounds(nx, ny) and A.walkable(self.g, map, nx, ny)
          and not A.isWarpTile(map, nx, ny) then
        starts[#starts + 1] = { nx, ny }
      end
    end
  end
  if #starts == 0 then return nil end

  -- The generator's regions are strongly connected components over DIRECTED
  -- movement (ledge hops and Gold's one-way walls -- see mapgraph.lua), so
  -- membership is mutual reachability: the fill runs once forward and once
  -- over reversed edges, and a representative cell has to appear in both.
  -- A forward-only fill would claim every region the player can DRAIN into
  -- (hop down into and never climb back out of), and planTravelRegions would
  -- then seed the search from regions the player is not standing in.
  local function cellOk(x, y)
    return map:inBounds(x, y) and A.walkable(self.g, map, x, y)
        and not A.isWarpTile(map, x, y)
  end
  -- Successor cells of (x, y): permitted steps, else ledge hops.
  local function stepsFrom(x, y)
    local out = {}
    local hop = A.ledgeFacings(map, x, y)
    for dir, d in pairs(DELTA) do
      local nx, ny = x + d[1], y + d[2]
      if A.stepPermitted(map, x, y, dir) and cellOk(nx, ny) then
        out[#out + 1] = { nx, ny }
      elseif hop and hop[dir] then
        local hx, hy = x + d[1] * 2, y + d[2] * 2
        if cellOk(hx, hy) then out[#out + 1] = { hx, hy } end
      end
    end
    return out
  end
  local function stepsOnto(x, y, tx, ty)
    if not cellOk(x, y) then return false end
    for _, s in ipairs(stepsFrom(x, y)) do
      if s[1] == tx and s[2] == ty then return true end
    end
    return false
  end

  local function fill(forward)
    local seen = {}
    local queue, head = {}, 1
    for _, s in ipairs(starts) do
      seen[s[2] * 4096 + s[1]] = true
      queue[#queue + 1] = s
    end
    while head <= #queue do
      local c = queue[head]; head = head + 1
      if forward then
        for _, s in ipairs(stepsFrom(c[1], c[2])) do
          local k = s[2] * 4096 + s[1]
          if not seen[k] then
            seen[k] = true
            queue[#queue + 1] = { s[1], s[2] }
          end
        end
      else
        for _, d in pairs(DELTA) do
          for dist = 1, 2 do
            local px2, py2 = c[1] + d[1] * dist, c[2] + d[2] * dist
            local k = py2 * 4096 + px2
            if not seen[k] and stepsOnto(px2, py2, c[1], c[2]) then
              seen[k] = true
              queue[#queue + 1] = { px2, py2 }
            end
          end
        end
      end
    end
    return seen
  end

  local fwd = fill(true)
  local bwd = fill(false)
  local out = {}
  for index, r in ipairs(list) do
    local k = r.y * 4096 + r.x
    if fwd[k] and bwd[k] then out[#out + 1] = index end
  end
  return (#out > 0) and out or nil
end

-- Cheapest sequence of hops from where we stand to `target`, over the REGION
-- graph.
--
-- The map-id graph this replaced could not express the one fact that decides
-- most of Johto's routing: a map is not a place.  Route 33's north strip and
-- its south strip touch only at the Union Cave entrance, so "Route 33 connects
-- west to Azalea Town" is true of the south half and false of the north half;
-- Azalea Town's east border is shared by the town and by a 27-cell dead end.
-- Planning over map ids, the bot walked from Route 32 down Route 33, crossed
-- west, landed in the dead end, and then -- because the graph insisted it was
-- standing in Azalea Town -- either toured Johto looking for a way out or gave
-- up and teleported.  Over regions the same query answers "through Union
-- Cave", which is what the walkthrough says.
--
-- The static graph is a prior, not gospel: CUT trees, boulders and Strength
-- can merge regions at run time, and it knows nothing of NPCs.  So a plan that
-- fails still falls back to the map-id search below, and the live prices
-- (seams, bad exits, visits) apply to both.
function Bot:planTravelRegions(target, visits, wantRegion)
  local from = A.mapId(self.g)
  if not (from and REGIONS[from] and REGIONS[target]) then return nil end
  local here = self:currentRegions()
  if not here then
    -- Falling back to the map-id planner is a real loss of accuracy on any map
    -- with more than one region, so say when it happens rather than degrade
    -- silently: the lighthouse bounce looked like a planner bug and was really
    -- this.
    local px, py = A.pos(self.g)
    self:say(("plan: no region match on %s at (%s,%s) -- using the map graph")
      :format(tostring(from), tostring(px), tostring(py)))
    return nil
  end
  -- Already there is only "already there" if the REGION matches too.
  --
  -- This returned an empty hop list whenever the map ids matched, which made a
  -- region-targeted travel a no-op the moment the bot was standing anywhere on
  -- the right map: row 11.15r reported "ok" in zero frames from the wrong half
  -- of TEAM_ROCKET_BASE_B3F, and every row behind it went back to failing. When
  -- the region is wrong the answer is a real route -- out of this region and
  -- back in by the other door -- so fall through and plan one.
  if from == target then
    if not wantRegion then return {} end
    for _, r in ipairs(here) do
      if r == wantRegion then return {} end
    end
  end

  local function key(map, r) return ("%s#%d"):format(map, r) end
  local dist, open = {}, {}
  for _, r in ipairs(here) do
    dist[key(from, r)] = 0
    open[#open + 1] = { map = from, region = r, d = 0, parent = nil }
  end

  local seen = {}
  while #open > 0 do
    local bi, best = 1, open[1]
    for i = 2, #open do
      if open[i].d < best.d then bi, best = i, open[i] end
    end
    table.remove(open, bi)
    local bk = key(best.map, best.region)
    if not seen[bk] then
      seen[bk] = true
      if best.map == target
          and (not wantRegion or best.region == wantRegion) then
        local hops, node = {}, best
        while node and node.hop do
          table.insert(hops, 1, node.hop)
          node = node.parent
        end
        return hops
      end
      local regs = REGIONS[best.map]
      local node = regs and regs[best.region]
      -- Do NOT apply map-level isCulDeSac here.  GOLDENROD_UNDERGROUND's every
      -- external warp lands on SWITCH_ROOM_ENTRANCES, so the map-id test calls
      -- it a cul-de-sac -- but its regions are the only bridge between that
      -- neighbour's disconnected halves (basement warp 6 -> switch region 1;
      -- salon warps 1/2 -> switch regions 10/9). Filtering it made every
      -- region-targeted travel into the switch room fall back to the map-id
      -- planner and arrive in the wrong half, with Switch1/2/3 then reporting
      -- "nowhere to stand".
      if node then
        for _, link in ipairs(node.exits) do
          local exit = (link.k == "w")
            and { kind = "warp", index = link.i, x = link.x, y = link.y,
                  to = link.to }
            or  { kind = "edge", dir = BUTTON_DIR[link.d], to = link.to }
          if exit.kind ~= "edge" or exit.dir then
            local nd = best.d + 1 + self:visitCost(visits, link.to)
                     + self:seamCost(best.map, link.to)
                     + self:exitCost(best.map, exit)
            local nk = key(link.to, link.r)
            if nd < (dist[nk] or math.huge) then
              dist[nk] = nd
              open[#open + 1] = { map = link.to, region = link.r, d = nd,
                                  parent = best,
                                  hop = { from = best.map, exit = exit } }
            end
          end
        end
      end
    end
  end
  return nil
end

function Bot:planTravel(target, avoid, visits)
  local from = A.mapId(self.g)
  if not from then return nil end
  if from == target then return {} end

  -- Nodes carry their own parent chain rather than a prev[mapId] table.
  -- That table was the bug that made this whole fix look broken: once the
  -- start map may appear in the MIDDLE of a route (2F -> 1F -> 2F), walking
  -- the chain back "until we reach the start" stops at that middle occurrence
  -- and hands back only the tail -- which is precisely the unreachable hop the
  -- detour existed to avoid.  Following node parents cannot truncate.
  local dist = {}
  local open = {}

  -- Seed with the exits we can actually reach from where we are standing.
  local px, py = A.pos(self.g)
  local reachable = 0
  for _, exit in ipairs(self:exitsOf(from)) do
    local ok = true
    if exit.kind == "warp" then
      -- Only WARP exits are reachability-checked here.  Doing the same for edge
      -- exits is tempting and was tried: it costs up to a dozen full searches
      -- per edge per plan, and travelTo re-plans after every hop, so the run
      -- went from 280k frames to 1.36M and got further from Goldenrod, not
      -- closer.  crossEdge probes the border itself, which is the cheap place
      -- for that question.
      ok = self:planPath(exit.x, exit.y) ~= nil
      -- Never step straight back through the warp we just arrived on.  A gate
      -- drops the player onto the tile that leads back, so "walk to that tile"
      -- is a no-op followed by an immediate return -- the bot ping-ponged
      -- between Route 46 and its gate this way, twice a second, forever.
      -- Backtracking is still allowed, just not from the doormat.
      if avoid and exit.to == avoid and exit.x == px and exit.y == py then
        ok = false
      end
    elseif not self:borderStandable(from, exit.dir) then
      -- A connection whose near border we could not stand on anywhere.  Not a
      -- flaky seam to be priced: there is nothing to walk off.
      ok = false
    end
    if ok then
      reachable = reachable + 1
      local d = 1 + self:visitCost(visits, exit.to)
             + self:seamCost(from, exit.to)
             + self:exitCost(from, exit)
      -- Deliberately NOT penalising "the map we just came from" in general.
      -- Tried it (+50) and it was a bad trade: Johto's routes are a chain, so
      -- almost every real path revisits its predecessor, and the planner
      -- answered by taking enormous detours -- the bot ended up back on Route
      -- 29 wiping 88 times instead of walking to Violet City.  The narrow
      -- standing-on-the-doormat exclusion above is enough to stop the tight
      -- bounce, and travelTo's visits guard catches the looser ones.
      if d < (dist[exit.to] or math.huge) then
        dist[exit.to] = d
        open[#open + 1] = { id = exit.to, d = d, parent = nil,
                            hop = { from = from, exit = exit } }
      end
    end
  end
  if reachable == 0 then
    -- Walled in.  Nothing to plan; the caller reports it rather than spinning.
    return nil
  end

  local seen = {}
  while #open > 0 do
    local bi, best = 1, open[1]
    for i = 2, #open do
      if open[i].d < best.d then bi, best = i, open[i] end
    end
    table.remove(open, bi)
    if not seen[best.id] then
      seen[best.id] = true
      if best.id == target then
        local hops, node = {}, best
        while node do
          table.insert(hops, 1, node.hop)
          node = node.parent
        end
        return hops
      end
      -- Never route THROUGH a cul-de-sac; it may only ever be a destination.
      if not (self:isCulDeSac(best.id) and best.id ~= target) then
        for _, exit in ipairs(self:exitsOf(best.id)) do
          -- A seam is priced by how often it has failed, so a flaky border cell
          -- costs more than a clean one but never becomes impassable.
          local nd = best.d + 1 + self:visitCost(visits, exit.to)
                   + self:seamCost(best.id, exit.to)
                   + self:exitCost(best.id, exit)
          if nd < (dist[exit.to] or math.huge) then
            dist[exit.to] = nd
            open[#open + 1] = { id = exit.to, d = nd, parent = best,
                                hop = { from = best.id, exit = exit } }
          end
        end
      end
    end
  end
  return nil
end

-- Take one hop: walk onto the warp cell, or walk off the connected edge.
function Bot:takeHop(hop)
  local from = A.mapId(self.g)
  local exit = hop.exit
  if exit.kind == "warp" then
    self:say(("hop %s -> %s via warp %d (%d,%d)")
      :format(from, exit.to, exit.index, exit.x, exit.y))
    self:enterWarp(exit.x, exit.y, exit.to)
  else
    self:say(("hop %s -> %s via %s edge"):format(from, exit.to, exit.dir))
    self:crossEdge(exit.dir, exit.to)
  end
  self:clearDialogue()
  local arrived = A.mapId(self.g)
  if arrived == exit.to then
    self:clearSeam(from, exit.to)
    self:progress()
    return true
  end
  self:noteSeam(from, exit.to)
  self:say(("hop failed: wanted %s, on %s"):format(exit.to, tostring(arrived)))
  return arrived ~= from      -- landing somewhere ELSE is still movement, and
                              -- the caller re-plans from wherever we are
end

-- How many cells can the player actually reach from where they stand?
--
-- Several maps have a pocket that touches a border: Azalea Town's east side is
-- shared by the town proper (251 cells) and a 27-cell dead end whose only exit
-- is back the way you came.  Cross at the wrong y, or teleport onto the wrong
-- warp, and every plan afterwards is drawn from inside a cupboard.  Counting
-- the reachable cells is how the bot notices it is in one.
function Bot:regionSize(limit)
  local map = A.map(self.g)
  local sx, sy = A.pos(self.g)
  if not (map and sx) then return 0 end
  local seen = { [sy * 4096 + sx] = true }
  local queue, head, n = { { sx, sy } }, 1, 1
  while head <= #queue do
    local c = queue[head]; head = head + 1
    for _, d in pairs(DELTA) do
      local nx, ny = c[1] + d[1], c[2] + d[2]
      local k = ny * 4096 + nx
      if not seen[k] and map:inBounds(nx, ny)
          and A.walkable(self.g, map, nx, ny) then
        seen[k] = true
        n = n + 1
        if limit and n >= limit then return n end
        queue[#queue + 1] = { nx, ny }
      end
    end
  end
  return n
end

-- The reachable cell nearest the given edge, which is what we aim at before
-- pushing into the connection.
--
-- `skip` walks the candidate list further along.  A connection is a STRIP: the
-- y you cross at decides the y you land on, and on a map with a border pocket
-- that decides which side of a wall you arrive in.  Always aiming at the
-- nearest cell meant a failed crossing was retried identically forever, so the
-- caller counts its attempts and asks for a different cell each time.
function Bot:edgeTarget(map, rawDir, skip)
  local dir = BUTTON_DIR[rawDir]
  if not dir then return nil end
  local w, h = map.widthCells, map.heightCells
  local px, py = A.pos(self.g)
  if not px then return nil end
  -- Candidates along the border, nearest first -- and then REACHABLE-checked.
  --
  -- "Nearest passable" is not good enough and Route 34 is why: its top row has
  -- passable cells the player cannot actually get to (the river cuts them off),
  -- so the bot aimed at (13,0), found no path, and never crossed into Goldenrod
  -- at all.  A border cell is only a useful target if we can walk to it.
  local candidates = {}
  local function consider(x, y)
    if not self:passable(map, x, y) then return end
    candidates[#candidates + 1] =
      { x = x, y = y, d = math.abs(x - px) + math.abs(y - py) }
  end
  if dir == "up" then
    for x = 0, w - 1 do consider(x, 0) end
  elseif dir == "down" then
    for x = 0, w - 1 do consider(x, h - 1) end
  elseif dir == "left" then
    for y = 0, h - 1 do consider(0, y) end
  else
    for y = 0, h - 1 do consider(w - 1, y) end
  end
  table.sort(candidates, function(a, b) return a.d < b.d end)

  -- Each check is a full search, so the scan is bounded -- but the bound has to
  -- be big enough to leave the region we are IN.  The nearest-16 cap was too
  -- small on tall maps: coming down Blackthorn onto Route 45's top strip
  -- (region 3), the sixteen west-border cells nearest (15,0) are all up in the
  -- top-left, which is region 1/2 and unreachable from region 3 -- region 3's
  -- own Route 46 border cells are a third of the way down, past the cap, so
  -- the scan found nothing reachable and fell back to (0,0), a region-1 cell it
  -- could never walk to.  Scan far enough to clear a region (this is a
  -- per-crossing fallback, not the per-hop plan the handoff warns is too slow),
  -- and stop early once a handful are in hand.
  local reachable = {}
  local checked = 0
  for _, cell in ipairs(candidates) do
    if self:planPath(cell.x, cell.y) then reachable[#reachable + 1] = cell end
    checked = checked + 1
    if #reachable >= 6 or checked >= 64 then break end
  end
  if #reachable > 0 then
    -- Alternate near end / far end as `skip` grows rather than stepping one
    -- cell along.  Border cells that land in the same pocket are contiguous,
    -- so "the next one over" is almost always the same mistake again; the
    -- opposite end of the border is a different region.
    skip = skip or 0
    local index
    if skip % 2 == 0 then
      index = math.min(#reachable, math.floor(skip / 2) + 1)
    else
      index = math.max(1, #reachable - math.floor((skip - 1) / 2))
    end
    return reachable[index]
  end
  -- Nothing provably reachable: still hand back the nearest border cell.  The
  -- local search does not model one-way ledge hops, so "no path" is weaker than
  -- "cannot get there", and crossEdge's push-and-slide can still find the seam.
  if #candidates > 0 then
    self:say(("edgeTarget %s: none of the nearest %d border cells provably "
              .. "reachable, trying the closest anyway"):format(dir, checked))
  end
  return candidates[1]
end

-- Walk off the edge of the map in `dir` (a pad direction) onto the connected
-- map.  There is no single cell to aim at -- any cell on that border works, and
-- which ones are reachable depends on where we came in -- so aim at the nearest
-- reachable border cell, then push.  Pushing repeatedly matters: the landing
-- strip is offset, so the first border cell we reach is not always one the
-- connection actually covers, and walking ALONG the edge finds one that is.
function Bot:crossEdge(dir, dest)
  local from = A.mapId(self.g)
  local map = A.map(self.g)
  if not map then return false end

  -- Cross at a different point each time this particular border has FAILED,
  -- so a crossing that lands in a dead-end pocket is not repeated identically.
  -- The counter used to bump on every call, including successes: the first
  -- Route 43 -> Lake of Rage cross (the good x) then made the return visit
  -- after 10.g pick skip=1, which is the west end of the strip, and that
  -- lands in a 47-cell pocket with no path to the Red Gyarados even with
  -- Surf.  Only failures (and escapePocket's explicit bump) advance it.
  local tryKey = ("%s#%s"):format(tostring(from), tostring(dir))
  local skip = self.edgeTries[tryKey] or 0

  local target = self:edgeTarget(map, dir, skip)
  local aimed = target ~= nil
  if target then
    local cx, cy = A.pos(self.g)
    self:say(("edge %s off %s: crossing at (%d,%d) from (%s,%s) [try %d]")
      :format(dir, tostring(from), target.x, target.y, tostring(cx),
              tostring(cy), skip))
    self:walkTo(target.x, target.y, { stopOnMapChange = true })
    if A.mapId(self.g) ~= from then
      self:clearDialogue()
      return dest == nil or A.mapId(self.g) == dest
    end
  end

  -- Push into the seam, and if it does not take, slide along the edge and try
  -- again.  `along` is the axis perpendicular to the crossing.
  local along = (dir == "up" or dir == "down") and { "left", "right" }
                                                or { "up", "down" }
  -- Pushing blindly is only worth much when we got near the border under our
  -- own steam.  When no border cell was even reachable -- the player is in a
  -- pocket, or eighty rows away -- twenty-four pushes is five thousand frames
  -- spent proving what the failed walk already said.
  for attempt = 1, (aimed and 24 or 6) do
    if A.mapId(self.g) ~= from then break end
    A.hold(self.g, dir)
    self:wait(TURN_FRAMES + 14)
    A.releaseDirs(self.g)
    self:wait(6)
    if A.mapId(self.g) ~= from then break end
    if A.busy(self.g) then self:clearDialogue() end
    -- Alternate which way we slide so a blocked corner does not trap us at one
    -- end of the border, but never slide OFF the map: standing in a corner, a
    -- slide along one border is a step across the other one.  That is how
    -- "cross west into Violet City" came back having arrived on Route 30 --
    -- the player was on Route 31's bottom row, and the first southward slide
    -- took the south connection instead.  A crossing that lands on the wrong
    -- map is worse than one that fails: the caller prices the seam it asked
    -- for, which was never the one that fired.
    local slide = along[(attempt % 2) + 1]
    local ax, ay = A.pos(self.g)
    local map2 = A.map(self.g)
    local d = DELTA[slide]
    if not (ax and map2 and map2:inBounds(ax + d[1], ay + d[2])) then
      slide = along[((attempt + 1) % 2) + 1]
      d = DELTA[slide]
    end
    if ax and map2 and map2:inBounds(ax + d[1], ay + d[2]) then
      self:stepDir(slide)
    end
  end

  self:clearDialogue()
  local now = A.mapId(self.g)
  if now == from then
    self.edgeTries[tryKey] = skip + 1
    self:say(("edge %s off %s did not cross"):format(dir, tostring(from)))
    return false
  end
  return dest == nil or now == dest
end

-- ---------------------------------------------------------------------------
-- healing
-- ---------------------------------------------------------------------------

-- A Pokecenter nurse is a map's only SPRITE_NURSE object, so the extracted
-- objects already say where every heal point in Johto is; nothing needs a cell
-- hardcoded per town.
local function nurseOn(def)
  for _, obj in ipairs((def and def.objects) or {}) do
    if obj.sprite == "SPRITE_NURSE" then return obj end
  end
  return nil
end

-- Nearest map (by hop count) whose def satisfies `predicate`.
function Bot:findNearest(predicate)
  local defs = self:mapDefs()
  local from = A.mapId(self.g)
  if not from then return nil end
  local seen, queue, head = { [from] = true }, { from }, 1
  while head <= #queue do
    local id = queue[head]
    head = head + 1
    if predicate(defs[id], id) then return id end
    for _, exit in ipairs(self:exitsOf(id)) do
      if not seen[exit.to] then
        seen[exit.to] = true
        queue[#queue + 1] = exit.to
      end
    end
  end
  return nil
end

-- Full heal at a Pokecenter: restores HP *and PP*, which is the part that
-- matters most given the port has no Struggle (see A.partyPpFraction).
function Bot:healUp(preferMap)
  local defs = self:mapDefs()
  -- Candidates in graph-BFS order, and TRY EACH ONE.  The BFS is region-blind,
  -- so the nearest Pokecenter by map hops can be walled off from where we
  -- actually stand -- west of the Sudowoodo tree, Route 36 cannot reach
  -- Violet's -- and failing the whole heal on that one miss is what ended
  -- 05.g with "could not heal mid-grind" while Goldenrod's center sat two
  -- maps the other way.
  local candidates = {}
  if preferMap and nurseOn(defs[preferMap]) then
    candidates[#candidates + 1] = preferMap
  end
  local from = A.mapId(self.g)
  if from then
    local seen, queue, head = { [from] = true }, { from }, 1
    while head <= #queue and #candidates < 4 do
      local id = queue[head]
      head = head + 1
      if nurseOn(defs[id]) and id ~= preferMap then
        candidates[#candidates + 1] = id
      end
      for _, exit in ipairs(self:exitsOf(id)) do
        if not seen[exit.to] then
          seen[exit.to] = true
          queue[#queue + 1] = exit.to
        end
      end
    end
  end
  if #candidates == 0 then
    self:say("heal: no Pokecenter reachable from here")
    return false
  end
  for _, target in ipairs(candidates) do
    if A.mapId(self.g) == target or self:travelTo(target) then
      local nurse = nurseOn(defs[target])
      if nurse and self:approachAndFace(nurse.x, nurse.y) then
        self:tap("a")
        self:clearDialogue({ "yes" }, 3000)
        self:say(("heal: done on %s (hp %.2f, pp %.2f)")
          :format(target, A.leadHpFraction(self.g), A.partyPpFraction(self.g)))
        return true
      end
      self:say("heal: could not reach the nurse on " .. target)
    else
      self:say("heal: could not reach " .. target .. " -- trying the next")
    end
  end
  self:say("heal: every candidate Pokecenter was unreachable")
  return false
end

-- Heal when the party is in no state to keep fighting.  Called between route
-- rows rather than inside them, so it can never interrupt a scripted beat
-- half-way through.
function Bot:maybeHeal()
  local hp = A.leadHpFraction(self.g)
  local pp = A.damagingPpFraction(self.g)
  if hp >= 0.35 and pp >= 0.35 then return false end
  if A.busy(self.g) or A.inBattle(self.g) then return false end
  self:say(("heal: hp %.2f attacking-pp %.2f -- going to a Pokecenter")
    :format(hp, pp))
  return self:healUp()
end

-- Are we walled into a corner of this map whose only exit leads back to
-- `cameFrom`?  Cheap enough to ask once per hop: it is one flood fill plus a
-- reachability test per exit, and it is the difference between noticing a bad
-- crossing immediately and touring Johto to find out.
function Bot:inPocket(cameFrom)
  local here = A.mapId(self.g)
  if not here then return false end
  local exits = self:exitsOf(here)
  if #exits == 0 then return false end
  local wayOut = false
  for _, exit in ipairs(exits) do
    if exit.to ~= cameFrom then
      if exit.kind == "edge" then
        if self:borderStandable(here, exit.dir) then wayOut = true break end
      elseif self:planPath(exit.x, exit.y) then
        wayOut = true
        break
      end
    end
  end
  return not wayOut
end

-- We crossed into a pocket.  Go back and cross again somewhere else.
--
-- `from` is the map we came from and `exit` the crossing that put us here.
-- Each attempt bumps that crossing's counter, which is what makes edgeTarget
-- pick a border cell at the other end of the seam instead of the same one.
function Bot:escapePocket(from, exit)
  local pocketMap = A.mapId(self.g)
  local key = ("%s#%s"):format(tostring(from),
    exit.kind == "edge" and exit.dir or ("w" .. tostring(exit.index)))
  for attempt = 1, 3 do
    self.edgeTries[key] = (self.edgeTries[key] or 0) + 1
    -- Back out through whichever way we can reach; on a pocket that is the way
    -- we came in.
    local out = nil
    for _, e in ipairs(self:exitsOf(pocketMap)) do
      if e.to == from then out = e break end
    end
    if not out then return false end
    if not self:takeHop({ exit = out }) then return false end
    if A.mapId(self.g) ~= from then return false end

    if exit.kind == "edge" then
      self:crossEdge(exit.dir, exit.to)
    else
      self:enterWarp(exit.x, exit.y, exit.to)
    end
    if A.mapId(self.g) ~= pocketMap then return false end
    if not self:inPocket(from) then
      self:say(("travel: re-crossed into %s clear of the pocket (try %d)")
        :format(tostring(pocketMap), attempt))
      return true
    end
  end
  self:say(("travel: every crossing into %s lands in the pocket")
    :format(tostring(pocketMap)))
  return false
end

-- Get to `target`, re-planning after every hop.
-- `wantRegion` is a region INDEX from tests/drivers/gold/map_regions.lua,
-- for the maps where arriving is not the same as arriving somewhere useful.
--
-- TEAM_ROCKET_BASE_B3F is the case that forced it. The rival trigger at (8,10)
-- sits in region 1, which is reachable only through warps 1 and 3 on the far
-- LEFT of the floor; the way in from B1F lands you in region 3 on the right,
-- and the two never touch. "travel TEAM_ROCKET_BASE_B3F" was therefore
-- satisfied by the wrong half of the map, and every row after it -- the rival,
-- Giovanni's door, Executive 4, HAIL GIOVANNI -- failed on a floor the bot was
-- standing on. The real route is a loop through both floors, which the region
-- graph can find as soon as it is told which end to aim for.
function Bot:travelTo(target, wantRegion)
  if not self:mapDefs()[target] then
    self:say("travel: unknown map " .. tostring(target))
    return false
  end
  -- Loop breaker.  A multi-floor interior (Sprout Tower, the lighthouse) has
  -- several ladders between the same pair of floors, so a hop can succeed --
  -- land exactly on the map it promised -- and still leave us further from the
  -- goal, at which point the next plan sends us straight back and the two
  -- floors trade the player back and forth forever.  Counting map VISITS
  -- catches that, where the seam price cannot: nothing here ever failed.
  local visits = {}
  local cameFrom = nil
  local relaxed = false
  -- A frame budget, not just a hop budget.
  --
  -- The hop counter (80) and the per-map visit guard both bound how many
  -- DECISIONS a trip makes, and neither bounds how long one takes: a single
  -- travel to the Ilex Forest gate once spent 3.5 MILLION frames -- most of a
  -- run -- inside eighty legal-looking hops, each of which walked half of
  -- Azalea and pushed at a border twenty-four times.  The watchdogs in :wait()
  -- and :say() cannot see it either, because every hop reports progress.
  --
  -- 150k frames is far more than any real journey in Johto (the longest honest
  -- one measured is about 60k) and far less than a wasted run.
  local startedAt = frames
  local frameBudget = tonumber(os.getenv("POKEPORT_GOLD_TRAVEL_BUDGET")) or 150000

  -- Starting inside a pocket is the same problem as arriving in one, minus the
  -- hop that tells you which crossing put you there.  The way out is forced
  -- and leads to exactly one map, so the crossing to vary is the one BACK from
  -- that map -- bump it before the trip rather than after, or the return leg
  -- re-enters the same corner and the trip is a loop by construction.
  if A.mapId(self.g) ~= target and self:inPocket(nil) then
    local OPPOSITE = { up = "down", down = "up", left = "right", right = "left" }
    for _, exit in ipairs(self:exitsOf(A.mapId(self.g))) do
      if exit.kind == "edge" and OPPOSITE[exit.dir] then
        local key = ("%s#%s"):format(exit.to, OPPOSITE[exit.dir])
        self.edgeTries[key] = (self.edgeTries[key] or 0) + 1
        self:say(("travel: starting in a dead-end pocket of %s -- will re-enter "
                  .. "from %s at a different point")
          :format(tostring(A.mapId(self.g)), exit.to))
      end
    end
  end

  local function arrived()
    if A.mapId(self.g) ~= target then return false end
    if not wantRegion then return true end
    for _, r in ipairs(self:currentRegions() or {}) do
      if r == wantRegion then return true end
    end
    return false
  end

  for _ = 1, 80 do
    local here = A.mapId(self.g)
    if arrived() then return true end
    if frames - startedAt > frameBudget then
      self:say(("travel: %d frames trying to reach %s from %s, giving up")
        :format(frames - startedAt, target, tostring(here)))
      return false
    end
    if A.busy(self.g) then self:clearDialogue() end

    -- Revisiting a map is now legitimate -- changing region inside a tower
    -- means leaving and coming back -- so the loop guard has to allow several
    -- passes before it calls it a loop.
    visits[here] = (visits[here] or 0) + 1
    if visits[here] > 8 then
      self:say(("travel: looping through %s on the way to %s, giving up")
        :format(tostring(here), target))
      return false
    end

    -- Region graph first, map-id graph as the fallback: the static graph is
    -- right about geometry and blind to anything the run has changed (a CUT
    -- tree down, a boulder moved, a badge earned).
    local hops = self:planTravelRegions(target, visits, wantRegion)
      or self:planTravel(target, cameFrom, visits)
    if not hops and not relaxed then
      -- The prices have painted us into a corner; drop them once and retry, so
      -- a route that genuinely needs to walk back through somewhere is still
      -- possible.
      relaxed = true
      hops = self:planTravel(target, cameFrom, nil)
    end
    if not hops then
      self:say(("travel: no route %s -> %s"):format(tostring(here), target))
      return false
    end
    -- Empty hops means "already there" only when the REGION matches too.
    -- planTravel (map-id fallback) returns {} whenever from == target, so a
    -- region-targeted travel that landed on the wrong half of RADIO_TOWER_5F
    -- -- or any other split map whose static region path is blocked -- used
    -- to report success at (0,0) while the boss sat in region 2.
    if #hops == 0 then return arrived() end
    local exit = hops[1].exit
    cameFrom = here
    if not self:takeHop(hops[1]) then
      -- Price both the pair and the specific exit.  The pair price keeps a
      -- flaky seam usable; the exit price is what makes the next attempt pick a
      -- DIFFERENT ladder, which is the only way out of a floor whose regions
      -- do not connect.
      self:noteSeam(here, exit.to)
      self:noteBadExit(here, exit)
      -- Burn a frame on the way past.  A hop that fails before it moves --
      -- "warp (15,0) is not reachable from here", decided by a search and no
      -- input at all -- costs ZERO frames, so a plan that keeps choosing it
      -- spins the loop without the silent-stall watchdog ever seeing a frame
      -- go by.  Radio Tower 2F did exactly that: the same three lines, forever,
      -- at frame 857930.  The repeat detector in :say() catches the talkative
      -- version; this makes sure the quiet one is caught too.
      self:wait(2)
    elseif self:inPocket(here)
        and not self:isCulDeSac(A.mapId(self.g)) then
      -- The hop landed exactly where it promised and still went wrong: we are
      -- in a walled-off corner whose only way out is back.  Azalea Town's east
      -- side is shared by the town (251 cells) and a 27-cell dead end, and
      -- Lake of Rage's west south shore is a 47-cell pocket with no path to
      -- the Red Gyarados even with Surf.  Crossing from Route 43 at the wrong
      -- x puts you in that pocket, after which every approach on the lake
      -- reports "nowhere to stand".
      --
      -- Used to only fire when the pocket was an INTERMEDIATE map
      -- (`mapId ~= target`).  That missed the destination case: travelTo
      -- called the Lake pocket "arrived" and 10.33 never started the fight.
      -- Cul-de-sacs (houses, shops) are excluded -- being pocketed in one is
      -- the same as having arrived.
      --
      -- A connection is a strip, so the answer is to cross at a different
      -- point.  escapePocket bumps the edge counter, which is what makes the
      -- retry pick another border cell instead of the same one.
      -- Deliberately NOT priced as a bad exit, and deliberately retried HERE
      -- rather than by handing control back to the planner.  It is the right
      -- exit crossed at the wrong point; the planner, which has no idea a map
      -- can have two disconnected halves, only sees a map it has now visited
      -- twice and answers by taking a seven-hop detour round Johto -- which is
      -- the failure this whole branch exists to prevent.  So: step back out,
      -- cross again somewhere else, and only give up after a few tries.
      self:say(("travel: %s is a dead-end pocket from here, re-crossing")
        :format(tostring(A.mapId(self.g))))
      self:escapePocket(here, exit)
    end
  end
  -- Must honour wantRegion.  Returning "on the right map" here was how a
  -- region-targeted travel into GOLDENROD_UNDERGROUND_SWITCH_ROOM_ENTRANCES
  -- reported success from region 10 after the map-id fallback hopped warp 1:
  -- eighty retries later the loop ended on the right map in the wrong half.
  return arrived()
end

-- Last-resort arrival: walk if we can, otherwise put the player there.
--
-- The map graph has one known hole -- Goldenrod is only reachable through
-- Route 35's south gate, whose warp is not reachable from the border the
-- player arrives on, so the planner bounces -- and that hole gates PLAINBADGE,
-- which gates STRENGTH, which gates everything after it.  Rather than let one
-- seam block six sections, fall through to a teleport and SAY SO, so a summary
-- can be read honestly: rows reached this way tested the beat, not the route.
function Bot:reachMap(target, wantRegion)
  if A.mapId(self.g) == target then
    if wantRegion then
      for _, r in ipairs(self:currentRegions() or {}) do
        if r == wantRegion then return true end
      end
      -- Wrong half of a split map; fall through and travel properly.
    elseif self:isCulDeSac(target) or self:regionSize(64) >= 64 then
      return true
    else
      -- On the right map but in a tiny disconnected pocket (Lake of Rage
      -- west shore after a bad strip crossing).  Leave through whatever exit
      -- we can reach, then travelTo back in at a different point.
      self:say(("reachMap: on %s in a %d-cell pocket, leaving to re-enter")
        :format(target, self:regionSize()))
      for _, exit in ipairs(self:exitsOf(target)) do
        if self:takeHop({ exit = exit }) and A.mapId(self.g) ~= target then
          break
        end
      end
      if A.mapId(self.g) == target then return false end
    end
  end
  -- A stall inside travelTo must not skip the fallback below it.
  --
  -- travelTo raises `{ botStall = true }` when the silent-stall backstop fires,
  -- and that unwound straight past this function -- so the one situation the
  -- warp-landing fallback exists for, a player who cannot walk anywhere, was
  -- also the one situation where it never got to run. Run 26 died exactly
  -- there: boxed onto MAHOGANY_GYM's door tile by an NPC, it spent 400k frames
  -- failing every remaining row rather than taking the shortcut, and lost a
  -- seven-badge save. A stall is a reason to fall back, not a reason to stop.
  local ok, res = pcall(self.travelTo, self, target, wantRegion)
  if ok and res then return true end
  if not ok then
    if not (type(res) == "table" and res.botStall) then error(res, 0) end
    self:say(("travel to %s stalled (%s) -- trying a warp landing instead")
      :format(target, tostring(res.why)))
  end
  local def = self:mapDefs()[target]
  local warps = (def and def.warps) or {}
  if #warps == 0 then return false end

  -- Try each warp in turn and keep the first landing with room to move.
  --
  -- Warp 1 used to be taken unconditionally, and on Ilex Forest warp 1 is
  -- (1,5) -- inside a walled pocket.  Every row after that shortcut then
  -- reported "nowhere to stand": the Farfetch'd herd, HM01 CUT and, through
  -- CUT, Whitney, the Squirtbottle, Sudowoodo, ROCK SMASH, the Burned Tower
  -- and Morty.  One bad landing cost six sections, so the landing is now
  -- checked rather than assumed.
  --
  -- When the caller named a region, prefer a landing that currentRegions
  -- says is that region -- the largest pocket on a split map is not always
  -- the useful half (and on SWITCH_ROOM_ENTRANCES region 1 happens to be
  -- largest, but region 10 is the second-largest and is where a blind
  -- "first warp with room" used to drop the bot).
  local best, bestSize, bestWanted
  for index, landing in ipairs(warps) do
    if A.teleport(self.g, target, landing.x, landing.y) then
      self:wait(4)
      local size = self:regionSize(64)
      local inWanted = false
      if wantRegion then
        for _, r in ipairs(self:currentRegions() or {}) do
          if r == wantRegion then inWanted = true break end
        end
      end
      if inWanted and not bestWanted then
        best, bestSize, bestWanted = landing, size, true
      elseif not bestWanted and (not bestSize or size > bestSize) then
        best, bestSize = landing, size
      end
      -- 24 rather than "as big as possible": a gate hut is 36 cells and a
      -- Pokecenter smaller still, so demanding a large region would reject
      -- every landing on a small map and scan warps for nothing.  What is being
      -- ruled out is a walled-off corner, and those are single figures.
      if (not wantRegion and size >= 24) or (bestWanted and size >= 24) then
        break
      end
      self:say(("TELEPORT: warp %d of %s lands in a %d-cell pocket, trying the "
                .. "next"):format(index, target, size))
    end
    if index >= 6 then break end     -- a big interior has plenty; do not scan
                                     -- every ladder of a six-floor tower
  end
  if not best then return false end
  self:say(("TELEPORT: could not walk to %s, placing the player at (%d,%d) "
            .. "[harness shortcut, not navigation]")
    :format(target, best.x, best.y))
  if not A.teleport(self.g, target, best.x, best.y) then return false end
  self.teleports = (self.teleports or 0) + 1
  self:wait(30)
  self:clearDialogue()
  self:progress()
  if not wantRegion then return A.mapId(self.g) == target end
  for _, r in ipairs(self:currentRegions() or {}) do
    if r == wantRegion then return true end
  end
  return false
end

-- ---------------------------------------------------------------------------
-- construction
-- ---------------------------------------------------------------------------

function Bot.new(game, opts)
  opts = opts or {}
  local self = setmetatable({}, Bot)
  self.g = game
  self.walls, self.seams, self.deaths, self.badExits = {}, {}, {}, {}
  self.culDeSac, self.borders, self.edgeTries = {}, {}, {}
  self.history = {}
  self.silentFrames = 0
  self.stallFrames = tonumber(os.getenv("POKEPORT_GOLD_STALL")) or 5000
  self.stuckRepeats = tonumber(os.getenv("POKEPORT_GOLD_REPEATS")) or 12
  self.battleFrames = 3000
  self.skipped = {}
  local logPath = os.getenv("POKEPORT_GOLD_LOG")
  if logPath then self.logFile = io.open(logPath, "w") end
  return self
end

return Bot
