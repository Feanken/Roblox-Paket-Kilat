-- World-space signs that identify the existing depot and district hand-off points.
local Stations = {}

local stops = {
	{id = "Depot", side = -6, forward = 6, yaw = 180, color = Color3.fromRGB(31, 90, 82), title = "PAPAN KURIR", subtitle = "Pesanan · Cerita"},
	{id = "CBD01", side = -4.5, yaw = 0, color = Color3.fromRGB(144, 97, 34), title = "SERAH PAKET", subtitle = "Menara Kilat"},
	{id = "BQ10", side = 4.5, yaw = 0, color = Color3.fromRGB(30, 91, 88), title = "SERAH PAKET", subtitle = "Kantor Arsitek"},
	{id = "BQ16", side = 4.5, yaw = 0, color = Color3.fromRGB(49, 83, 119), title = "SERAH PAKET", subtitle = "Galeri Tepi Air"},
}

local function part(parent, name, size, cf, color)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cf
	item.Color = color
	item.Material = Enum.Material.SmoothPlastic
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.Parent = parent
	return item
end

local function text(gui, value, top, height, font, color)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Position = UDim2.fromScale(.04, top)
	label.Size = UDim2.fromScale(.92, height)
	label.Text = value
	label.TextScaled = true
	label.TextColor3 = color
	label.Font = font
	label.Parent = gui
end

function Stations.Build()
	assert(not game:GetService("RunService"):IsRunning(), "Run in Studio Edit")
	local map = workspace.PaketKilat.Map
	assert(not map:FindFirstChild("CourierStations46"), "Courier stations already installed")
	local basis = map.DepotPad.CFrame
	local ray = RaycastParams.new()
	ray.RespectCanCollide = true
	local root = Instance.new("Folder")
	root.Name = "CourierStations46"
	local metal = Color3.fromRGB(44, 58, 57)
	local cream = Color3.fromRGB(255, 241, 214)
	for _, site in ipairs(stops) do
		local anchor = site.id == "Depot" and map.Depot.PickupPoint or map[site.id].DestinationPoint
		local point = basis:PointToObjectSpace(anchor.Position)
		local origin = basis * CFrame.new(point.X + site.side, 1, point.Z + (site.forward or 0)) * CFrame.Angles(0, math.rad(site.yaw), 0)
		for _, x in {-1.08, 1.08} do
			for _, z in {-.51, .51} do
				local at = origin:PointToWorldSpace(Vector3.new(x, 0, z))
				local hit = workspace:Raycast(at + Vector3.yAxis * 1.4, -Vector3.yAxis * 2, ray)
				assert(hit and math.abs(hit.Position.Y - at.Y) < .06, "Unsupported courier station " .. site.id)
			end
		end
		local model = Instance.new("Model")
		model.Name = site.id
		model.Parent = root
		part(model, "Base", Vector3.new(2.3, .16, 1.18), origin * CFrame.new(0, .08, 0), metal)
		part(model, "Stand", Vector3.new(.23, 1.3, .24), origin * CFrame.new(0, .81, 0), metal)
		local board = part(model, "Sign", Vector3.new(2.65, 1.3, .16), origin * CFrame.new(0, 2.11, 0), site.color)
		part(model, "Trim", Vector3.new(2.65, .075, .18), origin * CFrame.new(0, 2.78, 0), cream)

		local gui = Instance.new("SurfaceGui")
		gui.Face = Enum.NormalId.Front
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 56
		gui.LightInfluence = .2
		gui.MaxDistance = 55
		gui.Parent = board
		text(gui, site.title, .10, .39, Enum.Font.GothamBold, cream)
		text(gui, site.subtitle, .56, .25, Enum.Font.GothamMedium, cream)
	end
	root.Parent = map
	return #root:GetChildren()
end

return Stations
