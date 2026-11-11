-- Studio authoring for fixed, world-space visitor maps.
local Wayfinding = {}
local ink = Color3.fromRGB(30, 61, 63)
local cream = Color3.fromRGB(246, 238, 218)
local gold = Color3.fromRGB(255, 207, 92)
local water = Color3.fromRGB(40, 84, 89)
local roads = Color3.fromRGB(225, 219, 190)

local function makePart(model, name, size, transform, color, material)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.CFrame = transform
    part.Color = color
    part.Material = material
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Parent = model
    return part
end

local function panelGui(board)
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 48
    gui.LightInfluence = .2
    gui.MaxDistance = 80
    gui.Parent = board
    return gui
end

local function label(parent, value, position, size, color, zIndex)
    local text = Instance.new("TextLabel")
    text.Text = value
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.TextColor3 = color
    text.BackgroundTransparency = 1
    text.Position = position
    text.Size = size
    text.ZIndex = zIndex or 1
    text.Parent = parent
    return text
end

local function rectangle(parent, color, position, size, zIndex)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0
    frame.Position = position
    frame.Size = size
    frame.ZIndex = zIndex or 1
    frame.Parent = parent
    return frame
end

local function drawMap(gui, hereX, hereZ)
    local background = rectangle(gui, water, UDim2.fromScale(.04, .19), UDim2.fromScale(.92, .63))
    background.Name = "DistrictMap"
    background.ClipsDescendants = true

    -- Match the overhead city view. Local X increases toward the left of that view.
    local pixelHeight = 7 * 48 * .63
    local pixelSize = Vector2.new(pixelHeight * 620 / 362, pixelHeight)
    local map = rectangle(background, water, UDim2.fromScale(.5, .5), UDim2.fromOffset(pixelSize.X, pixelSize.Y))
    map.AnchorPoint = Vector2.new(.5, .5)
    local function point(x, z)
        return Vector2.new((160 - x) / 620, (322 - z) / 362)
    end

    local function area(x1, z1, x2, z2, color)
        local corner = point(x2, z2)
        local size = point(x1, z1) - corner
        rectangle(map, color, UDim2.fromScale(corner.X, corner.Y), UDim2.fromScale(size.X, size.Y), 2)
    end

    area(-138, -24, 145, 310, Color3.fromRGB(102, 134, 106))
    area(-445, 94, -163, 306, Color3.fromRGB(168, 106, 84))
    area(-62, 202, 48, 266, Color3.fromRGB(65, 105, 75))

    -- Size and rotation use canvas pixels so diagonal roads keep their angle.
    local segments = {
        {-130,28,132,28}, {-130,144,132,144}, {-130,28,-130,144},
        {132,28,132,144}, {-24,28,-24,144},
        {-92,144,-92,282}, {76,144,76,282}, {-115,282,125,282},
        {-185,144,-130,144}, {-423,114,-423,286}, {-185,114,-185,286},
        {-423,114,-185,114}, {-423,171,-185,171}, {-423,229,-185,229},
        {-423,286,-185,286}, {-185,114,-423,286},
    }
    for _, segment in segments do
        local first = point(segment[1], segment[2]) * pixelSize
        local last = point(segment[3], segment[4]) * pixelSize
        local delta = last - first
        local midpoint = (first + last) / 2
        local road = rectangle(map, roads, UDim2.fromOffset(midpoint.X, midpoint.Y), UDim2.fromOffset(delta.Magnitude, 3), 3)
        road.AnchorPoint = Vector2.new(.5, .5)
        road.Rotation = math.deg(math.atan2(delta.Y, delta.X))
    end

    for _, marker in {
        {"KOTA LAMA", 40, 82},
        {"TAMAN KOTA", -6, 250},
        {"BATA QUAY", -306, 262},
        {"JEMBATAN", -149, 121},
    } do
        local position = point(marker[2], marker[3])
        local title = label(map, marker[1], UDim2.fromScale(position.X, position.Y), UDim2.fromOffset(88, 18), cream, 4)
        title.AnchorPoint = Vector2.new(.5, .5)
        title.BackgroundColor3 = ink
        title.BackgroundTransparency = .12
    end

    local bridge = point(-149, 144)
    local bridgeMark = rectangle(map, gold, UDim2.fromScale(bridge.X, bridge.Y), UDim2.fromOffset(5, 5), 4)
    bridgeMark.AnchorPoint = Vector2.new(.5, .5)
    local position = point(hereX, hereZ)
    local marker = rectangle(map, gold, UDim2.fromScale(position.X, position.Y), UDim2.fromOffset(13, 13), 5)
    marker.AnchorPoint = Vector2.new(.5, .5)
    Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)
    local outline = Instance.new("UIStroke")
    outline.Color = ink
    outline.Thickness = 2
    outline.Parent = marker
end

function Wayfinding.RefreshMaps()
    assert(not game:GetService("RunService"):IsRunning(), "Run in Studio Edit")
    local map = workspace.PaketKilat.Map
    local basis = map.DepotPad.CFrame
    for _, name in {"Depot", "Taman", "BataQuay"} do
        local board = map.Wayfinding38[name].Board
        local gui = board:FindFirstChildOfClass("SurfaceGui")
        local previous = assert(gui:FindFirstChildOfClass("Frame"), "Missing map on " .. name)
        local here = basis:PointToObjectSpace(board.Position)
        drawMap(gui, here.X, here.Z)
        previous:Destroy()
    end
    return 3
end

function Wayfinding.Build()
    assert(not game:GetService("RunService"):IsRunning(), "Run in Studio Edit")
    local map = workspace.PaketKilat.Map
    assert(not map:FindFirstChild("Wayfinding38"), "Wayfinding already installed")
    local basis = map.DepotPad.CFrame
    local placements = {
        {"Depot",23,15,0,"PETA KAMPUNG KILAT","Jalan utama terhubung ke Pasar Pagi dan jembatan."},
        {"Taman",14,202,0,"PETA TAMAN KOTA","Jembatan menuju Bata Quay berada di sisi kanal."},
        {"BataQuay",-170.85,163,90,"PETA BATA QUAY","Jalan diagonal menghubungkan blok ruko."},
        {"Jembatan",-135.15,159.5,-90,"JEMBATAN KANAL","Bata Quay lewat penyeberangan kanal", true},
        {"Boulevard",8,269,180,"BOULEVARD TAMAN","Kios dan jalur tepi taman", true},
    }
    local floorParams = RaycastParams.new()
    floorParams.RespectCanCollide = true
    for _, placement in placements do
        local width = placement[7] and 7 or 12
        for _, offset in {-width * .34, width * .34} do
            local frame = basis * CFrame.new(placement[2], 1, placement[3]) * CFrame.Angles(0, math.rad(placement[4]), 0)
            local foot = frame:PointToWorldSpace(Vector3.new(offset, 0, 0))
            local hit = workspace:Raycast(foot + Vector3.new(0, .3, 0), Vector3.new(0, -.7, 0), floorParams)
            assert(hit and math.abs(hit.Position.Y - foot.Y) < .03, "Unsupported sign at " .. placement[1])
        end
    end

    local root = Instance.new("Folder")
    root.Name = "Wayfinding38"
    for _, placement in placements do
        local name, x, z, yaw, title, subtitle, small = table.unpack(placement)
        local frame = basis * CFrame.new(x, 1, z) * CFrame.Angles(0, math.rad(yaw), 0)
        local width, height = small and 7 or 12, small and 2.2 or 7
        local bottom = small and 3 or 2
        local model = Instance.new("Model")
        model.Name = name
        for _, side in {-1, 1} do
            local offset = side * width * .34
            makePart(model, "Foot", Vector3.new(.8,.22,.8), frame * CFrame.new(offset,.11,0), cream, Enum.Material.Concrete)
            makePart(model, "Post", Vector3.new(.24,bottom+.3,.24), frame * CFrame.new(offset,(bottom+.3)/2,0), ink, Enum.Material.Metal)
        end
        local board = makePart(model, "Board", Vector3.new(width,height,.3), frame * CFrame.new(0,bottom+height/2,0), ink, Enum.Material.Metal)
        local gui = panelGui(board)
        if small then
            label(gui,title,UDim2.fromScale(.04,.08),UDim2.fromScale(.92,.48),cream)
            label(gui,subtitle,UDim2.fromScale(.05,.60),UDim2.fromScale(.90,.25),gold)
        else
            label(gui,title,UDim2.fromScale(.04,.035),UDim2.fromScale(.92,.12),cream)
            drawMap(gui,x,z)
            label(gui,"●  KAMU DI SINI",UDim2.fromScale(.04,.835),UDim2.fromScale(.92,.058),gold)
            label(gui,subtitle,UDim2.fromScale(.04,.904),UDim2.fromScale(.92,.065),cream)
        end
        model.Parent = root
    end
    root.Parent = map
    return #root:GetChildren()
end

return Wayfinding
