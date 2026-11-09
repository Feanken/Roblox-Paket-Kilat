-- Temporary Studio UI fixture; commands only through server test inspection.
local Players=game:GetService("Players") local p
repeat task.wait(0.1) p=Players:GetPlayers()[1] until p
local M=game.ServerScriptService.PaketKilat local D=require(M.DeliveryService) local E=require(M.EconomyService)
repeat task.wait(0.1) until E.Has(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
local W=workspace.PaketKilat
local control=Instance.new("Folder") control.Name="Stage5UI" control.Parent=workspace
local function pivot(point)
	local o=D.orders[p.UserId] if o then o.previousPosition=nil o.previousVelocity=nil end
	p.Character:PivotTo(CFrame.new(point+Vector3.new(0,3,0)))
end
local function act(action)
	local o=D.orders[p.UserId] D.requests[p.UserId]=nil
	local ok,code=D.Handle(p,action,o and o.orderId,action=="Deliver" and o.destinationId or nil)
	assert(ok,code)
end
control:SetAttribute("Phase","Idle")
for _,command in ipairs({"Start","Drop","Recover","Pickup","Deliver","Second"}) do
	repeat task.wait(0.1) until control:GetAttribute("Command")==command
	if command=="Start" or command=="Second" then pivot(W.Map.Depot.PickupPoint.Position) D.requests[p.UserId]=nil assert(D.Handle(p,"Start"))
	elseif command=="Deliver" then local o=D.orders[p.UserId] pivot(W.Map[o.destinationId].DestinationPoint.Position) task.wait(0.15) act(command)
	elseif command=="Pickup" then pivot(W.Map.RecoveryPoint.Position) act(command)
	else act(command) end
	control:SetAttribute("Phase",command)
end
