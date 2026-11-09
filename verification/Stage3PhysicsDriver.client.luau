local player=game.Players.LocalPlayer
local RunService=game:GetService("RunService")
RunService:BindToRenderStep("PaketKilatPhysicsTestDriver",Enum.RenderPriority.Last.Value,function()
	local char=player.Character
	local r=char and char:FindFirstChild("HumanoidRootPart")
	local hum=char and char:FindFirstChildOfClass("Humanoid")
	local target=r and r:GetAttribute("Stage3MoveTarget")
	if hum and target then
		local delta=(target-r.Position)*Vector3.new(1,0,1)
		hum:Move(delta.Magnitude>1 and delta.Unit or Vector3.zero,false)
	end
end)
player.PlayerGui:SetAttribute("Stage3PhysicsDriverReady",true)
workspace:WaitForChild("Stage3PhysicsReport",120)
RunService:UnbindFromRenderStep("PaketKilatPhysicsTestDriver")
player.PlayerGui:SetAttribute("Stage3PhysicsDriverReady",false)
