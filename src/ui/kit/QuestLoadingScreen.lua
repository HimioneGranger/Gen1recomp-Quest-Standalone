-- Clean, deterministic Pokemon-themed Quest launch screen.
--
-- Geometry is authored in the Discord preview's 1915x821 reference space.
-- Runtime rendering uses one uniform scale and centered letterboxing, so the
-- logo and text are never skewed at a different headset surface ratio.

local Screen = {}

Screen.REFERENCE_W = 1915
Screen.REFERENCE_H = 821
Screen.LOGO_PATH = "assets/logo/gen1recomp_unplugged.png"

local COLORS = {
  navy = { 0.02, 0.23, 0.51, 1 },
  red = { 0.95, 0.18, 0.20, 1 },
  blue = { 0.12, 0.47, 0.82, 1 },
  yellow = { 1.00, 0.82, 0.12, 1 },
  white = { 1, 1, 1, 1 },
  paper = { 0.995, 0.995, 0.99, 1 },
}

local STATIC_PROTECTED_ZONES = {
  { id = "logo", x = 85, y = 90, w = 790, h = 640 },
  { id = "progress", x = 970, y = 390, w = 875, h = 145 },
  { id = "copy", x = 1050, y = 545, w = 745, h = 125 },
}

-- These are the 27 outlines visible in the reviewed v2 preview. Keep their
-- exact positions, sizes, and colors unless a live destination bound requires
-- a bounded collision-avoidance shift.
local BASE_BALLS = {
  { 105, 58, 31, "red" }, { 275, 62, 17, "blue" },
  { 470, 62, 24, "yellow" }, { 700, 48, 17, "red" },
  { 920, 62, 27, "blue" }, { 1100, 55, 18, "yellow" },
  { 1300, 54, 23, "red" }, { 1545, 48, 27, "blue" },
  { 1750, 72, 21, "yellow" }, { 1872, 155, 27, "red" },
  { 54, 268, 25, "blue" }, { 930, 275, 18, "yellow" },
  { 1880, 350, 26, "red" }, { 52, 520, 24, "yellow" },
  { 935, 595, 18, "red" }, { 1878, 535, 25, "blue" },
  { 62, 765, 27, "blue" }, { 255, 776, 17, "yellow" },
  { 925, 765, 25, "red" }, { 1100, 752, 18, "blue" },
  { 1320, 765, 24, "yellow" }, { 1545, 760, 17, "red" },
  { 1765, 760, 27, "blue" }, { 1890, 700, 24, "yellow" },
  { 955, 360, 15, "blue" },
  { 965, 690, 15, "yellow" }, { 1830, 690, 16, "red" },
}

-- Approximate the user's black-X guide density and locations. The guide marks
-- are data only; rendering always draws colored outline Pokeballs.
local GUIDE_POINTS = {
  { 310, 85 }, { 810, 48 }, { 560, 145 }, { 990, 125 },
  { 1200, 90 }, { 1430, 115 }, { 1705, 155 }, { 120, 180 },
  { 240, 195 }, { 460, 205 }, { 735, 205 }, { 1090, 185 },
  { 1210, 190 }, { 1400, 185 }, { 1580, 190 }, { 1760, 260 },
  { 70, 410 }, { 210, 480 }, { 270, 585 }, { 390, 750 },
  { 470, 640 }, { 550, 770 }, { 685, 650 }, { 770, 760 },
  { 800, 570 }, { 865, 645 }, { 885, 365 }, { 1080, 350 },
  { 1180, 330 }, { 1190, 550 }, { 1040, 585 }, { 1150, 665 },
  { 1280, 650 }, { 1400, 690 }, { 1500, 660 }, { 1535, 610 },
  { 1650, 730 }, { 1700, 600 }, { 1750, 650 }, { 1600, 350 },
  { 1420, 350 }, { 1310, 270 }, { 1250, 375 }, { 900, 480 },
}

local BALL_SIZES = { 13, 16, 19, 23, 27, 31 }
local BALL_COLORS = { "red", "blue", "yellow" }
local FALLBACK_OFFSETS = { { 0, 0 } }
for _, distance in ipairs({ 45, 90, 140, 200, 280, 360, 430 }) do
  for _, direction in ipairs({
    { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 },
    { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 },
  }) do
    FALLBACK_OFFSETS[#FALLBACK_OFFSETS + 1] = {
      direction[1] * distance, direction[2] * distance,
    }
  end
end

local function copyStaticZones()
  local out = {}
  for i, z in ipairs(STATIC_PROTECTED_ZONES) do
    out[i] = { id = z.id, x = z.x, y = z.y, w = z.w, h = z.h }
  end
  return out
end

local function destinationLines(name)
  name = tostring(name or "Pallet Town")
  local words = {}
  for word in name:gmatch("%S+") do words[#words + 1] = word end
  if #words <= 3 then return { name } end

  local best, bestScore
  for split = 2, math.min(3, #words - 2) do
    local left = table.concat(words, " ", 1, split)
    local right = table.concat(words, " ", split + 1)
    local score = math.max(#left, #right) * 10 + math.abs(#left - #right)
    if not bestScore or score < bestScore then
      best, bestScore = { left, right }, score
    end
  end
  return best or { name }
end

local function destinationGeometry(name, measureText)
  local lines = destinationLines(name)
  local size = #lines == 1 and 48 or 40
  local widths, height = {}, size
  for i, line in ipairs(lines) do
    local width, measuredHeight
    if measureText then width, measuredHeight = measureText(line, size) end
    widths[i] = tonumber(width) or (#line * size * 0.62)
    height = math.max(height, tonumber(measuredHeight) or size)
  end
  local lineHeight = height + 8
  local firstY = 238 - (#lines - 1) * lineHeight / 2
  local minX, maxX = math.huge, -math.huge
  for i, width in ipairs(widths) do
    minX = math.min(minX, 1410 - width / 2)
    maxX = math.max(maxX, 1410 + width / 2)
  end
  local padding = 18
  return lines, size, firstY, lineHeight, {
    id = "destination", x = minX - padding, y = firstY - padding,
    w = maxX - minX + padding * 2,
    h = height + (#lines - 1) * lineHeight + padding * 2,
  }
end

local function destinationSeed(destination)
  local seed = 17
  for i = 1, #destination do
    seed = (seed * 131 + destination:byte(i)) % 2147483647
  end
  return seed
end

local function intersectsBall(ballOrZone, maybeBall)
  local zone, ball = ballOrZone, maybeBall
  local x, y, r = ball.x, ball.y, ball.r
  return x + r >= zone.x and x - r <= zone.x + zone.w
    and y + r >= zone.y and y - r <= zone.y + zone.h
end

local function ballsOverlap(a, b)
  local dx, dy = a.x - b.x, a.y - b.y
  local distance = a.r + b.r + 7
  return dx * dx + dy * dy < distance * distance
end

local function safeBall(ball, zones, placed)
  if ball.x - ball.r < 0 or ball.x + ball.r > Screen.REFERENCE_W
    or ball.y - ball.r < 0 or ball.y + ball.r > Screen.REFERENCE_H then
    return false
  end
  for _, zone in ipairs(zones) do
    if intersectsBall(zone, ball) then return false end
  end
  for _, other in ipairs(placed) do
    if ballsOverlap(ball, other) then return false end
  end
  return true
end

local function placeBall(requested, zones, placed, seed, index)
  local fallbackCount = #FALLBACK_OFFSETS - 1
  local start = ((seed + index * 97) % fallbackCount) + 2
  for attempt = 0, #FALLBACK_OFFSETS - 1 do
    local offset
    if attempt == 0 then
      offset = FALLBACK_OFFSETS[1]
    else
      offset = FALLBACK_OFFSETS[2 + ((start - 2 + attempt - 1) % fallbackCount)]
    end
    local ball = {
      x = requested.x + offset[1], y = requested.y + offset[2],
      r = requested.r, color = requested.color,
      source = requested.source, guideIndex = requested.guideIndex,
    }
    if safeBall(ball, zones, placed) then return ball end
  end
end

function Screen.progressStyle(index)
  if index % 2 == 1 then
    return { top = "red", bottom = "white", center = "white" }
  end
  return { top = "blue", bottom = "yellow", center = "white" }
end

function Screen.layout(destination, progress, total, measureText)
  destination = tostring(destination or "Pallet Town")
  total = math.max(1, math.floor(tonumber(total) or 10))
  progress = math.max(0, math.min(1, tonumber(progress) or 0))
  local complete = math.min(total, math.floor(progress * total + 0.00001))
  local lines, destinationFontSize, destinationY, destinationLineHeight,
    destinationZone = destinationGeometry(destination, measureText)
  local zones = copyStaticZones()
  zones[#zones + 1] = destinationZone
  local background = {}
  local seed = destinationSeed(destination)
  for i, c in ipairs(BASE_BALLS) do
    local ball = placeBall({
      x = c[1], y = c[2], r = c[3], color = c[4], source = "base",
    }, zones, background, seed, i)
    if ball then background[#background + 1] = ball end
  end
  for i, point in ipairs(GUIDE_POINTS) do
    local ball = placeBall({
      x = point[1], y = point[2],
      r = BALL_SIZES[((seed + i * 37) % #BALL_SIZES) + 1],
      color = BALL_COLORS[((seed + i * 53) % #BALL_COLORS) + 1],
      source = "guide", guideIndex = i,
    }, zones, background, seed, #BASE_BALLS + i)
    if ball then background[#background + 1] = ball end
  end

  local row = {}
  local startX, endX, y = 1010, 1770, 465
  local step = total == 1 and 0 or (endX - startX) / (total - 1)
  for i = 1, total do
    local style = Screen.progressStyle(i)
    row[i] = {
      index = i, x = startX + (i - 1) * step, y = y, r = 22,
      active = i <= complete, top = style.top, bottom = style.bottom,
      center = style.center,
    }
  end

  return {
    logo = { x = 478.75, y = 410.5, w = 710, h = 520 },
    zones = zones,
    destination = destination,
    destinationLines = lines,
    destinationFontSize = destinationFontSize,
    destinationY = destinationY,
    destinationLineHeight = destinationLineHeight,
    background = background,
    progressBalls = row,
    progress = progress,
    complete = complete,
    total = total,
  }
end

local fontCache = {}
local logo

local function font(size)
  if not fontCache[size] then
    local ok, value = pcall(love.graphics.newFont,
      "assets/fonts/plainpixel/PlainPixel-Regular.ttf", size)
    fontCache[size] = ok and value or love.graphics.newFont(size)
  end
  return fontCache[size]
end

local function setColor(name, alpha)
  local c = COLORS[name]
  love.graphics.setColor(c[1], c[2], c[3], alpha or c[4])
end

local function drawOutlineBall(ball)
  local G, x, y, r = love.graphics, ball.x, ball.y, ball.r
  setColor(ball.color, 0.42)
  G.setLineWidth(2)
  G.circle("line", x, y, r)
  G.line(x - r, y, x + r, y)
  G.circle("line", x, y, r * 0.34)
  G.circle("line", x, y, r * 0.16)
end

local function drawProgressBall(ball)
  local G, x, y, r = love.graphics, ball.x, ball.y, ball.r
  local alpha = ball.active and 1 or 0.28
  G.push("all")
  setColor(ball.top, alpha)
  G.arc("fill", "closed", x, y, r - 1, math.pi, math.pi * 2, 48)
  setColor(ball.bottom, ball.bottom == "white" and 1 or alpha)
  G.arc("fill", "closed", x, y, r - 1, 0, math.pi, 48)
  setColor("navy", ball.active and 1 or 0.42)
  G.setLineWidth(3)
  G.circle("line", x, y, r)
  G.line(x - r, y, x + r, y)
  setColor("white", 1)
  G.circle("fill", x, y, 6)
  setColor("navy", ball.active and 1 or 0.42)
  G.circle("line", x, y, 6)
  G.pop()
end

function Screen.draw(m, spec)
  local G = love.graphics
  local W, H = m.W, m.H
  local scale = math.min(W / Screen.REFERENCE_W, H / Screen.REFERENCE_H)
  local ox = (W - Screen.REFERENCE_W * scale) / 2
  local oy = (H - Screen.REFERENCE_H * scale) / 2
  local layout = Screen.layout(spec.destination, spec.progress, spec.total,
    function(line, size)
      local measured = font(size)
      return measured:getWidth(line), measured:getHeight()
    end)

  G.push("all")
  setColor("paper")
  G.rectangle("fill", 0, 0, W, H)
  G.translate(ox, oy)
  G.scale(scale, scale)

  for _, ball in ipairs(layout.background) do drawOutlineBall(ball) end

  if not logo then logo = G.newImage(Screen.LOGO_PATH) end
  local lw, lh = logo:getDimensions()
  local logoScale = math.min(layout.logo.w / lw, layout.logo.h / lh)
  G.setColor(1, 1, 1, 1)
  G.draw(logo, layout.logo.x, layout.logo.y, 0, logoScale, logoScale,
    lw / 2, lh / 2)

  setColor("navy")
  local lines = layout.destinationLines
  local nameFont = font(layout.destinationFontSize)
  G.setFont(nameFont)
  for i, line in ipairs(lines) do
    G.printf(line, 1030,
      layout.destinationY + (i - 1) * layout.destinationLineHeight,
      760, "center")
  end

  G.setColor(COLORS.navy[1], COLORS.navy[2], COLORS.navy[3], 0.25)
  G.setLineWidth(4)
  G.line(1010, 465, 1770, 465)
  for _, ball in ipairs(layout.progressBalls) do drawProgressBall(ball) end

  G.setFont(font(25))
  local pct = math.floor(layout.progress * 100 + 0.5)
  local copy = ("LOADING MAP DATA - %d%%  (%d / %d)")
    :format(pct, layout.complete, layout.total)
  setColor("navy")
  G.printf(copy, 1060, 570, 725, "center")
  G.pop()
end

Screen.intersectsBall = intersectsBall
Screen.baseBalls = BASE_BALLS
Screen.guidePoints = GUIDE_POINTS

return Screen
