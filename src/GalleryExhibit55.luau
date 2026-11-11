-- Edit-only displays for the exhibition in front of Galeri Tepi Air.
local Gallery = {}
local ink = Color3.fromRGB(28, 58, 62)
local paper = Color3.fromRGB(246, 237, 213)
local gold = Color3.fromRGB(225, 171, 74)
local water = Color3.fromRGB(87, 147, 157)
local foliage = Color3.fromRGB(95, 126, 91)
local brick = Color3.fromRGB(157, 88, 65)

local exhibits = {
	{x = -207.45, title = "Kampung sebelum jembatan", credit = "Album Bu Sari"},
	{x = -211.55, title = "Jembatan Kanal", credit = "Catatan Maya dan Raka"},
	{x = -215.65, title = "Pintu galeri terbuka", credit = "Pameran warga · Galeri Tepi Air"},
}

local function part(parent, name, size, transform, color)
	local object = Instance.new("Part")
	object.Name = name
	object.Size = size
	object.CFrame = transform
	object.Color = color
	object.Material = Enum.Material.SmoothPlastic
	object.Anchored = true
	object.CanCollide = false
	object.CanTouch = false
	object.CanQuery = false
	object.Parent = parent
	return object
end

local function rectangle(parent, x, y, w, h, color)
	local box = Instance.new("Frame")
	box.BorderSizePixel = 0
	box.BackgroundColor3 = color
	box.Position = UDim2.fromScale(x, y)
	box.Size = UDim2.fromScale(w, h)
	box.Parent = parent
	return box
end

local function text(parent, value, x, y, w, h, color, font)
	local label = Instance.new("TextLabel")
	label.Text = value
	label.Position = UDim2.fromScale(x, y)
	label.Size = UDim2.fromScale(w, h)
	label.BackgroundTransparency = 1
	label.TextScaled = true
	label.TextColor3 = color
	label.Font = font
	label.Parent = parent
end

local function house(picture, x, color)
	rectangle(picture, x, .43, .2, .39, color)
	rectangle(picture, x - .02, .38, .24, .08, brick)
	rectangle(picture, x + .035, .51, .049, .14, paper)
	rectangle(picture, x + .11, .58, .054, .24, ink)
end

local function illustration(picture, index)
	if index == 1 then
		rectangle(picture, 0, .63, 1, .37, foliage)
		rectangle(picture, 0, .83, 1, .17, Color3.fromRGB(183, 163, 126))
		house(picture, .13, paper)
		house(picture, .41, gold)
		house(picture, .69, Color3.fromRGB(211, 157, 122))
	elseif index == 2 then
		rectangle(picture, 0, .53, 1, .47, water)
		rectangle(picture, 0, .56, .23, .44, foliage)
		rectangle(picture, .77, .56, .23, .44, foliage)
		rectangle(picture, .19, .49, .62, .11, brick)
		rectangle(picture, .19, .38, .62, .035, ink)
		for _, x in {.21, .35, .49, .63, .77} do
			rectangle(picture, x, .38, .022, .14, ink)
		end
		rectangle(picture, .34, .73, .22, .026, paper)
		rectangle(picture, .53, .86, .17, .02, paper)
	else
		rectangle(picture, 0, .71, 1, .29, Color3.fromRGB(160, 110, 75))
		for i, color in ipairs({foliage, water, brick}) do
			local x = .11 + (i - 1) * .28
			rectangle(picture, x, .24, .21, .39, ink)
			rectangle(picture, x + .025, .28, .16, .30, paper)
			rectangle(picture, x + .045, .33, .12, .20, color)
		end
	end
end

function Gallery.Build()
	assert(not game:GetService("RunService"):IsRunning(), "Run in Studio Edit")
	local map = workspace.PaketKilat.Map
	assert(not map:FindFirstChild("GalleryExhibit55"), "Gallery exhibit already installed")
	local basis = map.DepotPad.CFrame
	local params = RaycastParams.new()
	params.RespectCanCollide = true

	for _, exhibit in ipairs(exhibits) do
		for _, dx in {-1.55, 1.55} do
			for _, dz in {-.38, .38} do
				local foot = basis:PointToWorldSpace(Vector3.new(exhibit.x + dx, 1, 243 + dz))
				local hit = workspace:Raycast(foot + Vector3.yAxis * .2, -Vector3.yAxis, params)
				assert(hit and math.abs(hit.Position.Y - foot.Y) < .04, "Unsupported gallery display")
			end
		end
	end

	local folder = Instance.new("Folder")
	folder.Name = "GalleryExhibit55"
	for index, exhibit in ipairs(exhibits) do
		local model = Instance.new("Model")
		model.Name = "Display" .. index
		model.Parent = folder
		local origin = basis * CFrame.new(exhibit.x, 1, 243)
		part(model, "Base", Vector3.new(3.3, .16, .9), origin * CFrame.new(0, .08, 0), ink)
		for _, x in {-1.35, 1.35} do
			part(model, "Post", Vector3.new(.18, 3.7, .18), origin * CFrame.new(x, 1.85, 0), ink)
		end
		local board = part(model, "Board", Vector3.new(3.55, 2.28, .2), origin * CFrame.new(0, 2.64, -.10), ink)
		local gui = Instance.new("SurfaceGui")
		gui.Name = "GalleryDisplay"
		gui.Face = Enum.NormalId.Front
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 60
		gui.MaxDistance = 54
		gui.LightInfluence = .2
		gui.Parent = board

		local covered = rectangle(gui, 0, 0, 1, 1, ink)
		covered.Name = "Covered"
		rectangle(covered, .07, .16, .86, .02, gold)
		text(covered, exhibit.title, .07, .28, .86, .29, paper, Enum.Font.GothamBold)
		text(covered, "Pameran sedang disiapkan", .07, .68, .86, .13, gold, Enum.Font.GothamMedium)

		local opened = rectangle(gui, 0, 0, 1, 1, paper)
		opened.Name = "Exhibit"
		opened.Visible = false
		local picture = rectangle(opened, .06, .07, .88, .58, Color3.fromRGB(184, 198, 175))
		picture.ClipsDescendants = true
		illustration(picture, index)
		text(opened, exhibit.title, .05, .68, .90, .15, ink, Enum.Font.GothamBold)
		text(opened, exhibit.credit, .05, .86, .90, .09, ink, Enum.Font.GothamMedium)
	end
	folder.Parent = map
	return #folder:GetChildren()
end

return Gallery
