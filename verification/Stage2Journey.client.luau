-- LocalScript sementara. Aksi E/Q/R dikirim oleh tool keyboard MCP, bukan script ini.
-- Gerak rute memakai Humanoid:MoveTo. PivotTo hanya setup awal dan setup jatuh disengaja.
local player=game.Players.LocalPlayer
local RS=game.ReplicatedStorage.PaketKilat
local W=workspace.PaketKilat
local char=player.Character
local r,hum=char.HumanoidRootPart,char.Humanoid
local y=W.Map.DepotPad.Position.Y
local control=Instance.new("Folder") control.Name="Stage2Journey" control.Parent=player.PlayerGui
local reportValue=Instance.new("StringValue") reportValue.Name="Report" reportValue.Parent=control
local report={rounds={},pass=false,mode="Desktop; actual E/Q/R tool input; Humanoid MoveTo route",maxCarryError=0}
local state
local listener=RS.Remotes.StateChanged.OnClientEvent:Connect(function(s) state=s end)
local function phase(name) control:SetAttribute("Phase",name) end
local function waitFor(predicate,timeout)
	local deadline=os.clock()+(timeout or 120)
	repeat task.wait(0.05) until predicate() or os.clock()>=deadline
	assert(predicate(),"Timeout in "..tostring(control:GetAttribute("Phase")))
end
local function move(x,z)
	local target=Vector3.new(x,y+4,z)
	hum:MoveTo(target)
	waitFor(function() return ((r.Position-target)*Vector3.new(1,0,1)).Magnitude<1.2 end,12)
	assert(r.Position.Y>y,"Fell off walking route")
end
local function outward()
	for _,v in ipairs({{0,-20},{0,-40},{100,-40},{100,-20},{94,-12},{92,4},{100,4}}) do move(v[1],v[2]) end
end
local function back()
	for _,v in ipairs({{92,4},{94,-12},{100,-20},{100,-40},{0,-40},{0,-20},{0,0}}) do move(v[1],v[2]) end
end
local sample=game:GetService("RunService").Heartbeat:Connect(function()
	for _,p in ipairs(W.ActivePackages:GetChildren()) do
		if p:GetAttribute("ownerUserId")==player.UserId and p:GetAttribute("status")=="Carrying" then
			local desired=r.CFrame*CFrame.new(0,0,-2.5)
			report.maxCarryError=math.max(report.maxCarryError,(p.Position-desired.Position).Magnitude)
		end
	end
end)
local ok,err=pcall(function()
	char:PivotTo(CFrame.new(W.Map.Depot.PickupPoint.Position+Vector3.new(0,3,4)))
	task.wait(0.4)
	RS.Remotes.ActionRequest:FireServer("Sync")
	waitFor(function() return state~=nil end,5)
	assert(state.status=="Idle","Start journey with no active order")
	local balance=state.coins
	report.initialCoins=balance
	for index=1,3 do
		phase("ReadyStart"..index)
		waitFor(function() return state.status=="Carrying" end)
		local id=state.orderId
		if index==2 then
			phase("ReadyDrop2"); waitFor(function() return state.status=="Dropped" end)
			phase("ReadyRepick2"); waitFor(function() return state.status=="Carrying" end)
			phase("Falling2")
			char:PivotTo(CFrame.new(50,y+4,8))
			waitFor(function() return state.outOfBounds==true end,8)
			phase("ReadyRecover2")
			waitFor(function() return not state.outOfBounds and state.recoveryCount==1 end)
			assert(state.orderId==id and state.condition==80,"Recovery identity or penalty wrong")
			local target=W.Map.RecoveryPoint.Position+Vector3.new(0,3,3)
			hum:MoveTo(target)
			waitFor(function() return ((r.Position-target)*Vector3.new(1,0,1)).Magnitude<1.2 end,8)
			phase("ReadyPickRecovered2"); waitFor(function() return state.status=="Carrying" end)
		end
		phase("WalkingOut"..index)
		outward()
		phase("ReadyDeliver"..index)
		waitFor(function() return state.status=="Idle" and state.lastResult and state.lastResult.orderId==id end)
		local result=table.clone(state.lastResult)
		local expected=25+math.floor(15*result.condition/100)+math.floor(10*math.clamp(1-result.duration/90,0,1))
		assert(result.total==expected and state.coins==balance+expected,"Reward formula or cumulative balance wrong")
		balance=state.coins
		result.balance=balance
		table.insert(report.rounds,result)
		reportValue.Value=game.HttpService:JSONEncode(report)
		if index<3 then phase("WalkingBack"..index); back() end
	end
	report.pass=report.maxCarryError<0.5
	report.finalCoins=state.coins
end)
if not ok then report.error=tostring(err) end
listener:Disconnect(); sample:Disconnect()
reportValue.Value=game.HttpService:JSONEncode(report)
phase(ok and "Done" or "Failed")
print("[PaketKilat STAGE2 JOURNEY]",reportValue.Value)
