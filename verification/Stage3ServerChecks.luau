-- Script sementara Play. Fixture waktu/posisi hanya ada pada harness server ini.
local folder=game.ServerScriptService.PaketKilat
local D,E,P,H= require(folder.DeliveryService),require(folder.EconomyService),require(folder.PackageService),require(folder.HazardService)
local C=require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local player=game.Players:GetPlayers()[1]
local W=workspace.PaketKilat
local report={checks={},assignments={},mode="Studio Play; one real client; server runtime harness"}
local r
local function check(name,pass,detail) table.insert(report.checks,{name=name,pass=pass==true,detail=tostring(detail or "")}) end
local function waitFor(f,timeout)
	local deadline=os.clock()+timeout
	repeat task.wait(0.05) until f() or os.clock()>deadline
	assert(f(),"Timeout")
end
local function action(a,id,dest)
	task.wait(C.RequestCooldown+0.05)
	local ok,code=D.Handle(player,a,id,dest)
	if code=="RateLimited" then task.wait(C.RequestCooldown+0.05); return D.Handle(player,a,id,dest) end
	return ok,code
end
local function depot()
	r=player.Character.HumanoidRootPart
	r.Anchored=true
	r.CFrame=CFrame.new(W.Map.Depot.PickupPoint.Position+Vector3.new(0,3,4))
end
local ok,err=pcall(function()
	waitFor(function() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end,10)
	task.wait(1)
	D.Cancel(player)
	local base=E.Snapshot(player).coins
	local seen={}
	for index=1,10 do
		depot()
		assert(action("Start"))
		local o=D.orders[player.UserId]
		local expected=C.OrderSchedule[index]
		check("Server assignment "..index,o.destinationId==expected.DestinationId and o.packageType==expected.PackageType)
		seen[o.destinationId.."|"..o.packageType]=true
		table.insert(report.assignments,{destinationId=o.destinationId,packageType=o.packageType})
		check("Package type visible "..index,o.package:GetAttribute("packageType")==o.packageType and string.find(o.package.Label.TextLabel.Text,string.upper(o.packageType),1,true)~=nil)
		local before=o.condition
		local damaged=D.Impact(o)
		local repeated=D.Impact(o)
		check("Type damage and cooldown "..index,damaged and not repeated and o.condition==before-C.PackageTypes[o.packageType].ImpactDamage and o.status=="Dropped")
		assert(action("Pickup",o.orderId))
		local falseDestination=o.destinationId=="Rumah01" and "Rumah02" or "Rumah01"
		local wrong,wrongCode=action("Deliver",o.orderId,falseDestination)
		check("Wrong destination "..index,not wrong and wrongCode=="WrongDestination",wrongCode)
		local far,farCode=action("Deliver",o.orderId,o.destinationId)
		check("Distant request "..index,not far and farCode=="TooFar",farCode)
		o.condition=100
		o.startedAt=workspace:GetServerTimeNow()-C.Routes[o.destinationId].TargetSeconds*0.25
		r.CFrame=CFrame.new(W.Map[o.destinationId].DestinationPoint.Position+Vector3.new(0,3,2))
		task.wait(0.1)
		local part,connection=o.package,o.promptConnection
		local finished,finishedCode=action("Deliver",o.orderId,o.destinationId)
		local result=E.Snapshot(player).lastResult
		local expectedReward=25+15+math.floor(10*math.clamp(1-result.duration/C.Routes[o.destinationId].TargetSeconds,0,1))
		check("Route reward "..index,finished and result.total==expectedReward and result.destinationName==C.Routes[o.destinationId].Name,finishedCode)
		check("First record per pair "..index,result.recordEligible and result.newRecord and result.bestTime==result.duration and result.packageType==o.packageType)
		check("Delivered resources cleared "..index,not D.orders[player.UserId] and part.Parent==nil and not connection.Connected)
		local balance=E.Snapshot(player).coins
		local immediate,immediateCode=D.Handle(player,"Deliver",o.orderId,o.destinationId)
		check("Immediate replay "..index,not immediate and immediateCode=="RateLimited" and E.Snapshot(player).coins==balance)
		local replay,replayCode=action("Deliver",o.orderId,o.destinationId)
		check("Delayed replay "..index,not replay and replayCode=="NotOwnerOrStale" and E.Snapshot(player).coins==balance and E.GetBest(player,o.destinationId,o.packageType)==result.duration)
	end
	local pairCount=0 for _ in pairs(seen) do pairCount+=1 end
	check("All ten pairs covered",pairCount==10)
	local snapshot=E.Snapshot(player)
	local key=next(snapshot.bestTimes)
	local saved=snapshot.bestTimes[key]
	snapshot.bestTimes[key]=-999
	snapshot.lastResult.total=-999
	check("Best and result snapshots detached",E.Snapshot(player).bestTimes[key]==saved and E.Snapshot(player).lastResult.total~=-999)
	local fixture={UserId=player.UserId+200}
	E.Join(fixture)
	local n=0
	local function award(id,kind,duration,recovered,condition)
		n+=1
		local o={orderId="record-fixture-"..n,ownerUserId=fixture.UserId,destinationId=id,packageType=kind,status="Delivered",completionLocked=true,rewardProcessed=false,condition=condition or 100,recoveryCount=recovered or 0,startedAt=100-duration}
		local accepted,result=E.Award(fixture,o,100)
		assert(accepted)
		return result,o
	end
	for id in pairs(C.Routes) do for _,kind in ipairs({"Biasa","Rapuh"}) do
		local a=award(id,kind,20)
		local b=award(id,kind,30)
		local tie=award(id,kind,20)
		local fast=award(id,kind,10)
		local recovered,o=award(id,kind,5,1)
		check("Record eligible/faster/slower/tie/recovery "..id..kind,a.newRecord and not b.newRecord and not tie.newRecord and fast.newRecord and fast.previousBest==20 and recovered.recordEligible==false and recovered.recordReason=="Recovered" and not recovered.newRecord and recovered.bestTime==10 and E.GetBest(fixture,id,kind)==10)
		local money=E.Snapshot(fixture).coins
		local twice=E.Award(fixture,o,100)
		check("Credit ledger "..id..kind,not twice and E.Snapshot(fixture).coins==money)
		local zero=award(id,kind,C.Routes[id].TargetSeconds+1,0,0)
		check("Zero condition base reward "..id..kind,zero.total==25 and zero.recordEligible)
	end end
	E.Leave(fixture)
	check("Session records discarded on leave",E.sessions[fixture.UserId]==nil)
	local fixture2={UserId=player.UserId+201}
	E.Join(fixture2)
	local recoveredOrder={orderId="only-recovered",ownerUserId=fixture2.UserId,destinationId="Rumah01",packageType="Rapuh",status="Delivered",completionLocked=true,rewardProcessed=false,condition=80,recoveryCount=1,startedAt=90}
	local accepted,recoveredResult=E.Award(fixture2,recoveredOrder,100)
	check("Recovery cannot create first record",accepted and recoveredResult.bestTime==nil and E.GetBest(fixture2,"Rumah01","Rapuh")==nil)
	E.Leave(fixture2)
	depot(); assert(action("Start"))
	local o=D.orders[player.UserId]
	local balance=E.Snapshot(player).coins
	local records=E.Snapshot(player).bestTimes
	local oldChar=player.Character
	r.Anchored=false
	player:LoadCharacterAsync()
	waitFor(function() return player.Character and player.Character~=oldChar and player.Character:FindFirstChild("HumanoidRootPart") end,15)
	task.wait(0.8)
	local kept=true for k,v in pairs(records) do if E.Snapshot(player).bestTimes[k]~=v then kept=false end end
	check("Respawn keeps session coins and records",kept and E.Snapshot(player).coins==balance and D.orders[player.UserId]==nil and not H.effects[player.UserId])
	depot()
	local bad,badCode=action("Start",nil,"Rumah05")
	check("Client cannot select destination",not bad and badCode=="InvalidArguments")
	local fakeImpact,impactCode=action("Impact")
	check("Client cannot report damage",not fakeImpact and impactCode=="UnknownAction")
	assert(action("Start"))
	check("New order after respawn",D.orders[player.UserId]~=nil)
	D.Cancel(player)
	report.finalCoins=E.Snapshot(player).coins
end)
if r and r.Parent then r.Anchored=false end
if not ok then report.error=tostring(err) end
report.pass=ok
for _,c in ipairs(report.checks) do if not c.pass then report.pass=false end end
local value=Instance.new("StringValue") value.Name,value.Value,value.Parent="Stage3ServerReport",game.HttpService:JSONEncode(report),workspace
print("[PaketKilat STAGE3 SERVER]",value.Value)
