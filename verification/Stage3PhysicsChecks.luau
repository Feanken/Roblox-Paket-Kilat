-- Script sementara Play: gerak fisik server nyata, posisi awal diatur sebagai fixture.
local f=game.ServerScriptService.PaketKilat
local D,E,P,H=require(f.DeliveryService),require(f.EconomyService),require(f.PackageService),require(f.HazardService)
local C=require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local player=game.Players:GetPlayers()[1]
local W=workspace.PaketKilat
local origin=W.Map.DepotPad.Position
local report={checks={},trials={},mode="Studio Play / physics runtime / one real client"}
local r,hum
local function check(name,pass) table.insert(report.checks,{name=name,pass=pass==true}) end
local function waitFor(f,timeout)
	local deadline=os.clock()+timeout
	repeat task.wait(0.025) until f() or os.clock()>deadline
	assert(f(),"Physics timeout")
end
local function action(a,id)
	task.wait(0.26)
	local ok,code=D.Handle(player,a,id)
	if code=="RateLimited" then task.wait(0.26); ok,code=D.Handle(player,a,id) end
	assert(ok,code)
end
local function setup(kind,id)
	D.Cancel(player)
	r,hum=player.Character.HumanoidRootPart,player.Character.Humanoid
	r:SetAttribute("Stage3MoveTarget",nil)
	r.Anchored=true
	player.Character:PivotTo(CFrame.new(W.Map.Depot.PickupPoint.Position+Vector3.new(0,3,4)))
	r.AssemblyLinearVelocity,r.AssemblyAngularVelocity=Vector3.zero,Vector3.zero
	r:SetAttribute("Stage3MoveTarget",r.Position)
	for index,item in ipairs(C.OrderSchedule) do if item.PackageType==kind and item.DestinationId==id then E.sessions[player.UserId].nextOrderIndex=index; break end end
	action("Start")
	r.Anchored=false
	r:SetNetworkOwnershipAuto()
	return D.orders[player.UserId]
end
local function recover(o)
	local id,started=o.orderId,o.startedAt
	local before=o.condition
	action("Recover",id)
	check("Recover identity/penalty "..#report.trials,o.orderId==id and o.startedAt==started and o.condition==math.max(0,before-20) and not o.outOfBounds and (o.package.Position-W.Map.RecoveryPoint.Position).Magnitude<3)
	check("Recovery clears effect "..#report.trials,H.effects[player.UserId]==nil)
end
local ok,err=pcall(function()
	local balance=E.Snapshot(player).coins
	for _,kind in ipairs({"Biasa","Rapuh"}) do
		local damage=C.PackageTypes[kind].ImpactDamage
		local o=setup(kind,"Rumah02")
		player.Character:PivotTo(CFrame.lookAt(origin+Vector3.new(-34,4,0),origin+Vector3.new(-65,4,0)))
		r.AssemblyLinearVelocity=Vector3.new(-16,0,0)
		r:SetAttribute("Stage3MoveTarget",origin+Vector3.new(-65,4,0))
		waitFor(function() return o.status=="Dropped" end,4)
		r:SetAttribute("Stage3MoveTarget",r.Position)
		local effect=H.effects[player.UserId]
		task.wait(0.1)
		table.insert(report.trials,{hazard="Puddle",packageType=kind,condition=o.condition,velocity=tostring(r.AssemblyLinearVelocity),hasEffect=effect~=nil})
		script:SetAttribute("TrialCount",#report.trials)
		check("Puddle validated damage "..kind,o.condition==100-damage and o.hazardCooldowns and o.hazardCooldowns.Slip~=nil)
		check("Puddle has planar slide "..kind,effect~=nil and math.abs(effect.velocity.PlaneVelocity.Magnitude-18)<0.01)
		local condition=o.condition
		task.wait(0.1)
		check("Puddle no repeated damage "..kind,o.condition==condition)
		recover(o)
		if effect then check("Slide objects removed "..kind,effect.velocity.Parent==nil and effect.attachment.Parent==nil) end
		D.Cancel(player)
		o=setup(kind,"Rumah03")
		player.Character:PivotTo(CFrame.new(origin+Vector3.new(-24,4,65)))
		r.AssemblyLinearVelocity=Vector3.zero
		r:SetAttribute("Stage3MoveTarget",r.Position)
		waitFor(function() return o.status=="Dropped" end,5)
		local pushed=H.effects[player.UserId]
		table.insert(report.trials,{hazard="MovingBarrier",packageType=kind,condition=o.condition,hasEffect=pushed~=nil,motionSpeed=W.Map.Expansion.Hazards.MovingBarrier:GetAttribute("MotionSpeed")})
		script:SetAttribute("TrialCount",#report.trials)
		check("Swept moving barrier hit "..kind,o.condition==100-damage and o.hazardCooldowns.Barrier~=nil)
		check("Barrier applies bounded push "..kind,pushed~=nil and pushed.velocity.PlaneVelocity.Magnitude<=18.01)
		task.wait(0.4)
		check("Push expires "..kind,H.effects[player.UserId]==nil)
		recover(o); D.Cancel(player)
		o=setup(kind,"Rumah01")
		player.Character:PivotTo(CFrame.new(origin+Vector3.new(50,4,8)))
		r.AssemblyLinearVelocity=Vector3.zero
		waitFor(function() return o.outOfBounds end,4)
		table.insert(report.trials,{hazard="NarrowPlankSideFall",packageType=kind,status=o.status,held=o.package.Anchored})
		script:SetAttribute("TrialCount",#report.trials)
		check("Plank failure remains recoverable "..kind,o.status=="Dropped" and o.package.Anchored)
		recover(o)
		check("Fallen player returned to depot "..kind,r.Position.Y>origin.Y)
		D.Cancel(player)
		o=setup(kind,"Rumah01")
		r.Anchored=true
		player.Character:PivotTo(CFrame.new(origin+Vector3.new(-8,20,0)))
		P.Carry(o,r)
		task.wait(0.15)
		r.Anchored=false
		r:SetNetworkOwner(nil)
		hum:ChangeState(Enum.HumanoidStateType.Freefall)
		r.AssemblyLinearVelocity=Vector3.zero
		r:SetAttribute("Stage3MoveTarget",r.Position)
		local maxFall=0
		waitFor(function() maxFall=math.max(maxFall,-r.AssemblyLinearVelocity.Y); return o.status=="Dropped" end,4)
		table.insert(report.trials,{hazard="CarriedHardLanding",packageType=kind,condition=o.condition,maxFall=maxFall})
		script:SetAttribute("TrialCount",#report.trials)
		check("Carried hard landing "..kind,o.condition==100-damage and maxFall>=C.ImpactSpeed)
		recover(o); D.Cancel(player)
		o=setup(kind,"Rumah01")
		action("Drop",o.orderId)
		P.Hold(o)
		o.package.CFrame=CFrame.new(origin+Vector3.new(-8,14,0))
		o.condition,o.lastDamageAt=100,-math.huge
		o.package.Anchored=false; o.package:SetNetworkOwner(nil)
		waitFor(function() return o.condition<100 end,4)
		table.insert(report.trials,{hazard="DroppedHardLanding",packageType=kind,condition=o.condition})
		script:SetAttribute("TrialCount",#report.trials)
		check("Dropped hard landing "..kind,o.condition==100-damage and o.package:GetNetworkOwner()==nil)
		D.Cancel(player)
	end
	local o=setup("Biasa","Rumah02")
	player.Character:PivotTo(CFrame.lookAt(origin+Vector3.new(-34,4,0),origin+Vector3.new(-65,4,0)))
	r.AssemblyLinearVelocity=Vector3.new(-16,0,0); r:SetAttribute("Stage3MoveTarget",origin+Vector3.new(-65,4,0))
	waitFor(function() return H.effects[player.UserId]~=nil end,4)
	local effect=H.effects[player.UserId]
	local oldChar=player.Character
	player:LoadCharacterAsync()
	waitFor(function() return player.Character and player.Character~=oldChar and player.Character:FindFirstChild("HumanoidRootPart") end,15)
	task.wait(0.7)
	check("Reset removes live hazard effect",not H.effects[player.UserId] and effect.velocity.Parent==nil and effect.attachment.Parent==nil and not D.orders[player.UserId])
	check("Hazards and recovery never credit coins",E.Snapshot(player).coins==balance)
	r=player.Character.HumanoidRootPart
	r:SetNetworkOwnershipAuto()
end)
if r and r.Parent then r.Anchored=false end
if not ok then report.error=tostring(err) end
report.pass=ok
for _,c in ipairs(report.checks) do if not c.pass then report.pass=false end end
local v=Instance.new("StringValue") v.Name,v.Value,v.Parent="Stage3PhysicsReport",game.HttpService:JSONEncode(report),workspace
print("[PaketKilat STAGE3 PHYSICS]",v.Value)
