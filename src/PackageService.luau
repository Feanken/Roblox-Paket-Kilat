local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local P = {}
local C, W, D, template
function P.Init(config, world, delivery, packageTemplate)
	C, W, D, template = config, world, delivery, packageTemplate
end
function P.Update(o)
	local p = o.package
	if not p then return end
	for _,key in ipairs({"orderId", "ownerUserId", "packageType", "destinationId", "status", "condition", "outOfBounds"}) do p:SetAttribute(key, o[key]) end
	p.Color = C.PackageTypes[o.packageType].Color:Lerp(Color3.fromRGB(145,90,65),1-o.condition/100)
	p.Label.TextLabel.Text = string.format("%s → %s\n%s · %d/100%s", string.upper(o.packageType), C.Routes[o.destinationId].Name, o.status=="Carrying" and "Dibawa" or "Terlepas", o.condition, o.outOfBounds and " · Pulihkan!" or "")
	p.PickupPrompt.Enabled = false -- HUD menangani ambil ulang pada komputer/sentuh.
end
function P.Create(o)
	local p = template:Clone()
	p.Name = o.orderId
	p.CFrame = CFrame.new(W.Map.Depot.PickupPoint.Position + Vector3.new(0, 2, 0))
	p.Parent = W.ActivePackages
	o.package = p
	o.promptConnection = p.PickupPrompt.Triggered:Connect(function(player)
		local ok, code = D.Handle(player, "Pickup", o.orderId)
		if not ok then D.Publish(player, code) end
	end)
end
local function unweld(o)
	if o.weld then o.weld:Destroy(); o.weld = nil end
end
local function resetSample(o)
	o.previousPosition, o.previousVelocity, o.previousSampleAt = nil, nil, nil
end
function P.Carry(o, r)
	unweld(o)
	local p = o.package
	p.Anchored, p.CanCollide, p.Massless = false, false, true
	p.CollisionGroup = "PKCarried"
	p.AssemblyLinearVelocity, p.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	p.CFrame = r.CFrame * C.CarryOffset
	local weld = Instance.new("WeldConstraint")
	weld.Name, weld.Part0, weld.Part1, weld.Parent = "CarryWeld", r, p, p
	o.weld = weld
	resetSample(o)
end
function P.Drop(o, r)
	unweld(o)
	local p = o.package
	p.Anchored, p.Massless, p.CanCollide = false, false, true
	p.CollisionGroup = "PKDropped"
	if r then
		local desired = r.CFrame * C.DropOffset
		-- Jangan menaruh paket di balik dinding ketika dilepas.
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {o.player.Character, W.ActivePackages}
		local hit = workspace:Raycast(r.Position, desired.Position - r.Position, params)
		p.CFrame = hit and CFrame.new(hit.Position - (desired.Position - r.Position).Unit * 2) or desired
	end
	p.AssemblyLinearVelocity, p.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	p:SetNetworkOwner(nil)
	resetSample(o)
end
function P.Hold(o)
	unweld(o)
	o.package.AssemblyLinearVelocity, o.package.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
	o.package.Anchored = true
	resetSample(o)
end
function P.Recover(o)
	P.Drop(o, nil)
	o.package.CFrame = CFrame.new(W.Map.RecoveryPoint.Position + Vector3.new(0, C.PackageSize.Y / 2 + 0.4, 0))
	resetSample(o)
end
function P.Destroy(o)
	if o.promptConnection then o.promptConnection:Disconnect() end
	unweld(o)
	if o.package then o.package:Destroy() end
end
function P.Start()
	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < C.PhysicsSampleInterval then return end
		elapsed = 0
		local excluded = {W.ActivePackages}
		for _,player in ipairs(Players:GetPlayers()) do if player.Character then table.insert(excluded, player.Character) end end
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = excluded
		params.RespectCanCollide = true
		for _,o in pairs(D.orders) do
			local p = o.package
			if not p or not p.Parent or o.outOfBounds then continue end
			local pos = p.Position - W.Map.DepotPad.Position
			local lo, hi = C.BoundsMin, C.BoundsMax
			if pos.X < lo.X or pos.Y < lo.Y or pos.Z < lo.Z or pos.X > hi.X or pos.Y > hi.Y or pos.Z > hi.Z then
				D.OutOfBounds(o)
				continue
			end
			local subject, radius = p, p.Size.Y / 2
			if o.status == "Carrying" then
				local char = o.player.Character
				subject = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if subject and hum then radius = hum.HipHeight + subject.Size.Y / 2 end
			end
			if not subject then continue end
			local current, velocity = subject.Position, subject.AssemblyLinearVelocity
			local sampleTime = os.clock()
			if o.previousPosition and o.previousVelocity then
				local previous = o.previousVelocity
				local delta = current - o.previousPosition
				local inferred = delta / math.max(sampleTime - (o.previousSampleAt or sampleTime), C.PhysicsSampleInterval)
				if (o.status == "Carrying" and inferred.Y < previous.Y) or (o.status == "Dropped" and inferred.Magnitude > previous.Magnitude) then previous = inferred end
				local speed = o.status == "Carrying" and math.max(0, -previous.Y) or previous.Magnitude
				if speed >= C.ImpactSpeed then
					local hit = delta.Magnitude > 0.01 and workspace:Raycast(o.previousPosition, delta + delta.Unit * (radius + C.ContactMargin), params)
					local direction = o.status == "Carrying" and Vector3.new(0, -1, 0) or previous.Unit
					hit = hit or workspace:Raycast(current, direction * (radius + C.ContactMargin), params)
					if hit and -previous:Dot(hit.Normal) >= C.ImpactSpeed then
						D.Impact(o)
					end
				end
			end
			o.previousPosition, o.previousVelocity, o.previousSampleAt = current, velocity, sampleTime
		end
	end)
end
return P
