local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage"):WaitForChild("PaketKilat")
local C = require(RS.Shared.Config)
local D = require(script.Parent.DeliveryService)
local P = require(script.Parent.PackageService)
local E = require(script.Parent.EconomyService)
local L = require(script.Parent.PlayerLifecycle)
local H = require(script.Parent.HazardService)
local W = workspace:WaitForChild("PaketKilat")
local T=require(script.Parent:WaitForChild("TelemetryService")).CreateRuntime(require(script.Parent:WaitForChild("TelemetryConfig")))
for _,name in ipairs({"PKCharacters", "PKCarried", "PKDropped"}) do
	if not PhysicsService:IsCollisionGroupRegistered(name) then PhysicsService:RegisterCollisionGroup(name) end
end
for _,pair in ipairs({{"PKCharacters","PKCharacters"},{"PKCharacters","PKDropped"},{"PKCharacters","PKCarried"},{"PKCarried","Default"},{"PKCarried","PKCarried"},{"PKCarried","PKDropped"},{"PKDropped","PKDropped"}}) do
	PhysicsService:CollisionGroupSetCollidable(pair[1], pair[2], false)
end
local DataService=require(script.Parent.DataService)
local Storage=require(script.Parent.StorageConfig)
local K=require(script.Parent.CosmeticService)
local Data=DataService.CreateRuntime(Storage,C,function(uid,status)
 local player=Players:GetPlayerByUserId(uid)
 if player and E.sessions[uid] then
  if status=="Lost" then D.Cancel(player,"ProfileUnavailable") else D.Publish(player,"StorageStatus") end
 end
end)
E.Init(C,Data)
K.Init(C,E)
D.Init(C, P, W, function(player, snapshot, code)
	if player.Parent == Players then RS.Remotes.StateChanged:FireClient(player, snapshot, code) end
end, E, H,K,T)
P.Init(C, W, D, game:GetService("ServerStorage").PaketKilat.PackageTemplate)
H.Init(C, W, D)
H.Start()
P.Start()
RS.Remotes.ActionRequest.OnServerEvent:Connect(function(player, ...)
	local action, orderId, destinationId=...
	local ok, code = D.Handle(player, action, orderId, destinationId,select("#",...))
	if not ok and code ~= "RateLimited" then D.Publish(player, code) end
end)
-- Prompt lama disimpan, tetapi seluruh input sekarang melalui HUD/keyboard.
W.Map.Depot.PickupPoint.StartPrompt.Enabled = false
require(script.Parent.CourierMovement).Start(D,E,RS.Remotes.MovementIntent)
require(script.Parent.CityBonus13).Start(D,E,W)
L.Start(D, E, W, C,Data,K,T)
task.spawn(function() while task.wait(1) do Data:Tick() end end)
game:BindToClose(function() T:Close() end)
game:BindToClose(function()
 local deadline=os.clock()+Storage.CloseTimeout
 for uid in pairs(Data.profiles) do task.spawn(function() Data:Release(uid) end) end
 while next(Data.profiles) and os.clock()<deadline do
  Data:Tick() task.wait(0.25)
 end
 if next(Data.profiles) then warn("[PaketKilat] shutdown: profiles not acknowledged within deadline") end
end)
print("[PaketKilat] Bootstrap ready — T21; onboarding + LocalOnly analytics in Studio")
