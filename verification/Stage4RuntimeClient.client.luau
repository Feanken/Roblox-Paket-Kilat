-- TEMPORARY actual client handshake and private snapshot observation.
local RS=game.ReplicatedStorage:WaitForChild("PaketKilat")
local qa=RS.Remotes:WaitForChild("Stage4QA",100) if not qa then return end
local player=game.Players.LocalPlayer
local done=false
qa.OnClientEvent:Connect(function(kind)
	if kind~="WireTest" then return end
	local root=player.PlayerGui.PaketKilatUI.Root local before=root:GetAttribute("Coins")
	local codes={}
	local c=RS.Remotes.StateChanged.OnClientEvent:Connect(function(_,code) table.insert(codes,code) end)
	for _,payload in ipairs({{false},{"BuyCosmetic",{}},{"BuyCosmetic","TasBiru",nil,999999},{"Deliver","foreign","Rumah99"}}) do
		RS.Remotes.ActionRequest:FireServer(table.unpack(payload,1,payload[4] and 4 or #payload)) task.wait(0.35)
	end
	for _=1,100 do RS.Remotes.ActionRequest:FireServer("BuyCosmetic","TasBiru",false) end
	task.wait(0.5) c:Disconnect()
	qa:FireServer("WireResult",{passed=root:GetAttribute("Coins")==before and #codes>=4 and #codes<=6,codes=codes,before=before,after=root:GetAttribute("Coins")})
end)
RS.Remotes.StateChanged.OnClientEvent:Connect(function(s)
	if done or not s.profileReady then return end
	local root=player.PlayerGui:WaitForChild("PaketKilatUI"):WaitForChild("Root")
	local deadline=os.clock()+8
	repeat task.wait(0.2) until root:GetAttribute("ProfileReady")==true or os.clock()>deadline
	done=true qa:FireServer("Ready",{profileOwnerUserId=s.profileOwnerUserId,coins=s.coins,uiReady=root:FindFirstChild("Shop")~=nil and root:GetAttribute("ProfileReady")==true})
end)
task.wait(1) RS.Remotes.ActionRequest:FireServer("Sync")
