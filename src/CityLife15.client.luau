-- Cosmetic residents on fixed pedestrian loops; no physics, rewards or remotes.
local world=workspace:WaitForChild('PaketKilat')local map=world:WaitForChild('Map')
map:WaitForChild('Surface15')
local depot,basis
 game.ReplicatedStorage:WaitForChild('PaketKilat').Remotes.StateChanged.OnClientEvent:Connect(function(s)depot=s.depotPosition basis=s.routeBasis or CFrame.identity end)
local folder=Instance.new('Folder')folder.Name='PaketKilatLocalResidents15'folder.Parent=workspace
local residents={}
local function create(name,shirt,path,offset)
 local model=Instance.new('Model')model.Name=name model.Parent=folder local parts={}
 local function piece(n,size,color,shape)
  local p=Instance.new('Part')p.Name=n p.Size=size p.Color=color p.Material=Enum.Material.SmoothPlastic
  p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=true
  if shape then p.Shape=shape end p.Parent=model parts[n]=p return p
 end
 local skin=Color3.fromRGB(195,143,106)local pants=Color3.fromRGB(42,66,78)
 piece('Torso',Vector3.new(1.5,1.7,.8),shirt)
 piece('Head',Vector3.new(1.1,1.1,1.1),skin,Enum.PartType.Ball)
 for _,side in ipairs({'Left','Right'})do piece(side..'Arm',Vector3.new(.45,1.65,.55),skin)piece(side..'Leg',Vector3.new(.55,1.7,.65),pants)end
 piece('EyeLeft',Vector3.new(.09,.09,.07),Color3.fromRGB(35,38,38))piece('EyeRight',Vector3.new(.09,.09,.07),Color3.fromRGB(35,38,38))
 local length=0 for i=1,#path do length+=(path[i%#path+1]-path[i]).Magnitude end
 table.insert(residents,{parts=parts,path=path,length=length,offset=offset})
end
create('WargaTaman',Color3.fromRGB(228,178,83),{Vector3.new(49,0,-6),Vector3.new(49,0,12),Vector3.new(73,0,12),Vector3.new(49,0,12)},0)
create('PengunjungPasar',Color3.fromRGB(88,155,144),{Vector3.new(14,0,128),Vector3.new(44,0,128)},13)
local elapsed=0
game:GetService('RunService').Heartbeat:Connect(function(dt)
 elapsed+=dt if elapsed<.05 then return end elapsed=0
 if not depot then return end
 local t=workspace:GetServerTimeNow()
 for _,r in ipairs(residents)do
  local distance=(t*3+r.offset)%r.length local a,b
  for i=1,#r.path do a=r.path[i]b=r.path[i%#r.path+1]local len=(b-a).Magnitude if distance<=len then break end distance-=len end
  local pos=a+(b-a).Unit*distance local at=depot+basis:VectorToWorldSpace(pos-Vector3.new(0,0,-6))
  local cf=CFrame.lookAt(at,at+basis:VectorToWorldSpace((b-a).Unit))
  local swing=math.sin(t*7+r.offset)*.45 local p=r.parts
  p.Torso.CFrame=cf*CFrame.new(0,2.55,0)p.Head.CFrame=cf*CFrame.new(0,3.96,0)
  p.LeftLeg.CFrame=cf*CFrame.new(-.4,1.7,0)*CFrame.Angles(swing,0,0)*CFrame.new(0,-.85,0)
  p.RightLeg.CFrame=cf*CFrame.new(.4,1.7,0)*CFrame.Angles(-swing,0,0)*CFrame.new(0,-.85,0)
  p.LeftArm.CFrame=cf*CFrame.new(-1,3.2,0)*CFrame.Angles(-swing,0,0)*CFrame.new(0,-.8,0)
  p.RightArm.CFrame=cf*CFrame.new(1,3.2,0)*CFrame.Angles(swing,0,0)*CFrame.new(0,-.8,0)
  p.EyeLeft.CFrame=cf*CFrame.new(-.2,4.05,-.52)p.EyeRight.CFrame=cf*CFrame.new(.2,4.05,-.52)
 end
end)