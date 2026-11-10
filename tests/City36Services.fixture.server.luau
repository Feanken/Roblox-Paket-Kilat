-- StudioMemory only. Verifies restored shop and widened old-town package bounds; no awards.
local report=game.ServerStorage.TemporaryCity36ServiceResult
local D=require(game.ServerScriptService.PaketKilat.DeliveryService)
local E=require(game.ServerScriptService.PaketKilat.EconomyService)
local p=game.Players:GetPlayers()[1]
local char=p and p.Character local root=char and char:FindFirstChild("HumanoidRootPart")
local originalCF=char and char:GetPivot()local anchored=root and root.Anchored
local ok,value=xpcall(function()
 assert(game.GameId==0 and p and E.Has(p)and root,"Fresh Studio session required")
 local before=E.Snapshot(p)assert(before.storageMode=="StudioMemory","No persistent profile testing")
 assert(not D.orders[p.UserId],"Expected idle")
 root.Anchored=true
 local map=workspace.PaketKilat.Map local b=map.DepotPad.CFrame
 char:PivotTo(map.Depot.ShopPoint.CFrame+Vector3.new(0,3,0))task.wait(.3)
 local equip,code=D.Handle(p,"EquipCosmetic",E.sessions[p.UserId].profile.equippedCosmetic,nil,2)
 assert(equip,code)task.wait(.3)
 char:PivotTo(map.Depot.PickupPoint.CFrame+Vector3.new(0,3,0))task.wait(.3)
 local started,startCode=D.Handle(p,"Start",nil,nil,1)assert(started,startCode)
 local out={shop={ok=equip,code=code},started=started,storage=before.storageMode,bounds={}}
 for _,v in {{-130,4,70},{132,4,70}}do
  local order=D.orders[p.UserId]order.previousPosition,order.previousVelocity,order.previousSampleAt=nil,nil,nil
  char:PivotTo(b*CFrame.new(table.unpack(v)))root.AssemblyLinearVelocity=Vector3.zero task.wait(.65)
  local snap=D.Snapshot(p)table.insert(out.bounds,{x=v[1],status=snap.status,outOfBounds=snap.outOfBounds or false})
  assert(snap.status=="Carrying"and not snap.outOfBounds,"Loop triggers bounds reset")
 end
 D.Cancel(p,"Sync")
 local after=E.Snapshot(p)out.coinsUnchanged=after.coins==before.coins out.finalStatus=D.Snapshot(p).status
 assert(out.coinsUnchanged and out.finalStatus=="Idle","Fixture changed wallet/state")
 return out
end,debug.traceback)
if p and D.orders[p.UserId]then D.Cancel(p,"Sync")end
if char and root then char:PivotTo(originalCF)root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero root.Anchored=anchored end
report.Value=game.HttpService:JSONEncode({ok=ok,result=value})
report:SetAttribute("Ready",true)
