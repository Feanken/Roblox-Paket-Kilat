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
-- Classify bends along the remaining route, independent of the camera bearing.
function P.NextTurn(points, segment, cursor, maxDistance)
	local incoming
	local distance = 0
	for i = segment, #points - 1 do
		local step = points[i + 1] - points[i]
		local flat = Vector3.new(step.X, 0, step.Z)
		local length = flat.Magnitude
		if length <= .01 then continue end

		local direction = flat / length
		if incoming then
			local angle = math.deg(math.atan2(incoming:Cross(direction).Y, incoming:Dot(direction)))
			if math.abs(angle) >= 28 then
				local turn = math.abs(angle) >= 150 and "back" or (angle > 0 and "left" or "right")
				return turn, distance, points[i]
			end
		end

		local start = i == segment and cursor or points[i]
		local rest = points[i + 1] - start
		distance += Vector3.new(rest.X, 0, rest.Z).Magnitude
		if distance > maxDistance then return nil end
		incoming = direction
	end
	return nil
end
return P
