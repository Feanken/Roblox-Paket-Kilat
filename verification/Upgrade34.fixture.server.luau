local E=require(game.ServerScriptService.PaketKilat.EconomyService)
local K=require(game.ServerScriptService.PaketKilat.CosmeticService)
local D=require(game.ServerScriptService.PaketKilat.DeliveryService)
local B=require(game.ServerScriptService.PaketKilat.CityBonus13)
local C=require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local p=game.Players:GetPlayers()[1]assert(p and E.Has(p)and p.Character)
assert(game.GameId==0 and E.Snapshot(p).storageMode=="StudioMemory")
local profile=E.sessions[p.UserId].profile
local saved={coins=profile.coins,id=profile.equippedCosmetic,level=profile.upgrades.Grip,owned=table.clone(profile.ownedCosmetics)}
for _,id in C.CosmeticOrder do profile.ownedCosmetics[id]=true end
local function gear(id,level)
 profile.equippedCosmetic=id profile.upgrades.Grip=level K.Apply(p)D.Publish(p,"Sync")
 local groups=0 local parts=0 local bad={}
 for _,name in {"PaketKilatBag","PaketKilatGloveLeft","PaketKilatGloveRight"}do
  local model=p.Character:FindFirstChild(name)
  if model then groups+=1 for _,v in model:GetDescendants()do if v:IsA("BasePart")then
   parts+=1 local weld=v:FindFirstChildWhichIsA("WeldConstraint")
   if v.Anchored or not v.Massless or v.CanCollide or v.CanTouch or v.CanQuery or not weld or not weld.Part0 or weld.Part1~=v then table.insert(bad,v.Name)end
  end end end
 end
 return {id=id,level=level,models=groups,parts=parts,bad=bad}
end
local report={}
for _,id in C.CosmeticOrder do for level=0,3 do table.insert(report,gear(id,level))end end
local f=Instance.new("BindableFunction")f.Name="TemporaryUpgrade34Harness"f.Parent=game.ServerStorage
f.OnInvoke=function(action,a,b)
 if action=="gear"then return game.HttpService:JSONEncode(gear(a,b))
 elseif action=="restore"then profile.coins=saved.coins profile.equippedCosmetic=saved.id profile.upgrades.Grip=saved.level profile.ownedCosmetics=saved.owned K.Apply(p)D.Publish(p,"Sync")return true
 elseif action=="start"then
  local root=p.Character.HumanoidRootPart;root.Anchored=true
  p.Character:PivotTo(workspace.PaketKilat.Map.DepotPad.CFrame*CFrame.new(0,4,2))
  local ok,code=D.Handle(p,"Start",nil,nil,1)assert(ok,code)return true
 elseif action=="stamp"then
  p.Character:PivotTo(workspace.PaketKilat.Map.City13.Stations.Pos3.CFrame+Vector3.new(0,3,0))return true
 elseif action=="deliver"then
  local o=D.orders[p.UserId]assert(o)
  o.condition=a or 100 o.startedAt=workspace:GetServerTimeNow()-10
  p.Character:PivotTo(workspace.PaketKilat.Map[o.destinationId].DestinationPoint.CFrame+Vector3.new(0,3,0))
  o.previousPosition,o.previousVelocity,o.previousSampleAt=nil,nil,nil
  task.wait(.35)
  local ok,code=D.Handle(p,"Deliver",o.orderId,o.destinationId,3)assert(ok,code)
  return game.HttpService:JSONEncode(D.Snapshot(p))
 elseif action=="snapshot"then return game.HttpService:JSONEncode(D.Snapshot(p))
 elseif action=="replay"then game.ReplicatedStorage.PaketKilat.Remotes.StateChanged:FireClient(p,D.Snapshot(p),"Delivered")return true
 end
end
script:SetAttribute("GearReport",game.HttpService:JSONEncode(report))
local nav=B.Navigation(workspace.PaketKilat)
script:SetAttribute("Navigation",game.HttpService:JSONEncode({paths=#nav.paths,stations=#nav.stations,points=nav.paths[1]}))
gear("TasHijau",3)
