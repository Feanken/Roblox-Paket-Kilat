-- LocalScript sementara. Gerak rute memakai MoveTo pada controller klien normal.
-- PivotTo hanya menyiapkan awal setiap percobaan; tidak dipakai sepanjang rute.
local player=game.Players.LocalPlayer
local W=workspace.PaketKilat
local RS=game.ReplicatedStorage.PaketKilat
local C=require(RS.Shared.Config)
local char=player.Character
local r,hum=char.HumanoidRootPart,char.Humanoid
local origin=W.Map.DepotPad.Position
local control=Instance.new("Folder") control.Name="Stage3WalkControl" control.Parent=player.PlayerGui
local value=Instance.new("StringValue") value.Name="Report" value.Parent=control
local report={routes={},pass=false,maxCarryError=0,mode="Client MoveTo on real character; setup teleports only"}
local state
local listener=RS.Remotes.StateChanged.OnClientEvent:Connect(function(s) state=s end)
local function save() value.Value=game.HttpService:JSONEncode(report) end
local function phase(p) control:SetAttribute("Phase",p) end
local function waitFor(f,timeout)
	local deadline=os.clock()+timeout
	repeat task.wait(0.05) until f() or os.clock()>deadline
	assert(f(),"Timeout: "..tostring(control:GetAttribute("Phase")))
end
local function move(x,z)
	local target=origin+Vector3.new(x,4,z)
	hum:MoveTo(target)
	local refresh=os.clock()
	waitFor(function()
		if os.clock()-refresh>3 then hum:MoveTo(target); refresh=os.clock() end
		return ((r.Position-target)*Vector3.new(1,0,1)).Magnitude<1.2 or hum.Health<=0
	end,15)
	assert(hum.Health>0 and r.Position.Y>origin.Y,"Fell off route")
end
local function request(a,expected)
	task.wait(0.3)
	RS.Remotes.ActionRequest:FireServer(a,state and state.orderId,a=="Deliver" and state.destinationId or nil)
	waitFor(function() return state and state.status==expected end,5)
end
local paths={
	{{0,-20},{0,-40},{100,-40},{100,-20},{94,-12},{92,4},{100,4}},
	{{0,-20},{0,-40},{-100,-40},{-100,-20},{-106,-12},{-108,4},{-100,4}},
	{{0,8},{-24,8},{-24,44},{-48,44},{-48,86},{-24,86},{-24,132},{0,132},{0,123}},
	{{0,8},{-24,8},{-24,44},{-48,44},{-48,86},{-24,86},{-24,132},{100,132},{100,123}},
	{{0,8},{-24,8},{-24,44},{-48,44},{-48,86},{-24,86},{-24,132},{-100,132},{-100,123}},
	{{12,0},{50,0},{88,0},{100,3}},
}
local sample=game:GetService("RunService").Heartbeat:Connect(function()
	for _,p in ipairs(W.ActivePackages:GetChildren()) do if p:GetAttribute("ownerUserId")==player.UserId and p:GetAttribute("status")=="Carrying" and p:FindFirstChild("CarryWeld") then
		report.maxCarryError=math.max(report.maxCarryError,(p.Position-(r.CFrame*C.CarryOffset).Position).Magnitude)
	end end
end)
local ok,err=pcall(function()
	RS.Remotes.ActionRequest:FireServer("Sync")
	waitFor(function() return state~=nil end,5)
	assert(state.status=="Idle")
	for index=1,7 do
		phase("Setup "..index)
		char:PivotTo(CFrame.new(W.Map.Depot.PickupPoint.Position+Vector3.new(0,3,4)))
		task.wait(0.4)
		request("Start","Carrying")
		local id,kind=state.destinationId,state.packageType
		assert(id==string.format("Rumah%02d",(index-1)%5+1),"Unexpected assignment order")
		phase("Walking "..id.." "..kind..(index>5 and " shortcut" or " safe"))
		local began=os.clock()
		local slips=0
		if index<=6 then
			for _,point in ipairs(paths[index]) do move(point[1],point[2]); assert(state.status=="Carrying","Safe route lost package") end
			assert(state.condition==100,"Safe route damaged package")
		else
			move(-32,0)
			local deadline=os.clock()+20
			hum:MoveTo(origin+Vector3.new(-75,4,0))
			while r.Position.X>origin.X-70 do
				assert(os.clock()<deadline,"Puddle shortcut could not be crossed")
				if state.status=="Dropped" then
					slips+=1
					hum:MoveTo(r.Position)
					task.wait(0.7)
					local package
					for _,p in ipairs(W.ActivePackages:GetChildren()) do if p:GetAttribute("orderId")==state.orderId then package=p break end end
					assert(package,"Dropped package missing")
					if (r.Position-package.Position).Magnitude>10 then
						hum:MoveTo(package.Position+Vector3.new(3,2,0))
						waitFor(function() return (r.Position-package.Position).Magnitude<10 end,5)
					end
					request("Pickup","Carrying")
					hum:MoveTo(origin+Vector3.new(-75,4,0))
				end
				task.wait(0.05)
			end
			if state.status=="Dropped" then request("Pickup","Carrying") end
			move(-100,3)
			assert(slips>0,"Puddle shortcut did not exercise slip")
		end
		local walkSeconds=os.clock()-began
		request("Deliver","Idle")
		local result=table.clone(state.lastResult)
		local expected=25+math.floor(15*result.condition/100)+math.floor(10*math.clamp(1-result.duration/C.Routes[id].TargetSeconds,0,1))
		assert(result.total==expected and result.recordEligible,"Wrong reward or record eligibility")
		task.wait(0.2)
		local hint=player.PlayerGui.PaketKilatUI.Root.TopCard.Hint.Text
		assert(string.find(hint,"Rekor") or string.find(hint,"REKOR") or string.find(hint,"Terbaik"),"Record summary missing")
		table.insert(report.routes,{destinationId=id,packageType=kind,path=index>5 and "Shortcut" or "Safe",walkSeconds=walkSeconds,targetSeconds=C.Routes[id].TargetSeconds,slips=slips,result=result})
		save()
	end
	report.pass=true
end)
if not ok then report.error=tostring(err) end
sample:Disconnect(); listener:Disconnect()
save(); phase(ok and "Done" or "Failed")
print("[PaketKilat STAGE3 WALK]",value.Value)
