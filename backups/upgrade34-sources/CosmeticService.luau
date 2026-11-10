local K={}
local C,E
function K.Init(config,economy) C,E=config,economy end
function K.Apply(player)
	local char=player.Character if not char then return end
	for _,name in ipairs({"PaketKilatBag","PaketKilatGloveLeft","PaketKilatGloveRight"})do local old=char:FindFirstChild(name)if old then old:Destroy()end end
	local snapshot=E.Snapshot(player)
	if not snapshot.profileReady then return end
	local item=C.Cosmetics[snapshot.equippedCosmetic]
	local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	local hum=char:FindFirstChildOfClass("Humanoid")
	if not item or not torso or not hum or hum.Health<=0 then return end
	local bag=Instance.new("Part")
	bag.Name="PaketKilatBag" bag.Size=Vector3.new(1.5,1.7,0.65) bag.Color=item.Color
	bag.Material=Enum.Material.SmoothPlastic bag.Massless=true
	bag.CanCollide=false bag.CanTouch=false bag.CanQuery=false
	bag.CFrame=torso.CFrame*CFrame.new(0,-0.1,torso.Size.Z/2+0.35)
	bag:SetAttribute("CosmeticId",snapshot.equippedCosmetic)
	local weld=Instance.new("WeldConstraint") weld.Part0=torso weld.Part1=bag weld.Parent=bag
	bag.Parent=char
 local level=snapshot.gear and snapshot.gear.level or 0
 if level>0 then
  local color=({Color3.fromRGB(143,102,71),Color3.fromRGB(39,119,115),Color3.fromRGB(211,166,56)})[level]
  for _,side in ipairs({"Left","Right"})do
   local limb=char:FindFirstChild(side.."Hand")or char:FindFirstChild(side.." Arm")
   if limb then
    local glove=Instance.new("Part")glove.Name="PaketKilatGlove"..side
    local hand=limb.Name:find("Hand")~=nil
    glove.Size=hand and(limb.Size+Vector3.new(.08,.06,.08))or Vector3.new(limb.Size.X+.08,.55,limb.Size.Z+.08)
    glove.CFrame=limb.CFrame*(hand and CFrame.identity or CFrame.new(0,-limb.Size.Y/2+.24,0))
    glove.Color=color glove.Material=Enum.Material.Fabric glove.Massless=true glove.CanCollide=false glove.CanTouch=false glove.CanQuery=false
    glove:SetAttribute("GripLevel",level)local weld=Instance.new("WeldConstraint")weld.Part0=limb weld.Part1=glove weld.Parent=glove glove.Parent=char
   end
  end
 end
end
return K
