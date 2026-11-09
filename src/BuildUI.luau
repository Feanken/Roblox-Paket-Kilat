-- Jalankan di Edit sekali, setelah memastikan PaketKilatUI belum ada.
assert(not game.StarterGui:FindFirstChild("PaketKilatUI"), "HUD sudah ada; inspeksi dulu")
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "PaketKilatUI", false, 10
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
local function frame(parent, name, size, position, color)
	local f = Instance.new("Frame")
	f.Name, f.Size, f.Position = name, size, position
	f.BackgroundColor3, f.BorderSizePixel, f.Parent = color, 0, parent
	return f
end
local function round(parent, radius)
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, radius) c.Parent = parent
end
local function text(parent, name, size, position, value, fontSize)
	local t = Instance.new("TextLabel")
	t.Name, t.Size, t.Position, t.Text = name, size, position, value
	t.BackgroundTransparency, t.TextSize = 1, fontSize
	t.TextColor3, t.Font = Color3.fromRGB(240,246,250), Enum.Font.GothamMedium
	t.TextXAlignment, t.TextYAlignment = Enum.TextXAlignment.Left, Enum.TextYAlignment.Center
	t.Parent = parent
	return t
end
local root = frame(gui, "Root", UDim2.fromScale(1,1), UDim2.new(), Color3.new())
root.BackgroundTransparency = 1
local card = frame(root, "TopCard", UDim2.fromOffset(340,156), UDim2.fromOffset(14,12), Color3.fromRGB(27,42,58))
round(card,12)
local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(75,109,132) stroke.Transparency=0.35 stroke.Parent=card
local title=text(card,"Title",UDim2.new(1,-140,0,22),UDim2.fromOffset(14,9),"PAKET KILAT!",14)
title.Font, title.TextColor3 = Enum.Font.GothamBold, Color3.fromRGB(255,205,86)
local coins=text(card,"Coins",UDim2.fromOffset(116,24),UDim2.new(1,-130,0,8),"0 koin",18)
coins.TextXAlignment=Enum.TextXAlignment.Right
text(card,"Destination",UDim2.new(1,-28,0,24),UDim2.fromOffset(14,39),"Memuat pesanan...",17)
text(card,"ConditionText",UDim2.new(1,-28,0,20),UDim2.fromOffset(14,67),"Belum ada paket",13)
local track=frame(card,"ConditionTrack",UDim2.new(1,-28,0,6),UDim2.fromOffset(14,94),Color3.fromRGB(58,76,92))
round(track,3)
local fill=frame(track,"Fill",UDim2.fromScale(0,1),UDim2.new(),Color3.fromRGB(98,222,175))
round(fill,3)
local hint=text(card,"Hint",UDim2.new(1,-28,0,38),UDim2.fromOffset(14,106),"Koin dan rekor berlaku selama sesi ini.",12)
hint.TextWrapped=true
local actions=frame(root,"Actions",UDim2.fromOffset(152,108),UDim2.new(1,-16,0.47,0),Color3.new())
actions.AnchorPoint, actions.BackgroundTransparency = Vector2.new(1,0.5), 1
for index,name in ipairs({"Primary","Secondary"}) do
	local b=Instance.new("TextButton")
	b.Name, b.Size, b.Position = name, UDim2.fromOffset(152,48), UDim2.fromOffset(0,(index-1)*58)
	b.BackgroundColor3, b.TextColor3 = Color3.fromRGB(255,202,77), Color3.fromRGB(28,41,54)
	b.BorderSizePixel, b.Font, b.TextSize = 0, Enum.Font.GothamBold, 15
	b.Text, b.Parent = "Memuat...", actions
	b.Visible = name == "Primary"
	round(b,10)
end
gui.Parent=game.StarterGui
game.StarterGui.ScreenOrientation=Enum.ScreenOrientation.LandscapeSensor
return "PaketKilatUI dibuat"
