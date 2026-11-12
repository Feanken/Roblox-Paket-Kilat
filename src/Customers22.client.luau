-- Local, non-colliding customers. Parcel receipt follows a new server result only.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local shared = game.ReplicatedStorage:WaitForChild("PaketKilat")
local Config = require(shared.Shared.Config)
local Theme = require(shared.Shared.UITheme12)
local Dialogue=require(shared.Shared:WaitForChild('CustomerDialogue30'))
local Story = require(shared.Shared:WaitForChild('CourierStory'))
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
	piece("Torso", Vector3.new(1.5, 1.7, .8), palette[(index - 1) % #palette + 1])
	piece("Head", Vector3.new(1.12, 1.12, 1.06), skin, Enum.PartType.Ball)
	for _, side in {"Left", "Right"} do
		piece(side .. "Arm", Vector3.new(.45, 1.6, .55), skin)
		piece(side .. "Leg", Vector3.new(.58, 1.6, .65), ink)
	end
	piece("Hair", Vector3.new(1.18, .28, 1.1), Color3.fromRGB(68, 49, 39))
 if Config.Routes[id].DepotJobOnly then
  piece("Badge", Vector3.new(.28, .38, .06), Color3.fromRGB(247, 224, 168))
 end
	if index % 2 == 1 then
		piece("BackHair", Vector3.new(1.12, .85, .3), Color3.fromRGB(68, 49, 39))
		piece("Bun", Vector3.new(.55, .55, .55), Color3.fromRGB(68, 49, 39), Enum.PartType.Ball)
	end
	piece("EyeLeft", Vector3.new(.1, .1, .06), ink)
	piece("EyeRight", Vector3.new(.1, .1, .06), ink)
	piece("Smile", Vector3.new(.25, .06, .06), ink)
	piece('Parcel30',Vector3.new(1.3,.85,.85),Color3.fromRGB(201,160,96))
	piece('ParcelTape30',Vector3.new(.17,.87,.87),Color3.fromRGB(245,219,162))
	local bubble = Instance.new("BillboardGui")
	bubble.Name, bubble.Size, bubble.StudsOffset = "Reaction22", UDim2.fromOffset(220, 64), Vector3.new(0, 1.65, 0)
	bubble.MaxDistance, bubble.AlwaysOnTop, bubble.Enabled = 50, true, false
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
	customers[id] = {model = model, parts = parts, bubble = bubble, label = label, untilTime = 0, greetingUntil=0, nextGround = 0}
end
for index = 1, 5 do create(string.format("Rumah%02d", index), index) end
local districtAddresses = {}
for id, route in pairs(Config.Routes) do
 if route.DepotJobOnly then table.insert(districtAddresses, id) end
end
table.sort(districtAddresses)
for index, id in ipairs(districtAddresses) do create(id, index + 5) end

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
   local stations = map:FindFirstChild("CourierStations46")
   if stations then
    for _, station in ipairs(stations:GetChildren()) do
     local base = station:FindFirstChild("Base")
     local delta = base and position - base.Position
     if delta and Vector2.new(delta.X, delta.Z).Magnitude < 2.4 then clear = false break end
    end
   end
			for _, p in workspace:GetPartBoundsInBox(CFrame.new(position + Vector3.new(0, 2.3, 0)), Vector3.new(2.5, 4.4, 1.5), overlap) do
				if p.CanCollide then clear = false break end
			end
			if clear then return position, hit.Instance:GetFullName() end
		end
	end
end
local state={}local seenOrders={}local orderQueue={}
local function blockedUI()
 local toast=ui:FindFirstChild('DeliveryCelebration')
 local gallery=ui:FindFirstChild("GalleryReader")
 return ui.Shop.Visible or ui:GetAttribute("JobBoardOpen17") or ui:GetAttribute("MobileMenuOpen18")
  or ui:GetAttribute("MobileTargetOpen18") or ui:GetAttribute("AudioOpen33") or ui:GetAttribute("OrderOptionsOpen")
  or (gallery and gallery.Visible) or (toast and toast.Visible)
end
local function say(c,id,line)
 local contact = Story.Contact(id)
 local name = contact and contact.name or Config.Routes[id].Name:gsub("^Rumah ", "")
 c.label.Text = name .. "\n" .. line
end
table.insert(connections, shared.Remotes.StateChanged.OnClientEvent:Connect(function(snapshot, code)
	state=snapshot
	local result = state.lastResult
	if code ~= "Delivered" or not result or not result.orderId or seenOrders[result.orderId] then return end
	local customer = customers[result.destinationId]
	if not customer then return end
	seenOrders[result.orderId]=true table.insert(orderQueue,result.orderId)
	if #orderQueue>20 then seenOrders[table.remove(orderQueue,1)]=nil end
	local stars = result.rating and result.rating.stars or 1
	local count=(customer.model:GetAttribute('ReactionCount22')or 0)+1
	customer.pending={orderId=result.orderId,line=Dialogue.Reaction(result,state.relayOffer~=nil,count),expires=os.clock()+12}
	customer.greetingUntil=0 customer.untilTime=0
	customer.model:SetAttribute('PendingReceipt30',true)
	customer.model:SetAttribute("DialogueOrderId", result.orderId)
	customer.model:SetAttribute("ReactionStars22", stars)
	customer.model:SetAttribute("ReactionCount22", count)
end))
local elapsed = 0
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
	elapsed += dt
	if elapsed < .05 then return end
	elapsed = 0
	local now = os.clock()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local blocked = blockedUI()
	local mobile=Theme.IsMobile(ui)
	local snapshot=state
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
		local body=house and house:FindFirstChild('Body')local door=house and house:FindFirstChild('Door')
		local outward=body and door and Vector3.new(door.Position.X-body.Position.X,0,door.Position.Z-body.Position.Z)
		local idleDirection=outward and outward.Magnitude>.1 and outward.Unit or Config.Routes[id].DepotJobOnly and map.DepotPad.CFrame.LookVector or point and point.CFrame.LookVector
		local visible = root and point and c.base and (root.Position - c.base).Magnitude < 65
		if c.visible ~= (visible == true) then
			c.visible = visible == true
			for _, p in pairs(c.parts) do p.Transparency = c.visible and 0 or 1 end
		end
		local awaiting=snapshot.profileReady and snapshot.status=='Carrying'and snapshot.destinationId==id
		if not snapshot.profileReady then c.pending=nil c.untilTime=0 c.greetingUntil=0 end
		if c.pending and now>=c.pending.expires then c.pending=nil end
		if c.pending and visible and not blocked and(root.Position-c.base).Magnitude<40 then
			say(c,id,c.pending.line)c.model:SetAttribute('ReceiptOrder30',c.pending.orderId)
			c.model:SetAttribute('ReceiptCount30',(c.model:GetAttribute('ReceiptCount30')or 0)+1)
			c.pending=nil c.receiptStarted=now c.untilTime=now+8
		end
		c.model:SetAttribute('PendingReceipt30',c.pending~=nil)
		if awaiting and visible and not blocked and now>=c.untilTime and(root.Position-c.base).Magnitude<=Config.ActionDistance*2 and c.greetedOrder~=snapshot.orderId then
			c.greetedOrder=snapshot.orderId c.greetingUntil=now+4 say(c,id,Dialogue.Greeting(id,snapshot))
			c.model:SetAttribute('GreetingCount30',(c.model:GetAttribute('GreetingCount30')or 0)+1)
		end
		local holding=visible and now<c.untilTime and now<(c.receiptStarted or 0)+3
		local wave = visible and not holding and(now<c.untilTime or awaiting and now<c.greetingUntil)
		c.model:SetAttribute('HoldingParcel30',holding==true)
		c.model:SetAttribute("Waving22", wave == true)
		c.bubble.Size=mobile and UDim2.fromOffset(200,56)or UDim2.fromOffset(220,64)
		c.label.TextSize=mobile and 11 or 12
		local showBubble=visible==true and(now<c.untilTime or awaiting and now<c.greetingUntil)and not blocked and(root.Position-c.base).Magnitude<40
  if showBubble then
   local camera=workspace.CurrentCamera local delta=camera and(c.parts.Head.Position-camera.CFrame.Position)
   showBubble=delta~=nil and delta.Magnitude<=c.bubble.MaxDistance
   if showBubble then local obstruction=workspace:Raycast(camera.CFrame.Position,delta,ray)showBubble=not obstruction or obstruction.Distance>=delta.Magnitude-.1 end
  end
  c.bubble.Enabled=showBubble==true
		c.parts.Parcel30.Transparency=holding and 0 or 1 c.parts.ParcelTape30.Transparency=holding and 0 or 1
		if visible then
			local delta = Vector3.new(root.Position.X - c.base.X, 0, root.Position.Z - c.base.Z)
			local facing=awaiting or now<c.untilTime
			local direction = facing and delta.Magnitude > .2 and delta.Unit or idleDirection
			local cf = CFrame.lookAt(c.base, c.base + direction)
			local p = c.parts
			p.Torso.CFrame = cf * CFrame.new(0, 2.45, 0)
   if p.Badge then p.Badge.CFrame = cf * CFrame.new(-.4, 2.7, -.44) end
			p.Head.CFrame = cf * CFrame.new(0, 3.9, 0)
			p.Hair.CFrame = cf * CFrame.new(0, 4.36, 0)
			if p.Bun then
				p.BackHair.CFrame = cf * CFrame.new(0, 3.95, .46)
				p.Bun.CFrame = cf * CFrame.new(0, 4.27, .67)
			end
			p.LeftLeg.CFrame = cf * CFrame.new(-.4, .8, 0)
			p.RightLeg.CFrame = cf * CFrame.new(.4, .8, 0)
			p.LeftArm.CFrame = cf * CFrame.new(holding and -.85 or -1, 3.15, 0) * CFrame.Angles(holding and 1.1 or 0, 0, -.06) * CFrame.new(0, -.8, 0)
			local angle = wave and (2.35 + math.sin(now * 12) * .28) or .06
			p.RightArm.CFrame = cf * CFrame.new(holding and .85 or 1, 3.15, 0) * CFrame.Angles(holding and 1.1 or 0, 0, angle) * CFrame.new(0, -.8, 0)
			local received=cf*CFrame.new(0,2.65,-1.05)
			p.Parcel30.CFrame=received p.ParcelTape30.CFrame=received
			p.EyeLeft.CFrame = cf * CFrame.new(-.2, 3.98, -.5)
			p.EyeRight.CFrame = cf * CFrame.new(.2, 3.98, -.5)
			p.Smile.CFrame = cf * CFrame.new(0, 3.68, -.5)
		end
	end
end))

table.insert(connections,player.CharacterAdded:Connect(function()
 for _,c in pairs(customers)do c.pending=nil c.untilTime=0 c.greetingUntil=0 c.greetedOrder=nil end
end))
table.insert(connections, script.Destroying:Connect(function()
	for _, connection in ipairs(connections) do connection:Disconnect() end
	folder:Destroy()
end))
task.delay(.9, function() if script.Parent then shared.Remotes.ActionRequest:FireServer("Sync") end end)
