-- Kontak dan efek rintangan divalidasi server; tidak menerima laporan klien.
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local H={effects={},elapsed=0}
local C,W,D,puddle,barrier,basePosition,previousPosition
local function horizontal(v) return Vector3.new(v.X,0,v.Z) end
function H.Clear(player)
	local effect=H.effects[player.UserId]
	if effect then effect.velocity:Destroy(); effect.attachment:Destroy(); H.effects[player.UserId]=nil end
end
local function push(player,direction,speed,duration)
	local char=player.Character
	local r=char and char:FindFirstChild("HumanoidRootPart")
	if not r then return end
	H.Clear(player)
	direction=horizontal(direction)
	if direction.Magnitude<0.01 then direction=Vector3.new(1,0,0) end
	direction=direction.Unit
	local a=Instance.new("Attachment")
	a.Name="PaketKilatHazardAttachment"
	a.Parent=r
	local v=Instance.new("LinearVelocity")
	v.Name="PaketKilatHazardVelocity"
	v.Attachment0=a
	v.RelativeTo=Enum.ActuatorRelativeTo.World
	v.VelocityConstraintMode=Enum.VelocityConstraintMode.Plane
	v.PrimaryTangentAxis=Vector3.new(1,0,0)
	v.SecondaryTangentAxis=Vector3.new(0,0,1)
	v.PlaneVelocity=Vector2.new(direction.X*speed,direction.Z*speed)
	v.ForceLimitsEnabled=true
	v.ForceLimitMode=Enum.ForceLimitMode.Magnitude
	v.MaxForce=C.Hazards.MaxForce
	v.Parent=r
	H.effects[player.UserId]={velocity=v,attachment=a,expires=os.clock()+duration,root=r}
end
local function inBox(position,center,size,margin)
	local d=position-center
	return math.abs(d.X)<=size.X/2+margin and math.abs(d.Y)<=size.Y/2+margin and math.abs(d.Z)<=size.Z/2+margin
end
function H.Init(config,world,delivery)
	C,W,D=config,world,delivery
	puddle=W.Map.Expansion.Hazards.Puddle
	barrier=W.Map.Expansion.Hazards.MovingBarrier
	basePosition=barrier.Position
	previousPosition=barrier.Position
end
function H.Start()
	local sampled=0
	RunService.Heartbeat:Connect(function(dt)
		H.elapsed+=dt
		local omega=2*math.pi/C.Hazards.BarrierPeriod
		local pos=basePosition+Vector3.new(C.Hazards.BarrierAmplitude*math.sin(H.elapsed*omega),0,0)
		local speed=C.Hazards.BarrierAmplitude*omega*math.cos(H.elapsed*omega)
		barrier.CFrame=CFrame.new(pos)
		barrier:SetAttribute("MotionSpeed",speed)
		for userId,effect in pairs(H.effects) do
			if os.clock()>=effect.expires or not effect.root.Parent then
				effect.velocity:Destroy(); effect.attachment:Destroy(); H.effects[userId]=nil
			end
		end
		sampled+=dt
		if sampled<C.Hazards.SampleInterval then return end
		sampled=0
		local middle=(pos+previousPosition)/2
		local swept=barrier.Size+Vector3.new(math.abs(pos.X-previousPosition.X),0,0)
		for _,o in pairs(D.orders) do
			if o.outOfBounds or o.completionLocked then continue end
			o.hazardCooldowns=o.hazardCooldowns or {}
			local player=o.player
			local char=player.Character
			local r=char and char:FindFirstChild("HumanoidRootPart")
			local hum=char and char:FindFirstChildOfClass("Humanoid")
			if not r or not hum or hum.Health<=0 then continue end
			if o.status=="Carrying" then
				local localPos=puddle.CFrame:PointToObjectSpace(r.Position)
				local inPuddle=math.abs(localPos.X)<=puddle.Size.X/2 and math.abs(localPos.Z)<=puddle.Size.Z/2
					and localPos.Y>=1 and localPos.Y<=5.5
					and horizontal(r.AssemblyLinearVelocity).Magnitude>=C.Hazards.SlipMinimumSpeed
				o.slipSamples=inPuddle and ((o.slipSamples or 0)+1) or 0
				if o.slipSamples>=C.Hazards.SlipSamples and os.clock()-(o.hazardCooldowns.Slip or -math.huge)>=C.Hazards.SlipCooldown then
					local direction=horizontal(r.AssemblyLinearVelocity)
					if D.Impact(o,"Slip") then
						o.hazardCooldowns.Slip=os.clock()
						push(player,direction,C.Hazards.SlipSpeed,C.Hazards.SlipDuration)
					end
				end
			else o.slipSamples=0 end
			local subject=o.status=="Carrying" and r or o.package
			if subject and subject.Parent and math.abs(speed)>=C.Hazards.BarrierMinimumSpeed
				and inBox(subject.Position,middle,swept,1.25)
				and os.clock()-(o.hazardCooldowns.Barrier or -math.huge)>=C.Hazards.BarrierCooldown then
				local wasCarrying=o.status=="Carrying"
				if D.Impact(o,"Barrier") then
					o.hazardCooldowns.Barrier=os.clock()
					if wasCarrying then push(player,Vector3.new(speed,0,0),C.Hazards.KnockbackSpeed,C.Hazards.KnockbackDuration) end
				end
			end
		end
		previousPosition=pos
	end)
	Players.PlayerRemoving:Connect(H.Clear)
end
return H
