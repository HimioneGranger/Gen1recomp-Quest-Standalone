-- Bounded Quest world-streaming policy.
--
-- The first physical Saffron profile warmed twelve maps across four graph
-- hops and held the loading screen for 50.86 seconds. Keep only the immediate
-- connected ring at launch; normal neighbour streaming and the distance-gated
-- major-location prefetch take over once play begins.

local Policy = {
  PRELOAD_HOPS = 1,
  PRELOAD_MAP_CAP = 6,       -- current map plus at most five neighbours
  PRELOAD_FULL_CAP = 1,
  MAJOR_PRELOAD_DISTANCE = 512, -- world pixels, about 32 walking cells
}

function Policy.allowMajorPreload(distanceSquared)
  local distance = Policy.MAJOR_PRELOAD_DISTANCE
  return tonumber(distanceSquared) ~= nil
     and distanceSquared <= distance * distance
end

return Policy
