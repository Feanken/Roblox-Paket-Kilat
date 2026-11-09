local Players=game:GetService("Players")
local player=Players:GetPlayers()[1]
local W=workspace.PaketKilat
local D=require(game.ServerScriptService.PaketKilat.DeliveryService)
local E=require(game.ServerScriptService.PaketKilat.EconomyService)
local scenario=script:GetAttribute("Scenario") or "Eligible"
local r=player.Character:WaitForChild("HumanoidRootPart")
local function call(a,id,dest)
	task.wait(0.3)
	local ok,code=D.Handle(player,a,id,dest)
	if not ok and code=="RateLimited" then task.wait(0.3); ok,code=D.Handle(player,a,id,dest) end
	assert(ok,code)
end
D.Cancel(player)
E.sessions[player.UserId].nextOrderIndex=4
r.Anchored=true
r.CFrame=CFrame.new(W.Map.Depot.PickupPoint.Position+Vector3.new(0,3,4))
call("Start")
local o=D.orders[player.UserId]
local before=E.GetBest(player,o.destinationId,o.packageType)
if scenario=="Recovered" then
	call("Drop",o.orderId)
	call("Recover",o.orderId)
	r.CFrame=o.package.CFrame+Vector3.new(0,1,3)
	call("Pickup",o.orderId)
end
r.CFrame=CFrame.new(W.Map[o.destinationId].DestinationPoint.Position+Vector3.new(0,3,2))
o.startedAt=workspace:GetServerTimeNow()-(scenario=="Recovered" and 5 or 22)
task.wait(0.1)
call("Deliver",o.orderId,o.destinationId)
r.Anchored=false
local result=E.Snapshot(player).lastResult
local report={scenario=scenario,result=result,previous=before}
report.pass=scenario=="Recovered" and (not result.recordEligible and not result.newRecord and result.bestTime==before) or (result.recordEligible and result.bestTime~=nil)
local v=Instance.new("StringValue")
v.Name,v.Value,v.Parent="Stage3Presentation"..scenario,game.HttpService:JSONEncode(report),workspace
