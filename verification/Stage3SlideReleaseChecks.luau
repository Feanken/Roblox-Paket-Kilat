local player=game.Players:GetPlayers()[1]
local D=require(game.ServerScriptService.PaketKilat.DeliveryService)
local E=require(game.ServerScriptService.PaketKilat.EconomyService)
local H=require(game.ServerScriptService.PaketKilat.HazardService)
local C=require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local W=workspace.PaketKilat
local origin=W.Map.DepotPad.Position
local report={trials={},pass=true}
for _,kind in ipairs({"Biasa","Rapuh"}) do
	D.Cancel(player)
	local r=player.Character.HumanoidRootPart
	r.Anchored=true
	player.Character:PivotTo(CFrame.new(W.Map.Depot.PickupPoint.Position+Vector3.new(0,3,4)))
	for i,a in ipairs(C.OrderSchedule) do if a.DestinationId=="Rumah02" and a.PackageType==kind then E.sessions[player.UserId].nextOrderIndex=i break end end
	task.wait(0.3); assert(D.Handle(player,"Start"))
	r.Anchored=false; r:SetNetworkOwnershipAuto()
	player.Character:PivotTo(CFrame.lookAt(origin+Vector3.new(-34,4,0),origin+Vector3.new(-65,4,0)))
	r:SetAttribute("Stage3MoveTarget",origin+Vector3.new(-65,4,0))
	local deadline=os.clock()+6
	repeat task.wait(0.025) until H.effects[player.UserId] or os.clock()>deadline
	assert(H.effects[player.UserId],"Slip missing")
	r:SetAttribute("Stage3MoveTarget",r.Position)
	local start=r.Position
	task.wait(0.3)
	local distance=((r.Position-start)*Vector3.new(1,0,1)).Magnitude
	table.insert(report.trials,{packageType=kind,displacementAfterRelease=distance,pass=distance>1})
	report.pass=report.pass and distance>1
	D.Cancel(player)
	r:SetAttribute("Stage3MoveTarget",nil)
end
local v=Instance.new("StringValue") v.Name,v.Value,v.Parent="Stage3SlideReport",game.HttpService:JSONEncode(report),workspace
print("[PaketKilat SLIDE RELEASE]",v.Value)
