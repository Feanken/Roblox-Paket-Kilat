-- Builds depot delivery pads at approved District35 addresses in Studio Edit.
local DistrictDeliveries = {}

local destinations = {
	{id = "CBD01", color = Color3.fromRGB(225, 163, 72)},
	{id = "BQ10", color = Color3.fromRGB(69, 174, 163)},
	{id = "BQ16", color = Color3.fromRGB(69, 174, 163)},
}

function DistrictDeliveries.Build(addressId)
	assert(not game:GetService("RunService"):IsRunning(), "Run in Studio Edit")

	local map = workspace.PaketKilat.Map
	local candidates = map.Districts35.FutureAddresses
	local params = RaycastParams.new()
	params.RespectCanCollide = true
	local models = {}

	for _, destination in ipairs(destinations) do
		local id = destination.id
		if addressId and id ~= addressId then continue end
		assert(not map:FindFirstChild(id), "Delivery already installed: " .. id)
		local address = candidates:FindFirstChild(id)
		assert(address and address:IsA("BasePart"), "Missing district address: " .. id)
		local position = address.Position
		local surface = workspace:Raycast(position + Vector3.yAxis * 2, -Vector3.yAxis * 3, params)
		assert(surface and math.abs(surface.Position.Y - position.Y) <= 0.2, "Address lacks a level floor: " .. id)

		local model = Instance.new("Model")
		model.Name = id

		local pad = Instance.new("Part")
		pad.Name = "DestinationPoint"
		pad.Size = Vector3.new(3.3, 0.08, 4.5)
		pad.CFrame = CFrame.new(surface.Position + Vector3.yAxis * 0.045) * CFrame.Angles(0, -math.pi / 2, 0)
		pad.Color = destination.color
		pad.Material = Enum.Material.SmoothPlastic
		pad.Anchored = true
		pad.CanCollide = false
		pad.CanTouch = false
		pad.CanQuery = false
		pad.CastShadow = false
		pad:SetAttribute("DestinationId", id)
		pad.Parent = model

		local face = Instance.new("SurfaceGui")
		face.Face = Enum.NormalId.Top
		face.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		face.PixelsPerStud = 36
		face.LightInfluence = 0.3
		face.MaxDistance = 35
		face.Parent = pad

		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Font = Enum.Font.GothamBold
		label.TextColor3 = Color3.fromRGB(19, 45, 48)
		label.TextScaled = true
		label.Text = "SERAH\nPAKET"
		label.Parent = face

		models[#models + 1] = model
	end

	assert(#models > 0, "Unknown district address: " .. tostring(addressId))
	for _, model in ipairs(models) do
		model.Parent = map
	end
	return #models
end

return DistrictDeliveries
