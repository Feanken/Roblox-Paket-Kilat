-- LocalScript sementara. Seluruh aksi dan gerak sesudah setup memakai input sentuh emulator.
local player=game.Players.LocalPlayer
repeat task.wait(0.1) until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
task.wait(0.6)
local char=player.Character
local r=char.HumanoidRootPart
local W=workspace.PaketKilat
local RS=game.ReplicatedStorage.PaketKilat
local y=W.Map.DepotPad.Position.Y
local control=Instance.new("Folder") control.Name="Stage2TouchControl" control.Parent=player.PlayerGui
local resultValue=Instance.new("StringValue") resultValue.Name="Report" resultValue.Parent=control
local report={steps={},keyboardCount=0,touchBegan=0,pass=false,device="iPhone 17 Pro emulator",setupTeleport=true}
local state
local connections={}
local function save() resultValue.Value=game.HttpService:JSONEncode(report) end
table.insert(connections,game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.UserInputType==Enum.UserInputType.Keyboard then report.keyboardCount+=1 end
	if input.UserInputType==Enum.UserInputType.Touch then report.touchBegan+=1 end
	save()
end))
table.insert(connections,RS.Remotes.StateChanged.OnClientEvent:Connect(function(s) state=s end))
local function phase(name) control:SetAttribute("Phase",name) end
local function waitFor(predicate,timeout)
	local deadline=os.clock()+(timeout or 120)
	repeat task.wait(0.05) until predicate() or os.clock()>=deadline
	assert(predicate(),"Timeout at "..tostring(control:GetAttribute("Phase")))
end
local function step(name)
	table.insert(report.steps,{name=name,status=state.status,condition=state.condition,coins=state.coins})
	save()
end
workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
table.insert(connections,game:GetService("RunService").RenderStepped:Connect(function()
	workspace.CurrentCamera.CFrame=CFrame.lookAt(r.Position+Vector3.new(-14,9,0),r.Position+Vector3.new(6,0,0))
end))
local ok,err=pcall(function()
	char:PivotTo(CFrame.lookAt(Vector3.new(0,y+4,0),Vector3.new(10,y+4,0)))
	task.wait(0.3)
	RS.Remotes.ActionRequest:FireServer("Sync")
	waitFor(function() return state~=nil end,5)
	assert(state.status=="Idle")
	report.initialCoins=state.coins
	phase("ReadyStart"); waitFor(function() return state.status=="Carrying" end); step("Start")
	local id=state.orderId
	phase("ReadyDrop"); waitFor(function() return state.status=="Dropped" end); step("Drop")
	phase("ReadyRepick"); waitFor(function() return state.status=="Carrying" end); step("Pickup")
	phase("ReadyDropAgain"); waitFor(function() return state.status=="Dropped" end); step("DropAgain")
	phase("ReadyRecover"); waitFor(function() return state.recoveryCount==1 end); step("Recover")
	assert(state.condition==80 and state.orderId==id)
	phase("ReadyPickRecovered"); waitFor(function() return state.status=="Carrying" end); step("PickupRecovered")
	report.walkStart=tostring(r.Position)
	phase("ReadyMoveOut")
	waitFor(function() return (r.Position-W.Map.Rumah01.DestinationPoint.Position).Magnitude<=12 end)
	report.walkEnd=tostring(r.Position)
	report.walkedAcrossMap=r.Position.X>85
	phase("ReadyDeliver")
	waitFor(function() return state.status=="Idle" and state.lastResult and state.lastResult.orderId==id end)
	report.result=state.lastResult
	report.finalCoins=state.coins
	local expected=25+math.floor(15*state.lastResult.condition/100)+math.floor(10*math.clamp(1-state.lastResult.duration/90,0,1))
	report.pass=report.keyboardCount==0 and report.touchBegan>=8 and report.walkedAcrossMap and state.lastResult.total==expected and state.coins==report.initialCoins+expected
end)
if not ok then report.error=tostring(err) end
for _,connection in ipairs(connections) do connection:Disconnect() end
workspace.CurrentCamera.CameraType=Enum.CameraType.Custom
save()
phase(ok and "Done" or "Failed")
print("[PaketKilat STAGE2 TOUCH]",resultValue.Value)
