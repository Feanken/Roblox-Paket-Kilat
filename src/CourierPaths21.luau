-- Join existing street routes at their last shared junction.
-- Offsets stay in DepotPad's local basis, including after a whole-map rotation.
local P = {}
function P.Between(routes, sourceId, destinationId)
	local destination = routes[destinationId]
	if not destination then return nil end
	if not sourceId then return table.clone(destination) end
	local source = routes[sourceId]
	if not source or sourceId == destinationId then return nil end
	local joint = 0
	for i = 1, math.min(#source, #destination) do
		if (source[i] - destination[i]).Magnitude > .01 then break end
		joint = i
	end
	if joint == 0 then return nil end
	local points = {}
	for i = #source, joint, -1 do table.insert(points, source[i]) end
	for i = joint + 1, #destination do table.insert(points, destination[i]) end
	return points
end
function P.Length(points)
	local length = 0
	for i = 1, #points - 1 do length += (points[i + 1] - points[i]).Magnitude end
	return length
end
return P
