-- Server-authoritative attachment; detailed geometry is shared with shop previews.
local K={}local C,E
local V=require(game.ReplicatedStorage.PaketKilat.Shared.GearVisuals34)
function K.Init(config,economy)C,E=config,economy end
local function attach(model,limb,cf)
 model:PivotTo(cf)
 for _,p in model:GetDescendants()do if p:IsA("BasePart")then
  p.Anchored=false p.Massless=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
  local weld=Instance.new("WeldConstraint")weld.Part0=limb weld.Part1=p weld.Parent=p
 end end
end
function K.Apply(player)
 local char=player.Character if not char then return end
 for _,name in {"PaketKilatBag","PaketKilatGloveLeft","PaketKilatGloveRight"}do local old=char:FindFirstChild(name)if old then old:Destroy()end end
 local state=E.Snapshot(player)if not state.profileReady then return end
 local torso=char:FindFirstChild("UpperTorso")or char:FindFirstChild("Torso")
 local hum=char:FindFirstChildOfClass("Humanoid")
 local item=C.Cosmetics[state.equippedCosmetic]
 if not torso or not hum or hum.Health<=0 or not item then return end
 local scale=math.clamp(torso.Size.Y/2,.75,1.25)
 local bag=V.Bag(state.equippedCosmetic,item.Color)bag:ScaleTo(scale)
 local _,size=bag:GetBoundingBox()
 attach(bag,torso,torso.CFrame*CFrame.new(0,-.06*scale,torso.Size.Z/2+size.Z*.43))
 bag.Parent=char
 local level=state.gear and state.gear.level or 0
 if level>0 then for _,side in {"Left","Right"}do
  local hand=char:FindFirstChild(side.."Hand")local limb=hand or char:FindFirstChild(side.." Arm")
  if limb then
   local size=hand and(limb.Size+Vector3.new(.05,.04,.05))or Vector3.new(limb.Size.X+.06,.65,limb.Size.Z+.06)
   local glove=V.Glove(level,side,size)
   attach(glove,limb,limb.CFrame*(hand and CFrame.identity or CFrame.new(0,-limb.Size.Y/2+.18,0)))
   glove.Parent=char
  end
 end end
end
return K
