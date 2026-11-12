-- Read-only view of the current delivery and the authored street routes.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local shared = game.ReplicatedStorage:WaitForChild("PaketKilat")
local theme = require(shared.Shared.UITheme12)
local preview = require(shared.Shared.JobPreview28)
local paths = require(shared.Shared.CourierPaths21)
local routes = require(shared.Shared.SafeRoutes08)
local ui = player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI"):WaitForChild("Root")

local function frame(parent, name, color, z)
	local item = Instance.new("Frame")
	item.Name, item.BackgroundColor3, item.ZIndex = name, color, z
	item.BorderSizePixel = 0
	item.Parent = parent
	return item
end

local function label(parent, name, size, z)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Font = Enum.Font.GothamBold
	item.TextColor3 = theme.Ink
	item.TextSize = size
	item.TextTruncate = Enum.TextTruncate.AtEnd
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.BackgroundTransparency = 1
	item.ZIndex = z
	item.Parent = parent
	return item
end

local function button(parent, name, caption, z)
	local item = Instance.new("TextButton")
	item.Name, item.Text, item.ZIndex = name, caption, z
	theme.ToolbarButton(item)
	item.Parent = parent
	return item
end

local toggle = button(ui, "LiveMapToggle", "Peta [K]", 5)
toggle.Visible = false
local overlay = frame(ui, "LiveRouteMap", theme.Ink, 35)
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundTransparency = .4
overlay.Active = true
overlay.Visible = false
local panel = frame(overlay, "Panel", theme.Cream, 36)
panel.AnchorPoint = Vector2.new(.5, .5)
panel.Position = UDim2.fromScale(.5, .5)
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
local title = label(panel, "Title", 16, 37)
title.Text = "Peta pengantaran"
title.Position = UDim2.fromOffset(12, 8)
title.Size = UDim2.new(1, -70, 0, 34)
local close = button(panel, "Close", "×", 38)
close.Position = UDim2.new(1, -50, 0, 4)
close.Size = UDim2.fromOffset(44, 44)
close.TextSize = 21
local canvas = frame(panel, "StreetMap", theme.Soft, 37)
canvas.Position = UDim2.fromOffset(12, 50)
canvas.Size = UDim2.new(1, -24, 1, -96)
canvas.ClipsDescendants = true
Instance.new("UICorner", canvas).CornerRadius = UDim.new(0, 8)
local streets = frame(canvas, "Streets", theme.Soft, 38)
streets.BackgroundTransparency = 1
streets.Size = UDim2.fromScale(1, 1)
local caption = label(panel, "Destination", 12, 37)
caption.Position = UDim2.new(0, 12, 1, -42)
caption.Size = UDim2.new(1, -24, 0, 20)
local legend = label(panel, "Legend", 10, 37)
legend.Text = "K Kamu   ·   D Depot   ·   T Titik tujuan"
legend.Position = UDim2.new(0, 12, 1, -23)
legend.Size = UDim2.new(1, -24, 0, 16)
legend.TextColor3 = theme.Muted

local function marker(name, character, color, ink, z)
	local dot = label(canvas, name, 11, z)
	dot.Text, dot.BackgroundColor3, dot.TextColor3 = character, color, ink
	dot.BackgroundTransparency = 0
	dot.TextXAlignment = Enum.TextXAlignment.Center
	dot.AnchorPoint = Vector2.new(.5, .5)
	dot.Size = UDim2.fromOffset(19, 19)
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	return dot
end

local depotDot = marker("Depot", "D", theme.Ink, theme.Cream, 41)
local targetDot = marker("Target", "T", theme.Gold, theme.Ink, 42)
local playerDot = marker("Player", "K", Color3.fromRGB(25, 115, 104), theme.White, 43)
local state, connections = {}, {}
local drawnKey, project
local function bind(signal, callback)
	table.insert(connections, signal:Connect(callback))
end

local function blocked()
	local gallery = ui:FindFirstChild("GalleryReader")
	local result = ui:FindFirstChild("DeliveryCelebration")
	return ui.Shop.Visible or ui:GetAttribute("JobBoardOpen17") or ui:GetAttribute("AudioOpen33")
		or ui:GetAttribute("OrderOptionsOpen") or (gallery and gallery.Visible) or (result and result.Visible)
end

local function setOpen(open)
	overlay.Visible = open == true
	ui:SetAttribute("LiveRouteMapOpen", overlay.Visible)
	if overlay.Visible then
		ui:SetAttribute("MobileMenuOpen18", false)
		ui:SetAttribute("MobileTargetOpen18", false)
	end
end

local function draw(size, destination, source)
	local key = string.format("%d:%d:%s:%s", size.X, size.Y, destination or "", source or "")
	if key == drawnKey then return end
	drawnKey = key
	streets:ClearAllChildren()
	project = preview.Projector(routes, size.X, size.Y, 14)
	local function line(a, b, color, thickness, z)
		local first, last = project(a), project(b)
		local delta = last - first
		local item = frame(streets, "Road", color, z)
		item.AnchorPoint = Vector2.new(.5, .5)
		item.Position = UDim2.fromOffset((first.X + last.X) / 2, (first.Y + last.Y) / 2)
		item.Size = UDim2.fromOffset(delta.Magnitude, thickness)
		item.Rotation = math.deg(math.atan2(delta.Y, delta.X))
	end
	for _, points in pairs(routes) do
		for i = 1, #points - 1 do line(points[i], points[i + 1], theme.Line, 2, 38) end
	end
	local active = destination and paths.Between(routes, source, destination)
	if active then
		for i = 1, #active - 1 do line(active[i], active[i + 1], theme.Ink, 3, 39) end
	end
end

local function render()
	local mobile = theme.IsMobile(ui)
	local active = state.status == "Carrying" or state.status == "Dropped"
	local ready = state.profileReady and state.depotPosition ~= nil
	local otherOverlay = blocked()
	if overlay.Visible and (not ready or otherOverlay) then setOpen(false) end
	toggle.Visible = ready == true and not otherOverlay and not overlay.Visible
		and (not mobile or ui:GetAttribute("MobileMenuOpen18") == true)
	toggle.Size = UDim2.fromOffset(mobile and 64 or 84, 44)
	toggle.Position = mobile and UDim2.new(1, active and -158 or -88, 0, 162)
		or UDim2.new(1, -282, 0, (ui.AbsoluteSize.Y < 500 and 12 or 20) + 50)
	if not mobile and ui.AbsoluteSize.X < 570 then
		toggle.Position = UDim2.new(1, -98, 1, -56)
	end
	toggle.Text = mobile and "Peta" or "Peta [K]"
	if not overlay.Visible then return end

	local size = ui.AbsoluteSize
	panel.Size = UDim2.fromOffset(math.max(1, math.min(580, size.X - 24)), math.max(1, math.min(360, size.Y - 12)))
	local mapSize = canvas.AbsoluteSize
	if mapSize.X < 28 or mapSize.Y < 28 then return end
	local carrying = state.status == "Carrying"
	local returning = state.status == "Idle" and state.lastResult and not state.relayOffer
	local destination = carrying and state.destinationId or returning and state.lastResult.destinationId
	draw(mapSize, destination or nil, carrying and state.sourceId or nil)
	local basis = state.routeBasis or CFrame.identity
	local function place(dot, worldPosition)
		dot.Visible = worldPosition ~= nil
		if not worldPosition then return false end
		local offset = basis:VectorToObjectSpace(worldPosition - state.depotPosition)
		local point = project(offset)
		local x = math.clamp(point.X, 10, mapSize.X - 10)
		local y = math.clamp(point.Y, 10, mapSize.Y - 10)
		dot.Position = UDim2.fromOffset(x, y)
		return x ~= point.X or y ~= point.Y
	end
	local target = state.depotPosition
	local name = "Depot"
	if carrying then
		target, name = state.destinationPosition, state.destinationName
		local guide = workspace:FindFirstChild("PaketKilatLocalSafeRoute")
		local stamp = state.stampNavigation and guide and guide:GetAttribute("GuidedStampPosition26")
		if stamp then target, name = stamp, "Pos cap → " .. state.destinationName end
	elseif state.status == "Dropped" then
		target = not state.outOfBounds and state.packagePosition or nil
		name = state.atRecovery and "Petak pemulihan" or state.outOfBounds and "Paket keluar jalur" or "Paket terlepas"
	elseif state.relayOffer and workspace:GetServerTimeNow() < state.relayOffer.expiresAt then
		target, name = state.relayOffer.pickupPosition, "Ambil titipan"
	end
	local character = player.Character
	local characterRoot = character and character:FindFirstChild("HumanoidRootPart")
	place(depotDot, state.depotPosition)
	place(targetDot, target ~= state.depotPosition and target or nil)
	local outside = place(playerDot, characterRoot and characterRoot.Position)
	caption.Text = name or "Tujuan"
	legend.Text = outside and "K Posisi di tepi peta   ·   D Depot   ·   T Tujuan"
		or "K Kamu   ·   D Depot   ·   T Tujuan"
end

local function toggleMap()
	if overlay.Visible then
		setOpen(false)
	elseif state.profileReady and state.depotPosition and not blocked() then
		setOpen(true)
	end
	render()
end

bind(toggle.Activated, toggleMap)
bind(close.Activated, function() setOpen(false) render() end)
bind(player.CharacterRemoving, function() setOpen(false) end)
bind(shared.Remotes.StateChanged.OnClientEvent, function(snapshot)
	state = snapshot
	render()
end)
CAS:BindAction("PKLiveMap", function(_, input)
	if UIS:GetFocusedTextBox() or not state.profileReady then return Enum.ContextActionResult.Pass end
	if input == Enum.UserInputState.Begin then toggleMap() end
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.K)
task.delay(1.6, function()
	if script.Parent and not state.profileReady then shared.Remotes.ActionRequest:FireServer("Sync") end
end)
local elapsed = 0
bind(RunService.Heartbeat, function(dt)
	elapsed += dt
	if elapsed >= .1 then elapsed = 0 render() end
end)
script.Destroying:Connect(function()
	for _, connection in ipairs(connections) do connection:Disconnect() end
	CAS:UnbindAction("PKLiveMap")
	setOpen(false)
	overlay:Destroy()
	toggle:Destroy()
end)
