local Cleanup = {}

function Cleanup.Build()
	assert(not game:GetService("RunService"):IsRunning(), "Run in Studio Edit")
	local map = workspace.PaketKilat.Map
	local basis = map.DepotPad.CFrame
	local earth = workspace.ContinuousEarth
	assert(earth:GetAttribute("Foundation35"), "Bata Quay foundation missing")
	local top = basis:PointToObjectSpace(earth.CFrame:PointToWorldSpace(Vector3.new(0, earth.Size.Y / 2, 0)))
	assert(math.abs(top.Y - .5) < .01 and math.abs(top.X + 304) < .01, "Unexpected foundation geometry")
	local bench = map.Districts35.StreetDetails.QuayPockets35.PocketBench2
	local current = basis:PointToObjectSpace(bench:GetPivot().Position)
	assert((Vector2.new(current.X, current.Z) - Vector2.new(-270, 210)).Magnitude < .1, "Unexpected bench position")

	-- Keep the foundation bottom in place and its top below the road and pavement.
	local rise = .47
	earth.Size += Vector3.new(0, rise, 0)
	earth.CFrame += basis:VectorToWorldSpace(Vector3.new(0, rise / 2, 0))
	bench:PivotTo(bench:GetPivot() + basis:VectorToWorldSpace(Vector3.new(-19, 0, 3)))
	return "Foundation leveled and bench moved"
end

return Cleanup
