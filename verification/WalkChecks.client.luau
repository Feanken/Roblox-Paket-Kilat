-- LocalScript sementara di PlayerGui saat Play. Hanya setup awal memakai PivotTo;
-- seluruh rute depot-rumah-depot memakai Humanoid:MoveTo, tanpa teleport.
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
repeat task.wait(0.1) until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
task.wait(1)
local char = player.Character
local hum, r = char.Humanoid, char.HumanoidRootPart
local C = require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local y = workspace.PaketKilat.Map.DepotPad.Position.Y
local result = {route = {}, maxCarryError = 0, pass = true}
local sample
local ok, err = pcall(function()
	char:PivotTo(CFrame.new(0, y + 4, 0))
	task.wait(0.5)
	game.ReplicatedStorage.PaketKilat.Remotes.ActionRequest:FireServer("Start")
	task.wait(0.6)
	local package = workspace.PaketKilat.ActivePackages:FindFirstChildWhichIsA("BasePart")
	assert(package and package:GetAttribute("status") == "Carrying", "No carried package")
	sample = RunService.Heartbeat:Connect(function()
		local error = (package.Position - (r.CFrame * C.CarryOffset).Position).Magnitude
		result.maxCarryError = math.max(result.maxCarryError, error)
	end)
	for _,point in ipairs({{0,-20},{0,-40},{100,-40},{100,-20},{94,-12},{92,4},{100,4},{92,4},{94,-12},{100,-20},{100,-40},{0,-40},{0,-20},{0,4}}) do
		local target = Vector3.new(point[1], y + 4, point[2])
		hum:MoveTo(target)
		local deadline = os.clock() + 12
		local reached = false
		repeat
			task.wait(0.05)
			local delta = (r.Position - target) * Vector3.new(1,0,1)
			reached = delta.Magnitude < 1.2
		until reached or os.clock() >= deadline or hum.Health <= 0
		local valid = reached and r.Position.Y > y + 1 and package:GetAttribute("status") == "Carrying"
		table.insert(result.route, {x = point[1], z = point[2], reached = valid, position = tostring(r.Position)})
		if not valid then result.pass = false; break end
	end
	result.condition = package:GetAttribute("condition")
	result.carryStable = result.maxCarryError < 0.5
	result.pass = result.pass and result.carryStable
end)
if sample then sample:Disconnect() end
if not ok then result.pass, result.error = false, tostring(err) end
local value = Instance.new("StringValue")
value.Name, value.Value, value.Parent = "Stage1WalkReport", game.HttpService:JSONEncode(result), player.PlayerGui
print("[PaketKilat WALK]", value.Value)
