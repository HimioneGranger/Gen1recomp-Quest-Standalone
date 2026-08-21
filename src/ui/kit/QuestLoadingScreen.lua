-- Clean, deterministic Pokemon-themed Quest launch screen.
--
-- Geometry is authored in the Discord preview's 1915x821 reference space.
-- Runtime rendering uses one uniform scale and centered letterboxing, so the
-- logo and text are never skewed at a different headset surface ratio.

local Screen = {}

Screen.REFERENCE_W = 1915
Screen.REFERENCE_H = 821
Screen.LOGO_PATH = "assets/logo/gen1recomp_unplugged_tight.png"
Screen.PROTECTED_MARGIN = 14
Screen.MOTIF_COUNT = 36
Screen.V4_MOTIF_COUNT = 32

local LOGO_SOURCE_W = 1344
local LOGO_SOURCE_H = 759
local LOGO_MAX_W = 710
local LOGO_MAX_H = 520

local COLORS = {
  navy = { 0.02, 0.23, 0.51, 1 },
  red = { 0.95, 0.18, 0.20, 1 },
  blue = { 0.12, 0.47, 0.82, 1 },
  yellow = { 1.00, 0.82, 0.12, 1 },
  white = { 1, 1, 1, 1 },
  paper = { 0.995, 0.995, 0.99, 1 },
}

-- V8 keeps the 32 surviving V4 anchors and four surviving V5 left-side
-- anchors. It retains the four approved V6 color changes and removes the six
-- user-marked motifs. Destination-seeded fallback placement remains active
-- for every anchor when measured foreground bounds conflict.
local MOTIF_ANCHORS = {
  { 89, 35, 17, "blue" }, { 262, 48, 21, "yellow" },
  { 435, 38, 17, "red" }, { 580, 65, 17, "yellow" },
  { 1069, 76, 27, "blue" }, { 1192, 76, 13, "yellow" },
  { 1492, 96, 17, "red" },
  { 1705, 92, 17, "red" }, { 1715, 174, 17, "yellow" },
  { 1069, 193, 17, "red" },
  { 1229, 205, 22, "blue" }, { 1349, 175, 13, "red" },
  { 71, 372, 22, "red" }, { 1011, 329, 17, "red" },
  { 1362, 320, 27, "blue" },
  { 1486, 342, 13, "yellow" }, { 1872, 328, 27, "red" },
  { 889, 446, 22, "yellow" }, { 911, 619, 22, "red" },
  { 1198, 630, 13, "red" }, { 1645, 596, 27, "yellow" },
  { 1814, 634, 27, "blue" }, { 61, 750, 22, "red" },
  { 263, 760, 27, "red" }, { 405, 758, 17, "yellow" },
  { 579, 750, 27, "blue" }, { 864, 761, 22, "blue" },
  { 1186, 744, 13, "blue" },
  { 1351, 778, 27, "yellow" }, { 1530, 723, 27, "red" },
  { 1669, 747, 13, "red" }, { 1819, 734, 22, "yellow" },
  { 125, 150, 14, "blue" }, { 330, 150, 20, "red" },
  { 815, 165, 23, "blue" },
  { 75, 575, 18, "yellow" },
}
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

local function protectedZone(id, x, y, w, h)
  local margin = Screen.PROTECTED_MARGIN
  return {
    id = id, x = x - margin, y = y - margin,
    w = w + margin * 2, h = h + margin * 2,
  }
end

local function logoGeometry()
  local scale = math.min(LOGO_MAX_W / LOGO_SOURCE_W,
    LOGO_MAX_H / LOGO_SOURCE_H)
  local w, h = LOGO_SOURCE_W * scale, LOGO_SOURCE_H * scale
  return {
    x = Screen.REFERENCE_W / 4, y = Screen.REFERENCE_H / 2,
    w = w, h = h,
  }, protectedZone("logo", Screen.REFERENCE_W / 4 - w / 2,
    Screen.REFERENCE_H / 2 - h / 2, w, h)
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
  local contentY = firstY - height / 2
  return lines, size, firstY, lineHeight,
    protectedZone("destination", minX, contentY, maxX - minX,
      height + (#lines - 1) * lineHeight)
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
  local logoGeometryValue, logoZone = logoGeometry()
  local pct = math.floor(progress * 100 + 0.5)
  local copy = ("LOADING MAP DATA - %d%%  (%d / %d)")
    :format(pct, complete, total)
  local copyWidth, copyHeight
  if measureText then copyWidth, copyHeight = measureText(copy, 25) end
  copyWidth = tonumber(copyWidth) or (#copy * 25 * 0.62)
  copyHeight = tonumber(copyHeight) or 25
  local zones = {
    logoZone,
    destinationZone,
    protectedZone("progress", 988, 443, 804, 44),
    protectedZone("copy", 1422.5 - copyWidth / 2,
      585 - copyHeight / 2, copyWidth, copyHeight),
  }
  local background = {}
  local seed = destinationSeed(destination)
  for i, c in ipairs(MOTIF_ANCHORS) do
    local ball = placeBall({
      x = c[1], y = c[2], r = c[3], color = c[4],
      source = i <= Screen.V4_MOTIF_COUNT and "v4" or "v5-left",
    }, zones, background, seed, i)
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
    logo = logoGeometryValue,
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
    loadingCopy = copy,
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
      layout.destinationY + (i - 1) * layout.destinationLineHeight
        - layout.destinationFontSize / 2,
      760, "center")
  end

  G.setColor(COLORS.navy[1], COLORS.navy[2], COLORS.navy[3], 0.25)
  G.setLineWidth(4)
  G.line(1010, 465, 1770, 465)
  for _, ball in ipairs(layout.progressBalls) do drawProgressBall(ball) end

  G.setFont(font(25))
  setColor("navy")
  G.printf(layout.loadingCopy, 1060, 570, 725, "center")
  G.pop()
end

Screen.intersectsBall = intersectsBall
Screen.ballsOverlap = ballsOverlap
Screen.motifAnchors = MOTIF_ANCHORS
Screen.protectedZone = protectedZone

return Screen
