-- Edit-mode cleanup of the paving and furniture by Floris Sudut.
local Cleanup = {}

function Cleanup.Build()
	assert(not game:GetService("RunService"):IsRunning(), "Run in Studio Edit")
	local map = workspace.PaketKilat.Map
	local basis = map.DepotPad.CFrame
	local quay = map.Districts35.Surface35.BrickQuay
	assert(not quay:FindFirstChild("FlorisPavingJoint"), "Cleanup already installed")

	local furniture = map.City36.PublicRealm.StreetFurniture36
	local bistro
	for _, model in furniture:GetChildren() do
		local top = model.Name == "CafeBistro" and model:FindFirstChild("RoundTable")
		if top then
			local at = basis:PointToObjectSpace(top.Position)
			if (Vector2.new(at.X, at.Z) - Vector2.new(-281, 211)).Magnitude < .1 then
				bistro = model
				break
			end
		end
	end
	assert(bistro, "Floris bistro missing")

	local ray = RaycastParams.new()
	ray.RespectCanCollide = true
	local function floor(x, z)
		return workspace:Raycast(basis:PointToWorldSpace(Vector3.new(x, 1.18, z)), -Vector3.yAxis * 2, ray)
	end
	local side = assert(floor(-276.8, 215.5), "Paving edge missing")
	local gap = assert(floor(-277, 215.5), "Lower surface missing")
	assert(side.Position.Y - gap.Position.Y > .2, "Paving joint already filled")
	for _, x in {-276.35, -273.5, -270.65} do
		for _, z in {211.45, 212, 212.55} do
			local hit = floor(x, z)
			assert(hit and hit.Instance.Material == Enum.Material.Pavement and math.abs(hit.Position.Y - side.Position.Y) < .03, "Uneven cafe footprint")
		end
	end

	local joint = Instance.new("Part")
	joint.Name = "FlorisPavingJoint"
	joint.Size = Vector3.new(.14, .5, 1.02)
	joint.CFrame = basis * CFrame.new(-277, .74, 215.46)
	joint.Anchored = true
	joint.CanTouch = false
	joint.Material = Enum.Material.Concrete
	joint.Color = side.Instance.Color
	joint.Parent = quay

	-- The neutral finish keeps the diagonal pieces from rotating the paver pattern.
	local resurfaced = 0
	for _, part in quay:GetDescendants() do
		if part:IsA("BasePart") and part.Material == Enum.Material.Pavement then
			part.Material = Enum.Material.Concrete
			resurfaced += 1
		end
	end
	bistro:PivotTo(bistro:GetPivot() + basis:VectorToWorldSpace(Vector3.new(7.5, 0, 1)))
	return resurfaced
end

return Cleanup
