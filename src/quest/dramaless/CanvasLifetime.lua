-- Small, testable ownership helper for Quest-only render targets.
--
-- LÖVE eventually finalizes an unreachable Canvas, but Android graphics
-- pressure is high enough that "eventually" is the wrong lifecycle for a
-- framebuffer. Resize explicitly releases the superseded target before
-- allocating its replacement; release returns nil so owners cannot retain a
-- truthy, already-released object by mistake.

local CanvasLifetime = {}

function CanvasLifetime.release(canvas)
  if canvas and type(canvas.release) == "function" then
    pcall(canvas.release, canvas)
  end
  return nil
end

function CanvasLifetime.resize(canvas, width, height, factory)
  if canvas and type(canvas.getWidth) == "function"
     and type(canvas.getHeight) == "function"
     and canvas:getWidth() == width and canvas:getHeight() == height then
    return canvas, false
  end

  CanvasLifetime.release(canvas)
  local ok, made = pcall(factory, width, height)
  if not ok or not made then return nil, false, ok and "no canvas" or made end
  return made, true
end

return CanvasLifetime
