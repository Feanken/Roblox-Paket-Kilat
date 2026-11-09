-- Jalankan sebagai Script sementara di ServerScriptService SAAT Play; jangan ikut place final.
local Http = game:GetService("HttpService")
local D = require(game.ServerScriptService.PaketKilat.DeliveryService)
local C = require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local player = game.Players:GetPlayers()[1]
repeat task.wait(0.1) until player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0
task.wait(1)
local r = player.Character:WaitForChild("HumanoidRootPart")
local baseY = workspace.PaketKilat.Map.DepotPad.Position.Y
local function cf(x, y, z) return CFrame.new(x, baseY + y, z) end
local report = {checks = {}, mode = "Studio Play / server Script / one real client"}
local function check(name, condition, detail)
	table.insert(report.checks, {name = name, pass = condition == true, detail = tostring(detail or "")})
end
local function action(name, id)
	task.wait(C.RequestCooldown + 0.05)
	return D.Handle(player, name, id)
end
local ok, err = pcall(function()
	D.Cancel(player)
	r.Anchored = true
	r.CFrame = cf(0, 5, -1)
	local success, code = action("Start")
	check("Start at depot", success, code)
	local o = D.orders[player.UserId]
	local id, started = o.orderId, o.startedAt
	check("Authoritative data", o.ownerUserId == player.UserId and o.destinationId == "Rumah01" and o.condition == 100 and not o.rewardProcessed and not o.completionLocked)
	check("Carried visible weld", o.package.Parent == workspace.PaketKilat.ActivePackages and o.weld.Part0 == r and not o.package.CanCollide)
	local second, reason = action("Start")
	check("Second order denied", not second and reason == "OrderActive" and #workspace.PaketKilat.ActivePackages:GetChildren() == 1, reason)
	local wrong, why = D.ValidateCompletion(player, id, "RumahPalsu")
	check("Wrong destination denied", not wrong and why == "WrongDestination", why)
	local far, farReason = D.ValidateCompletion(player, id, "Rumah01")
	check("Distant completion denied", not far and farReason == "TooFar", farReason)
	local snapshot = D.Snapshot(player)
	snapshot.condition = -999
	check("Snapshot detached from state", o.condition == 100)
	local bad, badCode = action({}, id)
	check("Malformed argument denied", not bad and badCode == "InvalidArguments", badCode)
	local unknown, unknownCode = action("Deliver", id)
	check("No T07 action exposed", not unknown and unknownCode == "UnknownAction", unknownCode)
	local stale, staleCode = action("Drop", "stale")
	check("Stale ID denied", not stale and staleCode == "NotOwnerOrStale", staleCode)
	local dropped = action("Drop", id)
	check("Drop physical server owner", dropped and o.status == "Dropped" and not o.weld and o.package.CanCollide and o.package:GetNetworkOwner() == nil)
	-- Simulasi identitas asing pada batas service; bukan bukti dua klien nyata.
	local foreign = {UserId = player.UserId + 1, Character = player.Character}
	local taken, takeCode = D.Handle(foreign, "Pickup", id)
	check("Foreign identity denied pickup", not taken and takeCode == "NotOwnerOrStale", takeCode)
	D.requests[foreign.UserId] = nil
	r.CFrame = cf(100, 5, 4)
	local pickupFar, pickupReason = action("Pickup", id)
	check("Distant pickup denied", not pickupFar and pickupReason == "TooFar", pickupReason)
	r.CFrame = o.package.CFrame + Vector3.new(0, 1, 3)
	local pickup = action("Pickup", id)
	check("Owner repickup", pickup and o.status == "Carrying" and o.weld ~= nil)
	task.wait(C.DamageCooldown + 0.1)
	local before = o.condition
	local impact1, impact2 = D.Impact(o), D.Impact(o)
	check("Damage debounce", impact1 and not impact2 and o.condition == before - C.ImpactDamage and o.status == "Dropped")
	-- Runtime contact detection is tested separately with real falling physics.
	local recover, recoveryCode = action("Recover", id)
	check("Recovery identity and penalty", recover and o.orderId == id and o.startedAt == started and o.condition == before - C.ImpactDamage - C.RecoveryPenalty and o.recoveryCount == 1 and o.status == "Dropped", recoveryCode)
	check("Recovery safe position", (o.package.Position - workspace.PaketKilat.Map.RecoveryPoint.Position).Magnitude < 3)
	local condition = o.condition
	local spam, spamCode = D.Handle(player, "Recover", id)
	check("Request spam denied", not spam and spamCode == "RateLimited", spamCode)
	local cool, coolCode = action("Recover", id)
	check("Recovery cooldown denied", not cool and coolCode == "RecoveryCooldown" and o.condition == condition and o.recoveryCount == 1, coolCode)
	r.CFrame = cf(100, 5, 4)
	local picked, pickReason = action("Pickup", id)
	check("Recovered package still distance checked", not picked and pickReason == "TooFar", pickReason)
	o.package.CFrame = cf(50, -19, 10)
	r.CFrame = cf(50, -19, 10)
	task.wait(0.2)
	check("World boundary holds lost package", o.outOfBounds and o.package.Anchored and o.package.Parent ~= nil)
	task.wait(C.RecoveryCooldown)
	local recovered = action("Recover", id)
	check("Out of bounds recovery", recovered and not o.outOfBounds and not o.package.Anchored and o.orderId == id and o.startedAt == started)
	check("Fallen player returned to safe depot", r.Position.Y > baseY and (r.Position - workspace.PaketKilat.Map.PrototypeSpawn.Position).Magnitude < 6)
	for _ = 1, 12 do o.lastDamageAt = -math.huge; D.Impact(o) end
	check("Condition clamps zero", o.condition == 0)
	r.CFrame = o.package.CFrame + Vector3.new(0, 1, 3)
	local zeroPickup = action("Pickup", id)
	check("Zero condition repickup", zeroPickup and o.status == "Carrying" and o.condition == 0)
	r.CFrame = cf(100, 5, 3)
	local locked = D.LockCompletion(player, id, "Rumah01")
	local relock, lockReason = D.LockCompletion(player, id, "Rumah01")
	check("Internal completion lock once without reward", locked and not relock and lockReason == "CompletionLocked" and not o.rewardProcessed, lockReason)
	D.Cancel(player)
	check("Basic cancellation clears package", D.Snapshot(player).status == "Idle" and #workspace.PaketKilat.ActivePackages:GetChildren() == 0)
	local distant, distantCode = action("Start")
	check("Distant start denied", not distant and distantCode == "TooFar", distantCode)
	r.CFrame = cf(0, 5, -1)
end)
r.Anchored = false
if not ok then report.error = tostring(err) end
report.pass = ok
for _,result in ipairs(report.checks) do if not result.pass then report.pass = false end end
local value = Instance.new("StringValue")
value.Name, value.Value, value.Parent = "Stage1ServerReport", Http:JSONEncode(report), workspace
print("[PaketKilat TEST]", value.Value)
