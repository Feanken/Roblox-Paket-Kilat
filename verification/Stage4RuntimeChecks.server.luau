-- TEMPORARY StudioTestService harness; never shipped in saved place.
local TS=game:GetService("StudioTestService")
local args=TS:GetTestArgs()
if type(args)~="table" or args.tag~="PaketKilatStage4" then return end
local Players=game:GetService("Players")
local Http=game:GetService("HttpService")
local RS=game.ReplicatedStorage.PaketKilat
local M=game.ServerScriptService.PaketKilat
local D=require(M.DeliveryService) local E=require(M.EconomyService)
local DS=require(M.DataService) local L=require(M.PlayerLifecycle)
local C=require(RS.Shared.Config)
local W=workspace.PaketKilat
local report={phase=args.phase,requestedClients=args.clients,actualClients=0,checks={},clientReports={}}
local function check(name,ok,detail)
	table.insert(report.checks,{name=name,passed=not not ok,detail=detail})
	if not ok then error(name.." "..tostring(detail)) end
end
local function waitFor(predicate,seconds)
	local deadline=os.clock()+seconds
	repeat if predicate() then return true end task.wait(0.1) until os.clock()>deadline return false
end
local qa=Instance.new("RemoteEvent") qa.Name="Stage4QA" qa.Parent=RS.Remotes
qa.OnServerEvent:Connect(function(player,kind,value)
	if kind=="Ready" then report.clientReports[tostring(player.UserId)]=value end
	if kind=="WireResult" then report.wireResult=value end
end)
local function act(player,action,id,goal)
	D.requests[player.UserId]=nil
	return D.Handle(player,action,id,goal)
end
local function pivot(player,position)
	local active=D.orders[player.UserId]
	if active then active.previousPosition=nil active.previousVelocity=nil active.previousSampleAt=nil end
	player.Character:PivotTo(CFrame.new(position+Vector3.new(0,3,0)))
	local root=player.Character.HumanoidRootPart root.AssemblyLinearVelocity=Vector3.zero root.AssemblyAngularVelocity=Vector3.zero
end
local function deliver(player)
	pivot(player,W.Map.Depot.PickupPoint.Position)
	check("Start "..player.UserId,act(player,"Start"))
	local o=D.orders[player.UserId]
	local id,goal=o.orderId,o.destinationId
	pivot(player,W.Map[goal].DestinationPoint.Position)
	-- Weld transforms settle in physics before completing.
	task.wait(0.15)
	local before=E.Snapshot(player).coins
	local ok,code=act(player,"Deliver",id,goal)
	check("delivery credited "..player.UserId,ok,code)
	local after=E.Snapshot(player)
	check("reward formula "..player.UserId,after.coins==before+after.lastResult.total and after.lastResult.total>=25 and after.lastResult.total<=50)
	check("delivery replay rejected "..player.UserId,not act(player,"Deliver",id,goal) and E.Snapshot(player).coins==after.coins)
	return after
end
local ok,err=xpcall(function()
	check("all requested players joined",waitFor(function() report.actualClients=math.max(report.actualClients,#Players:GetPlayers()) return #Players:GetPlayers()==args.clients end,90))
	local players=Players:GetPlayers() table.sort(players,function(a,b) return a.UserId<b.UserId end)
	check("all profiles loaded",waitFor(function()
		if not DS.Runtime then return false end
		for _,p in ipairs(players) do if not E.Has(p) or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return false end end return true
	end,45))
	report.storageMode=DS.Runtime.config.Mode
	check("real test datastore backend",report.storageMode=="DataStoreTest")
	report.userIds={} for _,p in ipairs(players) do table.insert(report.userIds,p.UserId) end
	check("all actual client handshakes",waitFor(function() local n=0 for _ in pairs(report.clientReports) do n+=1 end return n==args.clients end,30))
	for _,p in ipairs(players) do
		local client=report.clientReports[tostring(p.UserId)]
		check("private client snapshot "..p.UserId,client and client.profileOwnerUserId==p.UserId and client.uiReady==true)
	end
	local p=players[1]
	if args.phase=="autosave-close" then
		deliver(p)
		local data=DS.Runtime local session=data.profiles[p.UserId]
		check("dirty after delivery",session.dirty)
		check("scheduled autosave acknowledged",waitFor(function() return not session.dirty and not session.saving and data:Info(p.UserId).saveStatus=="Acknowledged" end,40))
		qa:FireClient(p,"WireTest")
		check("actual remote malicious payloads",waitFor(function() return report.wireResult~=nil end,15) and report.wireResult.passed)
		deliver(p)
		check("dirty before BindToClose",session.dirty)
		local s=E.Snapshot(p) report.expected={uid=p.UserId,coins=s.coins,deliveryCount=s.deliveryCount,bestTimes=s.bestTimes,equippedCosmetic=s.equippedCosmetic}
		report.shutdownTest=true -- EndTest invokes production BindToClose, no explicit release here.
		return
	elseif args.phase=="reload" or args.phase=="close-reload" then
		local s=E.Snapshot(p) report.loaded=s
		local expected=args.expected
		check("same player across actual sessions",p.UserId==expected.uid)
		check("cross-session coins",s.coins==expected.coins)
		check("cross-session count",s.deliveryCount==expected.deliveryCount)
		check("cross-session owned and equipped",args.phase=="close-reload" and s.equippedCosmetic==expected.equippedCosmetic or (s.ownedCosmetics.TasMerah and s.equippedCosmetic=="TasMerah"))
		for key,value in pairs(expected.bestTimes) do check("cross-session record "..key,s.bestTimes[key]==value) end
		check("loaded cosmetic visible",p.Character:FindFirstChild("PaketKilatBag")~=nil and p.Character.PaketKilatBag:GetAttribute("CosmeticId")==s.equippedCosmetic)
	else
		local before={}
		for _,player in ipairs(players) do before[player.UserId]=E.Snapshot(player).coins pivot(player,W.Map.Depot.PickupPoint.Position) check("concurrent order "..player.UserId,act(player,"Start")) end
		local ids={}
		for _,player in ipairs(players) do
			local o=D.orders[player.UserId]
			check("unique order id "..player.UserId,not ids[o.orderId]) ids[o.orderId]=true
			check("owner package "..player.UserId,o.package:GetAttribute("ownerUserId")==player.UserId)
		end
		local foreign=players[2]
		if foreign then
			check("foreign package action denied",not act(p,"Drop",D.orders[foreign.UserId].orderId))
			local pa,pb=p.Character.HumanoidRootPart,foreign.Character.HumanoidRootPart
			pivot(foreign,pa.Position) task.wait(0.1)
			check("players do not collide",not game:GetService("PhysicsService"):CollisionGroupsAreCollidable(pa.CollisionGroup,pb.CollisionGroup))
		end
		for _,player in ipairs(players) do
			local o=D.orders[player.UserId]
			pivot(player,W.Map[o.destinationId].DestinationPoint.Position) task.wait(0.1)
			local delivered,dc=act(player,"Deliver",o.orderId,o.destinationId)
			check("isolated completion "..player.UserId,delivered,dc.." status="..o.status.." condition="..o.condition)
			local s=E.Snapshot(player) check("isolated exact balance "..player.UserId,s.coins==before[player.UserId]+s.lastResult.total)
		end
		-- Invalid payloads through actual server dispatcher; force interval only in this harness.
		pivot(p,W.Map.Depot.ShopPoint.Position)
		local balance=E.Snapshot(p).coins
		for i,payload in ipairs({{false},{"NoSuchAction"},{string.rep("x",17)},{"BuyCosmetic",{}},{"BuyCosmetic","TasMerah",{}},{"BuyCosmetic","TasMerah","fake"},{"Sync","extra"}}) do
			local success=act(p,table.unpack(payload)) check("invalid payload rejected "..i,not success and E.Snapshot(p).coins==balance)
		end
		D.requests[p.UserId]=nil local extraOk=D.Handle(p,"BuyCosmetic","TasMerah",nil,4)
		check("extra args rejected",not extraOk and E.Snapshot(p).coins==balance)
		local spoof,code=act(p,"BuyCosmetic","FakeTas") check("unknown catalog rejected",not spoof and code=="UnknownCosmetic")
		if not E.Snapshot(p).ownedCosmetics.TasHijau then local eq,ec=act(p,"EquipCosmetic","TasHijau") check("unowned equip rejected",not eq and ec=="NotOwned") end
		-- A real loaded QA profile, restored immediately after an insufficient balance fixture.
		local profile=DS.Runtime:Get(p.UserId) local savedCoins=profile.coins profile.coins=0
		local buy,bc=act(p,"BuyCosmetic","TasHijau")
		if not profile.ownedCosmetics.TasHijau then check("insufficient coins rejected",not buy and bc=="InsufficientCoins" and profile.coins==0) end
		profile.coins=savedCoins
		pivot(p,W.Map.Rumah05.DestinationPoint.Position)
		check("shop distance enforced",not act(p,"BuyCosmetic","TasMerah") and E.Snapshot(p).coins==savedCoins)
		pivot(p,W.Map.Depot.PickupPoint.Position) check("security start",act(p,"Start"))
		local o=D.orders[p.UserId] local id,goal=o.orderId,o.destinationId
		check("false destination rejected",not act(p,"Deliver",id,"Rumah99"))
		check("far destination rejected",not act(p,"Deliver",id,goal))
		D.requests[p.UserId]=nil local count=0
		for _=1,50 do local _,c=D.Handle(p,"Sync") if c=="RateLimited" then count+=1 end end
		check("spam bounded",count==49 and E.Snapshot(p).coins==savedCoins)
		check("drop",act(p,"Drop",id)) check("recover",act(p,"Recover",id))
		pivot(p,W.Map.RecoveryPoint.Position) check("pickup after recovery",act(p,"Pickup",id))
		D.Cancel(p,"Cancelled")
		for _=1,3 do deliver(p) end
		pivot(p,W.Map.Depot.ShopPoint.Position)
		local old=E.Snapshot(p) local speed=p.Character.Humanoid.WalkSpeed
		local purchased,pc=act(p,"BuyCosmetic","TasMerah")
		check("buy succeeds or already owned",purchased or pc=="AlreadyOwned")
		local expectedCoins=old.coins-(old.ownedCosmetics.TasMerah and 0 or C.Cosmetics.TasMerah.Price)
		check("catalog price exact",E.Snapshot(p).coins==expectedCoins)
		local dup,dc=act(p,"BuyCosmetic","TasMerah")
		check("duplicate purchase no charge",not dup and dc=="AlreadyOwned" and E.Snapshot(p).coins==expectedCoins)
		check("equip owned",act(p,"EquipCosmetic","TasMerah"))
		check("cosmetic no speed advantage",p.Character.Humanoid.WalkSpeed==speed)
		check("cosmetic primitive noncolliding",p.Character.PaketKilatBag:GetAttribute("CosmeticId")=="TasMerah" and not p.Character.PaketKilatBag.CanCollide and p.Character.PaketKilatBag.Massless)
		-- Reset while carrying: live lifecycle must remove order, preserve profile and reapply bag.
		pivot(p,W.Map.Depot.PickupPoint.Position) check("reset order start",act(p,"Start"))
		local oldChar=p.Character local oldOrder=D.orders[p.UserId]
		p:LoadCharacterAsync()
		check("respawn actual character",waitFor(function() return p.Character~=oldChar and p.Character and p.Character:FindFirstChild("PaketKilatBag") end,20))
		check("reset cleans package and order",D.orders[p.UserId]==nil and (not oldOrder.package or oldOrder.package.Parent==nil))
		check("reset retains balance/equipment",E.Snapshot(p).coins==expectedCoins and p.Character.PaketKilatBag:GetAttribute("CosmeticId")=="TasMerah")
		check("one cosmetic after respawn",#p.Character:GetChildren()>0 and (function() local n=0 for _,v in ipairs(p.Character:GetChildren()) do if v.Name=="PaketKilatBag" then n+=1 end end return n==1 end)())
		check("profile save real",DS.Runtime:Save(p.UserId))
		local saved=E.Snapshot(p) report.expected={uid=p.UserId,coins=saved.coins,deliveryCount=saved.deliveryCount,bestTimes=saved.bestTimes}
		if #players>=2 then
			local leaving=players[#players] local uid=leaving.UserId
			pivot(leaving,W.Map.Depot.PickupPoint.Position) check("leaving starts package",act(leaving,"Start"))
			local pack=D.orders[uid].package leaving:Kick("QA leave cleanup")
			check("actual leave removes resources",waitFor(function() return L.bindings[leaving]==nil and E.sessions[uid]==nil and D.orders[uid]==nil and D.requests[uid]==nil and pack.Parent==nil and DS.Runtime.profiles[uid]==nil end,30))
		end
	end
	for _,player in ipairs(Players:GetPlayers()) do D.Cancel(player,"Cancelled") check("release real profile "..player.UserId,DS.Runtime:Release(player.UserId)) end
	check("all packages cleaned",#W.ActivePackages:GetChildren()==0)
end,debug.traceback)
report.success=ok report.error=not ok and tostring(err) or nil
report.passed=0 for _,c in ipairs(report.checks) do if c.passed then report.passed+=1 end end
TS:EndTest(Http:JSONEncode(report))
