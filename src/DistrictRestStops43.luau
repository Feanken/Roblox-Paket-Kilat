-- Adds functional rest benches to the routes that cross the canal.
local DistrictRest = {}

local stops = {
	{name = "CanalApproach", x = -115, z = 158, yaw = 0, label = "Jembatan Kanal"},
	{name = "QuayGallery", x = -201, z = 213, yaw = -90, label = "Bata Quay"},
}

local function fixture(parent, name, size, frame, color)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = frame
	part.Color = color
	part.Material = Enum.Material.Metal
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Parent = parent
	return part
end

local function addSign(parent, frame)
	local ink = Color3.fromRGB(29, 80, 76)
	fixture(parent, "RestSignPost", Vector3.new(.16, 2.9, .16), frame * CFrame.new(3.55, 1.45, 0), ink)
	local board = fixture(parent, "RestSign", Vector3.new(2.1, 1.05, .15), frame * CFrame.new(3.55, 2.9, 0), ink)
	for _, side in {Enum.NormalId.Front, Enum.NormalId.Back} do
		local face = Instance.new("SurfaceGui")
		face.Face = side
		face.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		face.PixelsPerStud = 48
		face.MaxDistance = 58
		face.LightInfluence = .2
		face.Parent = board

		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(.92, .88)
		label.Position = UDim2.fromScale(.04, .06)
		label.Text = "POS\nISTIRAHAT"
		label.TextScaled = true
		label.TextColor3 = Color3.fromRGB(255, 230, 175)
		label.Font = Enum.Font.GothamBold
		label.Parent = face
	end
end

function DistrictRest.Build()
	assert(not game:GetService("RunService"):IsRunning(), "Run in Studio Edit")
	local map = workspace.PaketKilat.Map
	local rest = map.RestStops27
	local basis = map.DepotPad.CFrame
	local template = map.City36.PublicRealm.StreetFurniture36.CityBench1
	assert(not map:FindFirstChild("DistrictRestStops43"), "District rest stops already installed")
	local groundParams = RaycastParams.new()
	groundParams.RespectCanCollide = true

	local root = Instance.new("Folder")
	root.Name = "DistrictRestStops43"
	local seats = {}

	for _, spec in ipairs(stops) do
		assert(not rest:FindFirstChild(spec.name), "Duplicate rest seat " .. spec.name)
		local frame = basis * CFrame.new(spec.x, 1, spec.z) * CFrame.Angles(0, math.rad(spec.yaw), 0)
		for _, offset in {
			Vector3.new(-2.75, 0, -1.05), Vector3.new(-2.75, 0, 1.05),
			Vector3.new(2.75, 0, -1.05), Vector3.new(2.75, 0, 1.05),
			Vector3.new(3.55, 0, 0),
		} do
			local point = frame:PointToWorldSpace(offset)
			local hit = workspace:Raycast(point + Vector3.yAxis * 1.5, -Vector3.yAxis * 2, groundParams)
			assert(hit and math.abs(hit.Position.Y - point.Y) < .06, "Uneven rest stop " .. spec.name)
		end

		local model = Instance.new("Model")
		model.Name = spec.name
		model.Parent = root
		local bench = template:Clone()
		bench.Name = "Bench"
		bench.Parent = model
		local mesh = assert(bench:FindFirstChildWhichIsA("BasePart", true))
		bench:PivotTo(frame * CFrame.new(0, mesh.Size.Y / 2, 0) * CFrame.Angles(0, math.pi, 0))

		-- Reuse the same invisible seat and prompt convention as the existing public benches.
		local seat = rest.Depot:Clone()
		seat.Name = spec.name
		seat.Size = Vector3.new(math.min(mesh.Size.X * .6, 4), .2, mesh.Size.Z * .5)
		seat.CFrame = frame * CFrame.new(0, mesh.Size.Y * .42, -mesh.Size.Z * .1)
		seat.BenchModel.Value = bench
		seat.RestPrompt27.ActionText = "Duduk dan pulihkan"
		seat.RestPrompt27.ObjectText = spec.label
		seats[#seats + 1] = seat

		addSign(model, frame)
	end

	root.Parent = map
	for _, seat in ipairs(seats) do
		seat.Parent = rest
	end
	return #seats
end

return DistrictRest
