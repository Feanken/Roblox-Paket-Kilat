-- Local, non-colliding customers. Reactions only follow a new server delivery result.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local shared = game.ReplicatedStorage:WaitForChild("PaketKilat")
local Config = require(shared.Shared.Config)
local Theme = require(shared.Shared.UITheme12)
local map = workspace:WaitForChild("PaketKilat"):WaitForChild("Map")
local ui = player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI"):WaitForChild("Root")
local folder = Instance.new("Folder")
folder.Name = "PaketKilatLocalCustomers22"
folder.Archivable = false
folder.Parent = workspace
local customers, connections = {}, {}
local palette = {
	Color3.fromRGB(54, 145, 152), Color3.fromRGB(212, 143, 73), Color3.fromRGB(151, 107, 178),
	Color3.fromRGB(91, 146, 103), Color3.fromRGB(215, 179, 65),
}
local function create(id, index)
	local model = Instance.new("Model")
	model.Name = id
	model:SetAttribute("HouseId", id)
	local parts = {}
	local function piece(name, size, color, shape)
		local p = Instance.new("Part")
		p.Name, p.Size, p.Color = name, size, color
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
		p.Transparency = 1
		if shape then p.Shape = shape end
		p.Parent = model
		parts[name] = p
		return p
	end
	local skin = index % 2 == 0 and Color3.fromRGB(177, 124, 91) or Color3.fromRGB(208, 155, 114)
	local ink = Color3.fromRGB(41, 49, 53)
	piece("Torso", Vector3.new(1.5, 1.7, .8), palette[index])
	piece("Head", Vector3.new(1.12, 1.12, 1.06), skin, Enum.PartType.Ball)
	for _, side in {"Left", "Right"} do
		piece(side .. "Arm", Vector3.new(.45, 1.6, .55), skin)
		piece(side .. "Leg", Vector3.new(.58, 1.6, .65), ink)
	end
	piece("Hair", Vector3.new(1.18, .28, 1.1), Color3.fromRGB(68, 49, 39))
	if index % 2 == 1 then
		piece("BackHair", Vector3.new(1.12, .85, .3), Color3.fromRGB(68, 49, 39))
		piece("Bun", Vector3.new(.55, .55, .55), Color3.fromRGB(68, 49, 39), Enum.PartType.Ball)
	end
	piece("EyeLeft", Vector3.new(.1, .1, .06), ink)
	piece("EyeRight", Vector3.new(.1, .1, .06), ink)
	piece("Smile", Vector3.new(.25, .06, .06), ink)
	local bubble = Instance.new("BillboardGui")
	bubble.Name, bubble.Size, bubble.StudsOffset = "Reaction22", UDim2.fromOffset(220, 64), Vector3.new(0, 1.65, 0)
	bubble.MaxDistance, bubble.AlwaysOnTop, bubble.Enabled = 50, false, false
	bubble.Parent = parts.Head
	local label = Instance.new("TextLabel")
	label.Name, label.Size = "Dialogue", UDim2.fromScale(1, 1)
	label.BackgroundColor3, label.BackgroundTransparency = Theme.Cream, .03
	label.TextColor3, label.Font, label.TextSize = Theme.Ink, Enum.Font.GothamMedium, 12
	label.TextWrapped, label.BorderSizePixel = true, 0
	label.Parent = bubble
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 8), UDim.new(0, 8)
	padding.Parent = label
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = label
	model.Parent = folder
	customers[id] = {model = model, parts = parts, bubble = bubble, label = label, untilTime = 0, nextGround = 0}
end
for index = 1, 5 do create(string.format("Rumah%02d", index), index) end

local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances = {map, workspace.Terrain}
ray.IgnoreWater = true
local overlap = OverlapParams.new()
overlap.FilterType = Enum.RaycastFilterType.Include
overlap.FilterDescendantsInstances = {map}
local function ground(point)
	for _, offset in {
		Vector3.new(4.8, 0, 0), Vector3.new(-4.8, 0, 0),
		Vector3.new(4.8, 0, 2.5), Vector3.new(-4.8, 0, 2.5),
		Vector3.new(3.8, 0, 4), Vector3.new(-3.8, 0, 4),
	} do
		local at = point.CFrame:PointToWorldSpace(offset)
		local hit = workspace:Raycast(at + Vector3.new(0, 4, 0), Vector3.new(0, -15, 0), ray)
		if hit and hit.Normal.Y > .9 and math.abs(hit.Position.Y - point.Position.Y) < 1.5 then
			local position = Vector3.new(at.X, hit.Position.Y + .03, at.Z)
			local clear = true
			for _, p in workspace:GetPartBoundsInBox(CFrame.new(position + Vector3.new(0, 2.3, 0)), Vector3.new(2.5, 4.4, 1.5), overlap) do
				if p.CanCollide then clear = false break end
			end
			if clear then return position, hit.Instance:GetFullName() end
		end
	end
end
local shownOrder
table.insert(connections, shared.Remotes.StateChanged.OnClientEvent:Connect(function(state, code)
	local result = state.lastResult
	if code ~= "Delivered" or not result or not result.orderId or result.orderId == shownOrder then return end
	shownOrder = result.orderId
	local customer = customers[result.destinationId]
	if not customer then return end
	local stars = result.rating and result.rating.stars or 1
	local line = stars == 3 and "Rapi dan cepat. Terima kasih!" or stars == 2 and "Paketnya aman. Terima kasih!" or "Terima kasih. Lain kali lebih hati-hati, ya."
	if state.relayOffer then line ..= " Ada titipan lagi." end
	customer.label.Text = Config.Routes[result.destinationId].Name:gsub("^Rumah ", "") .. ":\n" .. line
	customer.untilTime = os.clock() + 12
	customer.model:SetAttribute("DialogueOrderId", result.orderId)
	customer.model:SetAttribute("ReactionStars22", stars)
	customer.model:SetAttribute("ReactionCount22", (customer.model:GetAttribute("ReactionCount22") or 0) + 1)
end))
local elapsed = 0
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < .05 then return end
	elapsed = 0
	local now = os.clock()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local toast = ui:FindFirstChild("DeliveryCelebration")
	local blocked = ui.Shop.Visible or ui:GetAttribute("JobBoardOpen17") or toast and toast.Visible
	for id, c in pairs(customers) do
		local house = map:FindFirstChild(id)
		local point = house and house:FindFirstChild("DestinationPoint")
		if point and (not c.pointFrame or c.pointFrame ~= point.CFrame) then c.base = nil c.nextGround = 0 c.pointFrame = point.CFrame end
		if point and not c.base and now >= c.nextGround then
			c.nextGround = now + 1
			local at, surface = ground(point)
			c.base = at
			c.model:SetAttribute("Grounded22", at ~= nil)
			c.model:SetAttribute("GroundSurface22", surface)
			c.model:SetAttribute("FeetY22", at and at.Y)
		end
		local visible = root and c.base and (root.Position - c.base).Magnitude < 65
		if c.visible ~= (visible == true) then
			c.visible = visible == true
			for _, p in pairs(c.parts) do p.Transparency = c.visible and 0 or 1 end
		end
		local wave = visible and now < c.untilTime
		c.model:SetAttribute("Waving22", wave == true)
		c.bubble.Enabled = wave == true and not blocked and (root.Position - c.base).Magnitude < 40
		if visible then
			local delta = Vector3.new(root.Position.X - c.base.X, 0, root.Position.Z - c.base.Z)
			local direction = delta.Magnitude > .2 and delta.Unit or point.CFrame.LookVector
			local cf = CFrame.lookAt(c.base, c.base + direction)
			local p = c.parts
			p.Torso.CFrame = cf * CFrame.new(0, 2.45, 0)
			p.Head.CFrame = cf * CFrame.new(0, 3.9, 0)
			p.Hair.CFrame = cf * CFrame.new(0, 4.36, 0)
			if p.Bun then
				p.BackHair.CFrame = cf * CFrame.new(0, 3.95, .46)
				p.Bun.CFrame = cf * CFrame.new(0, 4.27, .67)
			end
			p.LeftLeg.CFrame = cf * CFrame.new(-.4, .8, 0)
			p.RightLeg.CFrame = cf * CFrame.new(.4, .8, 0)
			p.LeftArm.CFrame = cf * CFrame.new(-1, 3.15, 0) * CFrame.Angles(0, 0, -.06) * CFrame.new(0, -.8, 0)
			local angle = wave and (2.35 + math.sin(now * 12) * .28) or .06
			p.RightArm.CFrame = cf * CFrame.new(1, 3.15, 0) * CFrame.Angles(0, 0, angle) * CFrame.new(0, -.8, 0)
			p.EyeLeft.CFrame = cf * CFrame.new(-.2, 3.98, -.5)
			p.EyeRight.CFrame = cf * CFrame.new(.2, 3.98, -.5)
			p.Smile.CFrame = cf * CFrame.new(0, 3.68, -.5)
		end
	end
end))
table.insert(connections, script.Destroying:Connect(function()
	for _, connection in ipairs(connections) do connection:Disconnect() end
	folder:Destroy()
end))
task.delay(.9, function() if script.Parent then shared.Remotes.ActionRequest:FireServer("Sync") end end)
