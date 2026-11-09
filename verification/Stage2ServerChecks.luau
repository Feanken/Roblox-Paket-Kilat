-- Script sementara di ServerScriptService saat Play; tidak ikut place tersimpan.
local D = require(game.ServerScriptService.PaketKilat.DeliveryService)
local E = require(game.ServerScriptService.PaketKilat.EconomyService)
local P = require(game.ServerScriptService.PaketKilat.PackageService)
local L = require(game.ServerScriptService.PaketKilat.PlayerLifecycle)
local C = require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local player = game.Players:GetPlayers()[1]
local W = workspace.PaketKilat
local report = {checks = {}, mode = "Studio Play; one real desktop client; server harness"}
local r
local function check(name, pass, detail)
	table.insert(report.checks,{name=name,pass=pass==true,detail=tostring(detail or "")})
end
local function waitFor(predicate, timeout)
	local deadline=os.clock()+timeout
	repeat task.wait(0.05) until predicate() or os.clock()>=deadline
	assert(predicate(),"Timeout")
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
local function destination()
	r.CFrame=CFrame.new(W.Map.Rumah01.DestinationPoint.Position+Vector3.new(0,3,2))
	task.wait(0.1)
end
local ok,err=pcall(function()
	waitFor(function() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end,10)
	task.wait(1)
	D.Cancel(player)
	depot()
	local baseline=E.Snapshot(player).coins
	check("Start valid",action("Start"))
	local o=D.orders[player.UserId]
	local id=o.orderId
	local second,secondCode=action("Start")
	check("Single active order",not second and secondCode=="OrderActive")
	local wrong,wrongCode=action("Deliver",id,"RumahPalsu")
	check("Wrong destination denied",not wrong and wrongCode=="WrongDestination",wrongCode)
	local far,farCode=action("Deliver",id,"Rumah01")
	check("Distant delivery denied",not far and farCode=="TooFar",farCode)
	local malformed,malformedCode=action("Deliver",id,{reward=999999})
	check("Client reward payload denied",not malformed and malformedCode=="InvalidArguments")
	local spam,spamCode=D.Handle(player,{},id)
	check("Malformed requests rate limited",not spam and spamCode=="RateLimited")
	check("Invalid delivery leaves coins untouched",E.Snapshot(player).coins==baseline)
	local foreign={UserId=player.UserId+100,Character=player.Character}
	E.Join(foreign)
	local foreignOk,foreignCode=D.Handle(foreign,"Deliver",id,"Rumah01")
	check("Foreign identity denied",not foreignOk and foreignCode=="NotOwnerOrStale")
	D.RemovePlayer(foreign)
	check("Drop before delivery",action("Drop",id))
	destination()
	local dropped,dropCode=action("Deliver",id,"Rumah01")
	check("Dropped delivery denied",not dropped and dropCode=="InvalidState")
	r.CFrame=o.package.CFrame+Vector3.new(0,1,3)
	check("Repickup before delivery",action("Pickup",id))
	P.Hold(o)
	destination()
	o.package.CFrame=CFrame.new(W.Map.Depot.PickupPoint.Position+Vector3.new(0,3,0))
	local farPackage,farPackageCode=action("Deliver",id,"Rumah01")
	check("Distant package denied even with nearby player",not farPackage and farPackageCode=="TooFar")
	P.Carry(o,r)
	D.Cancel(player)
	local total=baseline
	local previousId
	for index,scenario in ipairs({{condition=100,duration=100,expected=40},{condition=80,duration=44,expected=42},{condition=0,duration=120,expected=25}}) do
		depot()
		assert(action("Start"))
		o=D.orders[player.UserId]
		if previousId then
			local old,oldCode=action("Deliver",previousId,"Rumah01")
			check("Old order replay while new order active "..index,not old and oldCode=="NotOwnerOrStale")
		end
		o.condition=scenario.condition
		o.startedAt=workspace:GetServerTimeNow()-scenario.duration
		local package,connection=o.package,o.promptConnection
		destination()
		local completed,completedCode=action("Deliver",o.orderId,"Rumah01")
		total+=scenario.expected
		local snapshot=D.Snapshot(player)
		check("Formula scenario "..index,completed and snapshot.coins==total and snapshot.lastResult.total==scenario.expected,completedCode)
		check("Delivered then Idle "..index,snapshot.status=="Idle" and D.orders[player.UserId]==nil and o.rewardProcessed and o.completionLocked and o.status=="Delivered")
		check("Completed package resources removed "..index,package.Parent==nil and not connection.Connected and #W.ActivePackages:GetChildren()==0)
		local immediate,immediateCode=D.Handle(player,"Deliver",o.orderId,"Rumah01")
		check("Immediate duplicate no money "..index,not immediate and immediateCode=="RateLimited" and E.Snapshot(player).coins==total)
		local replay,replayCode=action("Deliver",o.orderId,"Rumah01")
		check("Delayed duplicate no money "..index,not replay and replayCode=="NotOwnerOrStale" and E.Snapshot(player).coins==total)
		previousId=o.orderId
	end
	local snap=D.Snapshot(player)
	snap.lastResult.total=-999
	check("Result snapshot is detached",D.Snapshot(player).lastResult.total==25)
	check("Three server deliveries counted",E.Snapshot(player).deliveryCount==3)
	-- Boundary formula without client inputs; a separate server-only session fixture.
	local fixture={UserId=player.UserId+101}
	E.Join(fixture)
	local fixtureOrder={orderId="fixture-zero-time",ownerUserId=fixture.UserId,status="Delivered",completionLocked=true,rewardProcessed=false,destinationId="Rumah01",condition=100,startedAt=10,recoveryCount=0}
	local awarded,result=E.Award(fixture,fixtureOrder,10)
	check("Zero duration formula maximum 50",awarded and result.total==50)
	local twice=E.Award(fixture,fixtureOrder,10)
	check("Economy independently rejects duplicate credit",not twice and E.Snapshot(fixture).coins==50)
	E.Leave(fixture)
	-- Recovery penalty and clock must affect the eventual real reward.
	depot(); assert(action("Start")); o=D.orders[player.UserId]
	assert(action("Drop",o.orderId)); assert(action("Recover",o.orderId))
	check("Recovery penalty before delivery",o.condition==80 and o.recoveryCount==1)
	r.CFrame=o.package.CFrame+Vector3.new(0,1,3)
	assert(action("Pickup",o.orderId))
	o.startedAt=workspace:GetServerTimeNow()-120
	destination(); assert(action("Deliver",o.orderId,"Rumah01"))
	total+=37
	check("Recovered reward uses original elapsed time and condition",E.Snapshot(player).coins==total and E.Snapshot(player).lastResult.total==37 and E.Snapshot(player).lastResult.recoveryCount==1)
	for _,status in ipairs({"Carrying","Dropped"}) do
		depot(); assert(action("Start")); o=D.orders[player.UserId]
		if status=="Dropped" then assert(action("Drop",o.orderId)) end
		local package,connection,oldChar=o.package,o.promptConnection,player.Character
		r.Anchored=false
		if status=="Carrying" then oldChar.Humanoid.Health=0 else player:LoadCharacterAsync() end
		waitFor(function() return player.Character and player.Character~=oldChar and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health>0 end,15)
		task.wait(0.8)
		check("Respawn clears "..status,not D.orders[player.UserId] and package.Parent==nil and not connection.Connected and #W.ActivePackages:GetChildren()==0)
		check("Respawn keeps session balance "..status,E.Snapshot(player).coins==total)
		check("Character bindings do not accumulate "..status,#L.bindings[player].characterConnections==2 and #L.bindings[player].playerConnections==2)
		depot(); assert(action("Start"))
		check("New order after respawn "..status,D.orders[player.UserId].orderId~=o.orderId)
		D.Cancel(player)
	end
	report.finalCoins=total
	depot()
end)
if r and r.Parent then r.Anchored=false end
if not ok then report.error=tostring(err) end
report.pass=ok
for _,c in ipairs(report.checks) do if not c.pass then report.pass=false end end
local value=Instance.new("StringValue")
value.Name,value.Value,value.Parent="Stage2ServerReport",game.HttpService:JSONEncode(report),workspace
print("[PaketKilat STAGE2 SERVER]",value.Value)
