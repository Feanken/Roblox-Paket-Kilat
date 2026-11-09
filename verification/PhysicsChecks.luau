-- Script sementara Play: percobaan kontak fisik server, tidak dibundel ke place.
local D = require(game.ServerScriptService.PaketKilat.DeliveryService)
local P = require(game.ServerScriptService.PaketKilat.PackageService)
local C = require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local player = game.Players:GetPlayers()[1]
local r = player.Character.HumanoidRootPart
local pad = workspace.PaketKilat.Map.DepotPad
local y = pad.Position.Y
local results = {threshold = C.ImpactSpeed, trials = {}}
local ok, err = pcall(function()
	D.Cancel(player)
	r.Anchored = true
	r.CFrame = CFrame.new(0, y + 4, 1)
	task.wait(0.3)
	assert(D.Handle(player, "Start"))
	local o = D.orders[player.UserId]
	task.wait(0.3)
	D.Handle(player, "Drop", o.orderId)
	task.wait(1.3)
	for _,height in ipairs({0.1, 1, 2, 6, 12}) do
		P.Hold(o)
		o.condition, o.lastDamageAt, o.outOfBounds = 100, -math.huge, false
		o.package.CFrame = CFrame.new(-8, y + 2 + height, -2)
		o.package.Anchored = false
		o.package:SetNetworkOwner(nil)
		local maxSpeed, beforeCount = 0, 100
		for _ = 1, 70 do
			task.wait(1 / 60)
			maxSpeed = math.max(maxSpeed, o.package.AssemblyLinearVelocity.Magnitude)
		end
		table.insert(results.trials, {height = height, maxSpeed = maxSpeed, condition = o.condition, outOfBounds = o.outOfBounds})
	end
	-- Benturan karakter membawa paket: jatuh vertikal pada platform.
	r.CFrame = o.package.CFrame + Vector3.new(0, 1, 3)
	task.wait(0.3)
	assert(D.Handle(player, "Pickup", o.orderId))
	o.condition, o.lastDamageAt = 100, -math.huge
	r.CFrame = CFrame.new(-6, y + 16, 5)
	r.Anchored = false
	r:SetNetworkOwner(nil)
	r.AssemblyLinearVelocity = Vector3.zero
	local maxFall = 0
	for _ = 1, 100 do task.wait(1 / 60); maxFall = math.max(maxFall, -r.AssemblyLinearVelocity.Y) end
	results.carriedFall = {maxFall = maxFall, status = o.status, condition = o.condition}
	r:SetNetworkOwnershipAuto()
	D.Cancel(player)
	r.CFrame = CFrame.new(0, y + 4, 1)
end)
r.Anchored = false
if not ok then results.error = tostring(err) end
local v = Instance.new("StringValue")
v.Name, v.Value, v.Parent = "Stage1PhysicsReport", game.HttpService:JSONEncode(results), workspace
print("[PaketKilat PHYSICS]", v.Value)
