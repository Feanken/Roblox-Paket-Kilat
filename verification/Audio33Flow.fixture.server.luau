-- Normal server-script fixture to use the same service module state as Bootstrap.
local E=require(game.ServerScriptService.PaketKilat.EconomyService)
local D=require(game.ServerScriptService.PaketKilat.DeliveryService)
local p=game.Players:GetPlayers()[1]assert(p and E.Has(p)and p.Character)
assert(game.GameId==0 and E.Snapshot(p).storageMode=="StudioMemory")
local root=p.Character.HumanoidRootPart local old=root.CFrame local b=workspace.PaketKilat.Map.DepotPad.CFrame
root.Anchored=true p.Character:PivotTo(b*CFrame.new(0,4,2))
task.wait(.4)local ok,code=D.Handle(p,"Start",nil,nil,1)assert(ok,code)
local o=D.orders[p.UserId]
p.Character:PivotTo(workspace.PaketKilat.Map.City13.Stations.Pos1.CFrame+Vector3.new(0,3,0))
task.wait(2)
script:SetAttribute("StampCount",D.Snapshot(p).routeBonus.count)
o.startedAt=workspace:GetServerTimeNow()-10
p.Character:PivotTo(workspace.PaketKilat.Map[o.destinationId].DestinationPoint.CFrame+Vector3.new(0,3,0))
o.previousPosition,o.previousVelocity,o.previousSampleAt=nil,nil,nil
task.wait(.4)ok,code=D.Handle(p,"Deliver",o.orderId,o.destinationId,3)assert(ok,code)
task.wait(2)
game.ReplicatedStorage.PaketKilat.Remotes.StateChanged:FireClient(p,D.Snapshot(p),"Delivered")
root.Anchored=false root.CFrame=old script:SetAttribute("Completed",true)
