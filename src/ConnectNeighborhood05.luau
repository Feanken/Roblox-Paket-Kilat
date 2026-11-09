-- Edit migration; follows actual yard geometry, not historical route offsets.
local w=workspace.PaketKilat local m=w.Map local o=m.DepotPad.Position
assert(w:GetAttribute("GroundRevision")=="Polish04","P04 required")
assert(game.ServerStorage:FindFirstChild("PaketKilat_PrePolish05"),"Backup first")
assert(not m:FindFirstChild("Polish05"),"Already applied")
local f=Instance.new("Folder") f.Name="Polish05" f.Parent=m
local cream=Color3.fromRGB(231,222,202)
local teal=Color3.fromRGB(33,91,91)
local function part(name,size,pos,color,mat,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=o+pos p.Color=color
 p.Anchored=true p.CanCollide=collide==true p.CanTouch=false p.CanQuery=collide==true
 p.Material=mat or Enum.Material.SmoothPlastic p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=f return p
end
local function relative(p) return p.Position-o end
local bedBottom=relative(m.Polish01.CanalBed).Y-.5
local function foundation(p)
 local at=relative(p) local top=at.Y-p.Size.Y/2
 local bottom=bedBottom-.5
 return part("SupportedFoundation",Vector3.new(p.Size.X,top-bottom,p.Size.Z),Vector3.new(at.X,(top+bottom)/2,at.Z),Color3.fromRGB(135,127,110),Enum.Material.Brick,false)
end
-- Retire the previous incomplete decorative foundations, keep originals in scoped backup.
for _,container in ipairs({m.Polish01,m.Polish03}) do
 for _,v in ipairs(container:GetChildren()) do
  if v:IsA("BasePart") and v.Name:find("Foundation") then v.Transparency=1 end
 end
end
local pads={m.DepotPad,m.HousePad}
for i=2,5 do table.insert(pads,m[string.format("Rumah%02d",i)]["HousePad"..i]) end
for _,pad in ipairs(pads) do foundation(pad) end
-- Align the first-row driveway stems with each supported yard.
for _,entry in ipairs({{m.SafeRoadDepot,m.DepotPad},{m.SafeRoadHouse,m.HousePad},{m.Expansion.Roads.WestSafeHouse,m.Rumah02.HousePad2}}) do
 local road,pad=entry[1],entry[2] local center=relative(pad)
 local start=center.Z+pad.Size.Z/2-.1 local finish=28
 road.Position=o+Vector3.new(center.X,0,(start+finish)/2)
 road.Size=Vector3.new(10,2,finish-start)
end
-- Retire fixed-coordinate front walks; rebuild from the three actual yards.
for _,p in ipairs(m.Polish03:GetChildren()) do
 if p:IsA("BasePart") and p.Name=="FrontGardenWalk" then p.Transparency=1 p.CanCollide=false p.CanQuery=false end
end
for i=3,5 do
 local pad=m[string.format("Rumah%02d",i)]["HousePad"..i] local center=relative(pad)
 local start=center.Z+pad.Size.Z/2-.1
 local walk=part("AlignedGardenWalk",Vector3.new(9,2,144-start),Vector3.new(center.X,0,(start+144)/2),cream,Enum.Material.Cobblestone,true)
 foundation(walk)
end
-- Every active road/deck has a visible connection down to the canal bed.
for _,v in ipairs({m.SafeRoadDepot,m.SafeRoadAcross,m.SafeRoadHouse}) do foundation(v) end
for _,p in ipairs(m.Expansion.Roads:GetChildren()) do if p:IsA("BasePart") then foundation(p) end end
for _,p in ipairs(m.Polish03:GetChildren()) do if p:IsA("BasePart") and p.Name=="FrontSidewalk" then foundation(p) end end
local function rail(x1,x2,z)
 local length=x2-x1
 part("CanalParapet",Vector3.new(length,1.35,.55),Vector3.new((x1+x2)/2,1.675,z),cream,Enum.Material.Concrete,true)
 part("ParapetCap",Vector3.new(length,.12,.7),Vector3.new((x1+x2)/2,2.4,z),Color3.fromRGB(164,178,169),Enum.Material.SmoothPlastic,false)
 for x=x1+1,x2-1,12 do part("ParapetPost",Vector3.new(.7,1.65,.7),Vector3.new(x,1.825,z),teal,nil,false) end
end
-- Leave the spine junction open. No rails across front driveways.
rail(-122,-34,35) rail(-14,122,35) rail(-122,122,151)
-- Short non-colliding paving strips define each doorstep without adding a trip step.
local names={"BU SARI","PAK BUDI","BU RINA","PAK AGUS","BU DEWI"}
for i=1,5 do
 local house=m[string.format("Rumah%02d",i)]
 local pad=i==1 and m.HousePad or house["HousePad"..i]
 local center=relative(pad) local door=relative(house.Door)
 part("DoorstepPath",Vector3.new(7,.035,12),Vector3.new(center.X,1.07,center.Z+7),cream,Enum.Material.Concrete,false)
 part("PorchLanding",Vector3.new(8,.04,3.5),Vector3.new(door.X,1.08,door.Z+2.2),cream,Enum.Material.CeramicTiles,false)
 if i>1 then
  local sign=part("HouseAddress",Vector3.new(6.4,1.25,.15),Vector3.new(door.X,8.2,door.Z+.42),teal,nil,false)
  sign.CFrame=sign.CFrame*CFrame.Angles(0,math.pi,0)
  local gui=Instance.new("SurfaceGui") gui.Face=Enum.NormalId.Front gui.CanvasSize=Vector2.new(600,110) gui.LightInfluence=.35 gui.Parent=sign
  local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(.94,.85) t.Position=UDim2.fromScale(.03,.075)
  t.BackgroundTransparency=1 t.Font=Enum.Font.GothamBold t.TextScaled=true t.TextColor3=cream t.Text=string.format("%02d  /  %s",i,names[i]) t.Parent=gui
 end
 local x,z=center.X+6,center.Z+10
 part("MailboxPost",Vector3.new(.25,2.1,.25),Vector3.new(x,2.05,z),Color3.fromRGB(127,89,61),Enum.Material.Wood,false)
 local box=part("Mailbox",Vector3.new(1.7,1.15,1),Vector3.new(x,3.55,z),teal,nil,false)
 part("MailSlot",Vector3.new(1.1,.09,.04),Vector3.new(x,3.72,z+.52),Color3.fromRGB(26,40,40),nil,false)
 part("MailboxNumber",Vector3.new(.6,.22,.04),Vector3.new(x,3.3,z+.52),cream,nil,false)
end
w:SetAttribute("NeighborhoodRevision","Polish05")
return {alignedYards=5,foundationBottom=bedBottom-.5,detailInstances=#f:GetDescendants()}
