-- Edit-only replacement of floating bridge/barrier by an at-grade pedestrian connection.
assert(not game:GetService("RunService"):IsRunning(),"Edit only")
local map=workspace.PaketKilat.Map local b=map.DepotPad.CFrame
assert(not map:FindFirstChild("City34"),"City34 exists")
local backup=game.ServerStorage.PaketKilat_PreUpgrade34
local archived=Instance.new("Folder")archived.Name="MapObjects"archived.Parent=backup
local function archive(p)
 p:SetAttribute("OriginalParent34",p.Parent:GetFullName())p.Parent=archived
end
local removed=0
for _,p in map.City13:GetChildren()do
 if p:IsA("BasePart")and(p.Name=="PedestrianBridge"or p.Name=="WestRamp"or p.Name=="EastRamp"or p.Name=="BridgeSupport"or p.Name=="BridgeRailing")then archive(p)removed+=1 end
end
for _,p in map.Expansion.Hazards:GetChildren()do if p.Name=="MovingBarrier"or p.Name=="BarrierZone"or p.Name=="BarrierPost"then archive(p)removed+=1 end end
local root=Instance.new("Folder")root.Name="City34"root.Parent=map
local cream=Color3.fromRGB(236,224,199)local teal=Color3.fromRGB(44,101,102)local wood=Color3.fromRGB(128,86,59)
local function part(parent,name,size,v,color,solid)
 local p=Instance.new("Part")p.Name=name p.Size=size p.CFrame=b*CFrame.new(v)
 p.Anchored=true p.CanCollide=solid==true p.CanTouch=false p.CanQuery=solid==true p.Color=color or cream p.Material=Enum.Material.SmoothPlastic p.Parent=parent return p
end
-- Partition only the two grass fringes crossed by the path; no new layered floor.
local changed,created=0,0
for _,old in map.Surface15:GetChildren()do
 if not old:IsA("BasePart")or old.Material~=Enum.Material.Grass then continue end
 local c=b:PointToObjectSpace(old.Position)
 local x1,x2=c.X-old.Size.X/2,c.X+old.Size.X/2
 local z1,z2=c.Z-old.Size.Z/2,c.Z+old.Size.Z/2
 if x1>=-33.01 and x2<=.01 and z1<76 and z2>84 then
  for _,seg in {{z1,76,false},{76,84,true},{84,z2,false}}do
   if seg[2]-seg[1]>.01 then
    local p=old:Clone()p.Name=seg[3]and "Pavement34"or "Grass34"
    p.Size=Vector3.new(old.Size.X,old.Size.Y,seg[2]-seg[1])
    p.CFrame=b*CFrame.new(c.X,c.Y,(seg[1]+seg[2])/2)
    if seg[3]then p.Material=Enum.Material.Pavement p.Color=Color3.fromRGB(175,175,160)end
    if seg[3]and c.X< -25 then p.Size+=Vector3.new(.002,0,0)p.CFrame+=b:VectorToWorldSpace(Vector3.new(.001,0,0))end
    p:SetAttribute("Upgrade34",true)p.Parent=map.Surface15 created+=1
   end
  end
  archive(old)changed+=1
 end
end
for x=-29.5,-18.5,2.2 do part(root,"Crosswalk",Vector3.new(1.1,.035,6),Vector3.new(x,1.025,80),cream)end
for _,x in {-35,-13}do for _,z in {75,85}do
 part(root,"CrossingBollard",Vector3.new(.3,1.8,.3),Vector3.new(x,1.9,z),teal)
 part(root,"BollardReflector",Vector3.new(.32,.16,.32),Vector3.new(x,2.4,z),cream)
end end
local nodes=Instance.new("Folder")nodes.Name="WalkNodes"nodes.Parent=root
for i,p in {Vector3.new(-60,1,80),Vector3.new(-24,1,80),Vector3.new(6,1,80)}do
 local n=part(nodes,"Node"..i,Vector3.new(.1,.1,.1),p,teal)n.Transparency=1
end
local pos=map.City13.Stations.Pos3
local old=Instance.new("CFrameValue")old.Name="Pos3CFrame"old.Value=pos.CFrame old.Parent=backup
pos.CFrame=b*CFrame.new(6,1.1,80)
local post=part(root,"StampPost",Vector3.new(.3,4.6,.3),Vector3.new(10,3.3,76.5),wood)
local board=part(root,"ParkStampSign",Vector3.new(4,1.55,.22),Vector3.new(10,5.05,76.5),teal)
for _,face in {Enum.NormalId.Front,Enum.NormalId.Back}do
 local g=Instance.new("SurfaceGui")g.Face=face g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.PixelsPerStud=35 g.ZOffset=.1 g.MaxDistance=90 g.Parent=board
 local t=Instance.new("TextLabel")t.BackgroundTransparency=1 t.Size=UDim2.fromScale(1,1)t.Font=Enum.Font.GothamBold t.TextScaled=true t.TextColor3=cream t.Text="POS TAMAN\nCAP RUTE"t.Parent=g
end
-- Low side planting frames the connection and leaves the eight-stud walking strip open.
for _,p in {{-9,73},{-9,87}}do
 part(root,"LowPlanter",Vector3.new(5,.65,1.5),Vector3.new(p[1],1.325,p[2]),wood)
 for _,dx in {-1.5,0,1.5}do
  local bush=part(root,"RoundedHedge",Vector3.new(1.8,1.4,1.35),Vector3.new(p[1]+dx,2.25,p[2]),Color3.fromRGB(86,135,91))bush.Shape=Enum.PartType.Ball
 end
end
root:SetAttribute("ArchivedObjects",removed)root:SetAttribute("PartitionedTiles",changed)
workspace.PaketKilat:SetAttribute("CityRevision","GroundedCrossing34")
return {removed=removed,grassReplaced=changed,surfaceCreated=created,parts=#root:GetDescendants()}
