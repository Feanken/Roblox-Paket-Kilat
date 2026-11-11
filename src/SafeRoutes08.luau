-- Current map routes. General guidance, not a guarantee of no hazards.
-- Offsets use the pickup point as the origin and DepotPad for orientation.
local function districtRoute(stops)
	local route = {}
	for _, stop in ipairs(stops) do
		table.insert(route, Vector3.new(stop[1] + 2, 0, stop[2] + 6))
	end
	return route
end

return {
CBD01=districtRoute({{-2,-6},{0,28},{-24,28},{-24,144},{-38,144},{-38,168}}),
BQ10=districtRoute({{-2,-6},{0,28},{-24,28},{-24,144},{-185,144},{-185,171},{-223.8,171},{-223.8,186.2}}),
Rumah01={Vector3.new(0.0000,0,0.0000),Vector3.new(2.0000,0,34.0000),Vector3.new(100.0000,0,34.0000),Vector3.new(100.0000,0,9.0000)},
Rumah02={Vector3.new(0.0000,0,0.0000),Vector3.new(2.0000,0,34.0000),Vector3.new(-100.0000,0,34.0000),Vector3.new(-100.0000,0,9.0000)},
Rumah03={Vector3.new(0.0000,0,0.0000),Vector3.new(2.0000,0,34.0000),Vector3.new(-22.0000,0,34.0000),Vector3.new(-22.0000,0,150.0000),Vector3.new(-3.0000,0,150.0000),Vector3.new(-3.0000,0,120.0000)},
Rumah04={Vector3.new(0.0000,0,0.0000),Vector3.new(2.0000,0,34.0000),Vector3.new(-22.0000,0,34.0000),Vector3.new(-22.0000,0,150.0000),Vector3.new(110.0000,0,150.0000),Vector3.new(110.0000,0,120.0000)},
Rumah05={Vector3.new(0.0000,0,0.0000),Vector3.new(2.0000,0,34.0000),Vector3.new(-22.0000,0,34.0000),Vector3.new(-22.0000,0,150.0000),Vector3.new(-100.0000,0,150.0000),Vector3.new(-100.0000,0,120.0000)},
}