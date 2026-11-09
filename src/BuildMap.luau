-- Jalankan hanya di Edit melalui MCP. Tidak menyentuh objek awal.
assert(not workspace:FindFirstChild("PaketKilat"), "Map PaketKilat sudah ada; inspeksi sebelum mengubah")
local world = Instance.new("Folder")
world.Name = "PaketKilat"
local map = Instance.new("Folder")
map.Name = "Map"
map.Parent = world
local function part(name, size, pos, color, parent)
	local p = Instance.new("Part")
	p.Name, p.Size, p.Position = name, size, pos
	p.Anchored = true
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent or map
	return p
end
local function label(p, text)
	local b = Instance.new("BillboardGui")
	b.Name, b.Size, b.StudsOffset = "Sign", UDim2.fromOffset(300, 64), Vector3.new(0, 3, 0)
	b.MaxDistance, b.AlwaysOnTop = 180, false
	b.Parent = p
	local t = Instance.new("TextLabel")
	t.Size, t.BackgroundTransparency = UDim2.fromScale(1, 1), 0.2
	t.BackgroundColor3, t.TextColor3 = Color3.fromRGB(28, 39, 56), Color3.new(1, 1, 1)
	t.TextSize, t.Font, t.TextWrapped = 18, Enum.Font.GothamBold, true
	t.Text, t.Parent = text, b
end
local green, road = Color3.fromRGB(97, 177, 110), Color3.fromRGB(95, 110, 127)
part("DepotPad", Vector3.new(28, 2, 28), Vector3.new(0, 24, 0), green)
part("HousePad", Vector3.new(28, 2, 28), Vector3.new(100, 24, 0), green)
part("SafeRoadDepot", Vector3.new(12, 2, 40), Vector3.new(0, 24, -26), road)
part("SafeRoadAcross", Vector3.new(112, 2, 12), Vector3.new(50, 24, -40), road)
part("SafeRoadHouse", Vector3.new(12, 2, 40), Vector3.new(100, 24, -26), road)
local plank = part("NarrowPlank", Vector3.new(72, 1, 3), Vector3.new(50, 24.5, 0), Color3.fromRGB(183, 125, 70))
plank.Material = Enum.Material.WoodPlanks
label(plank, "PAPAN SEMPIT\nJalan pintas — hati-hati jatuh!")
local depot = Instance.new("Model")
depot.Name, depot.Parent = "Depot", map
part("BackWall", Vector3.new(6, 9, 1), Vector3.new(-5, 29.5, -12), Color3.fromRGB(248, 189, 63), depot)
part("BackWallRight", Vector3.new(6, 9, 1), Vector3.new(5, 29.5, -12), Color3.fromRGB(248, 189, 63), depot)
part("Roof", Vector3.new(19, 1, 9), Vector3.new(0, 34, -9), Color3.fromRGB(228, 102, 64), depot)
local pickup = part("PickupPoint", Vector3.new(4, 1, 4), Vector3.new(0, 25.5, -5), Color3.fromRGB(255, 207, 79), depot)
label(pickup, "PAKET KILAT! · DEPOT\nE atau tombol Ambil pesanan")
local house = Instance.new("Model")
house.Name, house.Parent = "Rumah01", map
part("Body", Vector3.new(13, 9, 10), Vector3.new(104, 29.5, -8), Color3.fromRGB(83, 189, 206), house)
part("Roof", Vector3.new(16, 2, 13), Vector3.new(104, 35, -8), Color3.fromRGB(224, 103, 75), house)
part("Door", Vector3.new(3, 6, 0.3), Vector3.new(104, 28, -2.85), Color3.fromRGB(97, 65, 45), house)
local destination = part("DestinationPoint", Vector3.new(5, 0.3, 5), Vector3.new(100, 25.15, 3), Color3.fromRGB(102, 224, 185), house)
destination:SetAttribute("DestinationId", "Rumah01")
label(destination, "RUMAH BU SARI\nE atau tombol Antar di dekat petak ini")
local recovery = part("RecoveryPoint", Vector3.new(5, 0.3, 5), Vector3.new(8, 25.15, 4), Color3.fromRGB(104, 199, 247))
label(recovery, "TITIK PEMULIHAN\nAmbil ulang paket pada petak biru")
local spawn = Instance.new("SpawnLocation")
spawn.Name, spawn.Size, spawn.Position = "PrototypeSpawn", Vector3.new(5, 1, 5), Vector3.new(-6, 25.5, 5)
spawn.Anchored, spawn.Neutral, spawn.Duration = true, true, 0
spawn.Color, spawn.Parent = Color3.fromRGB(245, 245, 230), map
local active = Instance.new("Folder")
active.Name, active.Parent = "ActivePackages", world
world:SetAttribute("Stage", "T01-T06")
-- Posisi arena aktual yang diperiksa setelah penataan di Studio.
for _,v in ipairs(world:GetDescendants()) do
	if v:IsA("BasePart") then v.Position += Vector3.new(0, 1045 - 24, 0) end
end
world.Parent = workspace
return "Map dibuat; objek awal dipertahankan"
