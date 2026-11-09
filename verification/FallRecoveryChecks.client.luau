-- LocalScript sementara Play: jatuh ke bawah arena, pulih, berjalan, ambil ulang.
local player = game.Players.LocalPlayer
local char = player.Character
local r, hum = char.HumanoidRootPart, char.Humanoid
local world = workspace.PaketKilat
local remote = game.ReplicatedStorage.PaketKilat.Remotes.ActionRequest
local y = world.Map.DepotPad.Position.Y
local report = {pass = false}
local function waitFor(predicate, timeout)
	local deadline = os.clock() + timeout
	repeat task.wait(0.05) until predicate() or os.clock() >= deadline
	return predicate()
end
local ok, err = pcall(function()
	char:PivotTo(CFrame.new(0, y + 4, 0))
	task.wait(0.4)
	remote:FireServer("Start")
	assert(waitFor(function() return #world.ActivePackages:GetChildren() == 1 end, 4), "Start did not create package")
	local package = world.ActivePackages:GetChildren()[1]
	local id = package:GetAttribute("orderId")
	report.orderId = id
	char:PivotTo(CFrame.new(50, y + 4, 8)) -- setup jatuh dari samping papan
	assert(waitFor(function() return package:GetAttribute("outOfBounds") == true end, 5), "Boundary not detected")
	report.beforeRecovery = {status = package:GetAttribute("status"), outOfBounds = package:GetAttribute("outOfBounds"), playerY = r.Position.Y}
	task.wait(0.3)
	remote:FireServer("Recover", id)
	assert(waitFor(function() return package:GetAttribute("outOfBounds") == false and r.Position.Y > y end, 5), "Recovery did not return player and package")
	report.afterRecovery = {status = package:GetAttribute("status"), condition = package:GetAttribute("condition"), playerPosition = tostring(r.Position), sameId = package:GetAttribute("orderId") == id}
	local target = world.Map.RecoveryPoint.Position + Vector3.new(0, 3, 3)
	hum:MoveTo(target)
	assert(waitFor(function() return ((r.Position-target)*Vector3.new(1,0,1)).Magnitude < 1.5 end, 6), "Could not walk to recovered package")
	remote:FireServer("Pickup", id)
	assert(waitFor(function() return package:GetAttribute("status") == "Carrying" end, 4), "Repickup failed")
	report.finalStatus = package:GetAttribute("status")
	report.pass = report.afterRecovery.sameId and report.afterRecovery.condition == 80
end)
if not ok then report.error = tostring(err) end
local v = Instance.new("StringValue")
v.Name, v.Value, v.Parent = "Stage1FallRecoveryReport", game.HttpService:JSONEncode(report), player.PlayerGui
print("[PaketKilat FALL RECOVERY]", v.Value)
