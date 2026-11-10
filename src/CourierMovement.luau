local Players=game:GetService("Players") local RunService=game:GetService("RunService")
local T=require(script.Parent.MovementTuning)
local Rest=require(script.Parent.RestStops27)
local M={} local states={} local D,E,remote local started=false
local function get(player)
 local s=states[player]
 if not s then s={stamina=100,grip=100,sprinting=false,wants=false,lease=0,lastIntent=-math.huge,exhausted=false,tuning=T.Get()};states[player]=s end
 return s
end
function M.Snapshot(player)
 local s=get(player)
 return {stamina=math.floor(s.stamina+.5),grip=math.floor(s.grip+.5),sprinting=s.sprinting,resting=s.resting==true,exhausted=s.exhausted,gripLevel=s.gripLevel or 0,gripMultiplier=s.gripMultiplier or 1,available=E~=nil and E.Has(player)}
end
function M.Intent(player,...)
 local wants=...
 if select('#',...)~=1 or type(wants)~="boolean" then return false end
 local s=get(player) local now=os.clock()
 if not wants then s.wants=false s.lease=0 return true end
 if not E.Has(player) or now-s.lastIntent<s.tuning.IntentInterval then return false end
 s.lastIntent=now
 local hum=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not hum or hum.Health<=0 or hum.Sit then return false end
 s.wants=true s.lease=now+s.tuning.IntentLease return true
end
local function tickPlayer(player,dt)
 local s=get(player) local char=player.Character local hum=char and char:FindFirstChildOfClass("Humanoid")
 local root=char and char:FindFirstChild("HumanoidRootPart")
 if not hum or hum.Health<=0 or not root then
  if s.hum and s.hum.Parent then s.hum.WalkSpeed=s.baseSpeed end
  s.wants=false s.sprinting=false s.resting=false s.lease=0 return
 end
 if hum~=s.hum then
  s.hum=hum s.baseSpeed=hum.WalkSpeed s.stamina=100 s.grip=100 s.exhausted=false s.wants=false s.lease=0 s.tuning=T.Get()
  local gear=E.GearQuote(player)s.gripLevel=gear.level s.gripMultiplier=gear.multiplier
 end
 if not E.Has(player) then s.wants=false s.sprinting=false s.resting=false hum.WalkSpeed=s.baseSpeed return end
 local o=D.orders[player.UserId]
 if o and o.orderId~=s.orderId then s.orderId=o.orderId s.grip=100 s.tuning=T.Get()local gear=E.GearQuote(player)s.gripLevel=gear.level s.gripMultiplier=gear.multiplier end
 if s.stamina>=s.tuning.RestartAt then s.exhausted=false end
 s.resting=Rest.IsResting(hum)==true
 if hum.Sit then s.wants=false s.lease=0 end
 local regen=s.resting and s.tuning.RestRegenMultiplier or 1
 local sprint=s.wants and os.clock()<s.lease and not s.exhausted
 local moving=Vector3.new(root.AssemblyLinearVelocity.X,0,root.AssemblyLinearVelocity.Z).Magnitude>2
 if sprint and moving then
  s.stamina=math.max(0,s.stamina-s.tuning.StaminaDrain*dt)
  if s.stamina<=0 then s.exhausted=true sprint=false s.wants=false s.lease=0 end
 else s.stamina=math.min(100,s.stamina+s.tuning.StaminaRegen*regen*dt) end
 if sprint and moving and o and o.status=="Carrying" and not o.outOfBounds then
  local drain=o.packageType=="Rapuh" and s.tuning.FragileGripDrain or s.tuning.GripDrain
  s.grip=math.max(0,s.grip-drain*(s.gripMultiplier or 1)*dt)
  if s.grip<=0 and D.Impact(o,"GripLost")then s.grip=40 sprint=false s.wants=false s.lease=0 end
 else s.grip=math.min(100,s.grip+s.tuning.GripRegen*regen*dt) end
 s.sprinting=sprint hum.WalkSpeed=s.baseSpeed*(sprint and s.tuning.SprintMultiplier or 1)
end
function M.Start(delivery,economy,intent)
 assert(not started,"Movement already started") started=true D,E,remote=delivery,economy,intent T.Start()
 Rest.Start(workspace.PaketKilat,E)
 remote.OnServerEvent:Connect(function(player,...) M.Intent(player,...)end)
 local elapsed=0 local publish=0
 RunService.Heartbeat:Connect(function(dt)
  elapsed+=dt if elapsed<.05 then return end
  local step=math.min(elapsed,.2) elapsed=0 publish+=step
  for _,player in ipairs(Players:GetPlayers())do tickPlayer(player,step)end
  if publish>=.25 then publish=0 for _,player in ipairs(Players:GetPlayers())do if E.Has(player)then D.Publish(player,"Movement")end end end
 end)
 Players.PlayerRemoving:Connect(function(player)states[player]=nil end)
end
return M

