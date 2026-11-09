-- Edit migration. Coordinates relative to actual DepotPad, never absolute height.
local world=workspace.PaketKilat local map=world.Map local origin=map.DepotPad.Position
assert(game.ServerStorage:FindFirstChild("PaketKilat_PrePolish03"),"Back up live map first")
assert(not map:FindFirstChild("Polish03"),"Already installed")
local f=Instance.new("Folder") f.Name="Polish03" f.Parent=map
local cream=Color3.fromRGB(242,230,203)
local teal=Color3.fromRGB(33,91,91)
local roofColor=Color3.fromRGB(171,77,52)
local function part(name,size,offset,color,material,collide,parent)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=origin+offset
 p.Anchored=true p.CanCollide=collide==true p.CanTouch=false p.CanQuery=collide==true
 p.Color=color p.Material=material or Enum.Material.SmoothPlastic
 p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent or f return p
end
local function move(p,x,z,sx,sz)
 p.Position=origin+Vector3.new(x,0,z) p.Size=Vector3.new(sx,2,sz)
 p.Material=Enum.Material.Asphalt p.Color=Color3.fromRGB(82,94,94)
end
-- Streets pass the front gardens, never behind the houses.
move(map.SafeRoadAcross,50,28,112,14)
move(map.SafeRoadDepot,0,21,12,14)
move(map.SafeRoadHouse,100,21,12,14)
local roads=map.Expansion.Roads
move(roads.WestSafeAcross,-50,28,112,14)
move(roads.WestSafeHouse,-100,21,12,14)
move(roads.NorthEntry,-12,28,38,14)
move(roads.NorthStreet,-24,86,14,116)
move(roads.MarketStreet,0,144,248,14)
-- Preserve barrier bypass and hazards at their original locations.
for _,x in ipairs({-100,0,100}) do
 part("FrontGardenWalk",Vector3.new(9,2,24),Vector3.new(x,0,135),cream,Enum.Material.Cobblestone,true)
end
-- Visual embankments support the street rather than roads floating over water.
for _,p in ipairs({map.SafeRoadAcross,map.SafeRoadDepot,map.SafeRoadHouse,roads.WestSafeAcross,roads.WestSafeHouse,roads.NorthEntry,roads.NorthStreet,roads.MarketStreet}) do
 part("StreetFoundation",Vector3.new(p.Size.X,6,p.Size.Z),p.Position-origin-Vector3.new(0,4,0),Color3.fromRGB(133,125,106),Enum.Material.Brick,false)
end
-- Remove only previous polish markings; archived originals remain in scoped backup.
for _,v in ipairs(map.Polish01:GetChildren()) do
 if v.Name=="SafeLaneDash" or v.Name=="SafeRouteSign" then v:Destroy() end
end
for x=-110,110,12 do
 part("CenterLine",Vector3.new(4,.04,.25),Vector3.new(x,1.025,28),cream,nil,false)
 part("CenterLine",Vector3.new(4,.04,.25),Vector3.new(x,1.025,144),cream,nil,false)
end
-- Sidewalks on the house-facing side; kept flush with road for accessible walking.
for _,z in ipairs({19.5,135.5}) do
 part("FrontSidewalk",Vector3.new(236,2,3),Vector3.new(0,0,z),Color3.fromRGB(207,200,181),Enum.Material.Cobblestone,true)
end
-- Correct symmetric pitched roofs, with gable ends under (not sticking through) panels.
local function roof(name,cx,cz,eave,half,rise,depth,parent)
 local model=Instance.new("Model") model.Name=name model.Parent=parent or f
 local len=math.sqrt(half*half+rise*rise) local angle=math.atan2(rise,half)
 for _,side in ipairs({-1,1}) do
  local p=part("RoofPanel",Vector3.new(len+.15,.38,depth),Vector3.new(cx+side*half/2,eave+rise/2,cz),roofColor,Enum.Material.Slate,true,model)
  p.CFrame=p.CFrame*CFrame.Angles(0,0,-side*angle)
 end
 part("RidgeCap",Vector3.new(.48,.32,depth+.15),Vector3.new(cx,eave+rise+.13,cz),roofColor,Enum.Material.Slate,false,model)
 for _,z in ipairs({cz-depth/2+.8,cz+depth/2-.8}) do
  for _,side in ipairs({-1,1}) do
   local g=Instance.new("WedgePart") g.Name="Gable" g.Size=Vector3.new(.24,rise,half-.8)
   g.CFrame=CFrame.new(origin+Vector3.new(cx+side*(half-.8)/2,eave+rise/2,z))*CFrame.Angles(0,-side*math.pi/2,0)
   g.Color=cream g.Material=Enum.Material.SmoothPlastic g.Anchored=true g.CanCollide=false g.CanTouch=false g.CanQuery=false g.Parent=model
  end
 end
 for _,side in ipairs({-1,1}) do
  part("EaveTrim",Vector3.new(.3,.3,depth+.15),Vector3.new(cx+side*half,eave-.1,cz),cream,nil,false,model)
 end
 return model
end
for i=1,5 do
 local house=map[string.format("Rumah%02d",i)] local b=house.Body.Position-origin
 house.Roof.Transparency=1 house.Roof.CanCollide=false
 roof("Roof_"..house.Name,b.X,b.Z,10.2,8.4,3,14)
 if i>1 then
  part("HouseFoundation",Vector3.new(28,7,28),Vector3.new(b.X-4,-4.5,b.Z+8),Color3.fromRGB(140,126,106),Enum.Material.Brick,false)
  part("FrontTerrace",Vector3.new(25,.08,11),Vector3.new(b.X-4,1.04,b.Z+13),Color3.fromRGB(218,204,174),Enum.Material.Cobblestone,false)
  part("HousePlinth",Vector3.new(13.4,.8,10.3),Vector3.new(b.X,1.45,b.Z),cream,Enum.Material.Brick,false)
  for _,side in ipairs({-1,1}) do
   part("CornerTrim",Vector3.new(.3,8.6,.3),Vector3.new(b.X+side*6.3,5.6,b.Z+5.15),cream,nil,false)
   local wx=b.X+side*4
   for _,dx in ipairs({-1.35,1.35}) do part("WindowTrim",Vector3.new(.15,3,.17),Vector3.new(wx+dx,6,b.Z+5.35),cream,nil,false) end
   for _,y in ipairs({4.5,7.5}) do part("WindowTrim",Vector3.new(2.85,.15,.17),Vector3.new(wx,y,b.Z+5.35),cream,nil,false) end
  end
 end
end
-- The old depot generation had filled/inverted wedges cutting through the roof.
for _,v in ipairs(map.Polish01.DepotFacade:GetDescendants()) do
 if v:IsA("BasePart") and (v.Name:find("Roof") or v.Name:find("Gable") or v.Name:find("Purlin")) then v.Transparency=1 v.CanCollide=false end
end
roof("DepotRoof",0,-8,9.3,10,3.8,14)
-- Keep the water tank sitting on the rear half of its roof, not through the ridge.
map.Rumah05.WaterTank.Position=origin+Vector3.new(-96,16.4,108)
-- Dependent route hint text now points to the front street.
for _,v in ipairs(map:GetDescendants()) do
 if v:IsA("TextLabel") and v.Text:find("Utara:") then v.Text="KAMPUNG KILAT" end
end
world:SetAttribute("LayoutRevision","Polish03_FrontStreets")
return {streetZ={28,144},roofCount=6,newInstances=#f:GetDescendants()}
