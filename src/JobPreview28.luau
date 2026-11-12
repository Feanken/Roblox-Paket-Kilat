-- Read-only offer descriptions and diagram geometry. No reward calculation.
local Paths=require(script.Parent.CourierPaths21)
local P={}
function P.Route(routes,id)
 local points=routes[id]if not points or #points<2 then return nil end
 local distance=0
 for i=1,#points-1 do distance+=(points[i+1]-points[i]).Magnitude end
 return {points=points,distance=distance}
end
function P.OfferRoute(routes,offer)
 if not offer then return nil end
 if not offer.isBatch then return P.Route(routes,offer.destinationId)end
 local points={}
 local legDistances={}
 local source
 for _,id in ipairs(offer.batchDestinations)do
  local leg=Paths.Between(routes,source,id)if not leg then return nil end
  for i,v in ipairs(leg)do if #points==0 or i>1 then table.insert(points,v)end end
  table.insert(legDistances,Paths.Length(leg))
  source=id
 end
 return {points=points,distance=Paths.Length(points),legDistances=legDistances}
end
function P.Conditions(offer)
 if offer.isBatch then return '3 kiriman berurutan\nBonus finish: tanpa Pulihkan'end
 local c=offer.contract
 if c then
  local condition=string.format('Kondisi ≥%d',c.condition)
  if c.kind=='priority'then return string.format('%s · ≤%d dtk\nTanpa Pulihkan',condition,c.seconds)
  elseif c.kind=='perfect'then return condition..' sepanjang jalan\nTanpa Pulihkan'
  elseif c.kind=='explore'then return string.format('%d cap · %s\nTanpa Pulihkan',c.stamps,condition)end
 end
 return offer.description or ''
end
-- Suggestions describe the existing offers and do not affect eligibility or payment.
function P.MatchesGoal(goal, offer)
 if not goal or goal.done or not offer then return false end
 if goal.destination then
  if offer.isBatch then return table.find(offer.batchDestinations, goal.destination) ~= nil end
  return offer.destinationId == goal.destination
 end
 if goal.packageType then
  if offer.isBatch then return table.find(offer.packageTypes, goal.packageType) ~= nil end
  return offer.packageType == goal.packageType
 end
 if goal.contract then return offer.contract ~= nil end
 return goal.batch == true and offer.isBatch == true
end

function P.Recommendation(career, offer)
 for _, goal in ipairs(career and career.goals or {}) do
  if P.MatchesGoal(goal, offer) then return goal.label end
 end
 return nil
end
function P.Projector(routes,width,height,margin)
 margin=margin or 8
 local minX,maxX,minZ,maxZ=math.huge,-math.huge,math.huge,-math.huge
 for _,points in pairs(routes)do for _,p in ipairs(points)do
  minX=math.min(minX,p.X)maxX=math.max(maxX,p.X)minZ=math.min(minZ,p.Z)maxZ=math.max(maxZ,p.Z)
 end end
 if minX==math.huge then return nil end
 local scale=math.min(math.max(1,width-2*margin)/math.max(1,maxX-minX),math.max(1,height-2*margin)/math.max(1,maxZ-minZ))
 local x=(width-(maxX-minX)*scale)/2 local y=(height-(maxZ-minZ)*scale)/2
 -- Use the same orientation as the city signs and the overhead view.
 return function(p)
  return Vector2.new(x + (maxX - p.X) * scale, height - y - (p.Z - minZ) * scale)
 end
end
return P
