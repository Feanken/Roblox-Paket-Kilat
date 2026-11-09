local K={}
local C,E
function K.Init(config,economy) C,E=config,economy end
function K.Apply(player)
	local char=player.Character if not char then return end
	local old=char:FindFirstChild("PaketKilatBag") if old then old:Destroy() end
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
end
return K
