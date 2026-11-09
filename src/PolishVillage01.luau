-- Edit migration: visual pass only. Preserves anchors, hazards, economy and routes.
local world=workspace.PaketKilat
local map=world.Map
assert(not map:FindFirstChild("Polish01"),"Polish01 already applied")
assert(game.ServerStorage:FindFirstChild("PaketKilat_PrePolish01"),"Back up live place first")
local folder=Instance.new("Folder") folder.Name="Polish01" folder.Parent=map
local origin=map.DepotPad.Position
local cream=Color3.fromRGB(245,232,204)
local teal=Color3.fromRGB(27,91,92)
local terracotta=Color3.fromRGB(174,79,53)
local wood=Color3.fromRGB(121,83,58)
local function part(name,size,pos,color,material)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=origin+pos
 p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
 p.Color=color p.Material=material or Enum.Material.SmoothPlastic
 p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=folder return p
end
local function board(name,pos,size,title,subtitle,bg)
 local p=part(name,size,pos,bg or teal)
 local s=Instance.new("SurfaceGui") s.Name="Lettering" s.Face=Enum.NormalId.Front
 s.CanvasSize=Vector2.new(720,220) s.LightInfluence=0.3 s.Parent=p
 local t=Instance.new("TextLabel") t.Size=UDim2.fromScale(.94,.58) t.Position=UDim2.fromScale(.03,.03)
 t.BackgroundTransparency=1 t.Text=title t.Font=Enum.Font.GothamBlack t.TextScaled=true t.TextColor3=cream t.Parent=s
 local sub=t:Clone() sub.Position=UDim2.fromScale(.03,.65) sub.Size=UDim2.fromScale(.94,.23)
 sub.Text=subtitle sub.Font=Enum.Font.GothamMedium sub.Parent=s
 -- Board front faces +Z in this village.
 p.CFrame=p.CFrame*CFrame.Angles(0,math.pi,0)
 return p
end
-- Short-range signs replace huge tutorial billboards that obscure the world.
for _,gui in ipairs(map:GetDescendants()) do
 if gui:IsA("BillboardGui") then
  gui.MaxDistance=32 gui.Size=UDim2.fromOffset(160,36) gui.StudsOffset=Vector3.new(0,2,0)
  local t=gui:FindFirstChildWhichIsA("TextLabel")
  if t then t.TextSize=12 t.BackgroundTransparency=.12 t.BackgroundColor3=teal
   local parent=gui.Parent
   if parent.Name=="PickupPoint" then t.Text="AMBIL PESANAN"
   elseif parent.Name=="RecoveryPoint" then t.Text="PULIHKAN PAKET"
   elseif parent.Name=="NarrowPlank" then t.Text="PINTASAN · JAGA PAKET"
   elseif parent.Name=="DestinationPoint" then t.Text=parent.Parent.Name=="Rumah01" and "01 · BU SARI" or t.Text:match("^[^\n]+")
   elseif parent.Name=="VillageSign" then t.Text="KAMPUNG KILAT"
   else t.Text=t.Text:match("^[^\n]+") or t.Text end
  end
 end
end
-- Existing walkable surfaces keep exactly the same sizes/positions.
for _,p in ipairs(map:GetDescendants()) do
 if p:IsA("BasePart") and p.Parent~=folder then
  if p.Name:find("Road") or p.Parent.Name=="Roads" then
   p.Material=Enum.Material.Asphalt p.Color=Color3.fromRGB(86,100,101)
  elseif p.Name:find("Pad") or p.Name=="TreePatch" then
   p.Material=Enum.Material.Grass p.Color=Color3.fromRGB(119,155,98)
  elseif p.Name=="Roof" then p.Material=Enum.Material.Slate p.Color=terracotta
  elseif p.Name=="Window" then p.Color=Color3.fromRGB(98,163,173) p.Material=Enum.Material.Glass p.Reflectance=.1
  end
 end
end
-- Canal below the existing raised paths, never an invisible new walkable floor.
local canal=part("CanalWater",Vector3.new(282,.25,220),Vector3.new(0,-7,45),Color3.fromRGB(65,137,144),Enum.Material.Glass)
canal.Transparency=.25 canal.Reflectance=.12
part("CanalBed",Vector3.new(282,1,220),Vector3.new(0,-11,45),Color3.fromRGB(93,121,102),Enum.Material.Sand)
for _,v in ipairs({map.DepotPad,map.HousePad}) do
 local d=v.Position-origin
 part(v.Name.."Foundation",Vector3.new(28,7,28),d-Vector3.new(0,4.5,0),Color3.fromRGB(140,126,106),Enum.Material.Brick)
 part(v.Name.."Terrace",Vector3.new(27,.08,12),d+Vector3.new(0,1.04,5),Color3.fromRGB(218,204,174),Enum.Material.Cobblestone)
end
-- Depot trim, shelving and parcels; the central pickup lane remains clear.
for _,x in ipairs({-8,8}) do
 part("DepotPost",Vector3.new(.55,9,.55),Vector3.new(x,5.5,-3),teal,Enum.Material.Wood)
end
part("DepotFascia",Vector3.new(18,1.4,.5),Vector3.new(0,9.8,-3),teal)
board("DepotBrand",Vector3.new(0,8,-2.6),Vector3.new(8.8,2.1,.2),"PAKET KILAT!","DEPOT 01  /  KAMPUNG KILAT")
for i=0,11 do
 local p=part("StripedAwning",Vector3.new(1.5,.22,4),Vector3.new(-8.25+i*1.5,9,-.9),i%2==0 and cream or Color3.fromRGB(234,177,65),Enum.Material.Fabric)
 p.CFrame=p.CFrame*CFrame.Angles(math.rad(9),0,0)
end
for _,y in ipairs({2,4.2,6.4}) do
 part("ParcelShelf",Vector3.new(4.7,.22,2),Vector3.new(5.4,y,-10),wood,Enum.Material.WoodPlanks)
 for i=0,1 do
  local x=4.2+i*2.2
  part("DisplayParcel",Vector3.new(1.7,1.6,1.4),Vector3.new(x,y+.9,-10),Color3.fromRGB(192,146,89))
  part("ParcelTape",Vector3.new(.25,.035,1.43),Vector3.new(x,y+1.72,-10),cream)
 end
end
board("DispatchBoard",Vector3.new(-5.1,5.6,-11.35),Vector3.new(4.5,3,.18),"SIAP ANTAR?","AMBIL  >  JAGA  >  ANTAR")
-- Architectural dressing of Bu Sari's existing house.
local body=map.Rumah01.Body local b=body.Position-origin
body.Color=Color3.fromRGB(105,174,184)
part("HousePlinth",Vector3.new(13.4,1,10.4),Vector3.new(b.X,1.55,b.Z),cream,Enum.Material.Brick)
for _,x in ipairs({b.X-6.2,b.X+6.2}) do
 part("HouseCorner",Vector3.new(.45,8.3,.45),Vector3.new(x,6.4,b.Z+5.13),cream)
end
part("HouseEave",Vector3.new(16.4,.5,13.4),Vector3.new(b.X,10.1,b.Z),cream)
for _,x in ipairs({100,108}) do
 for _,dx in ipairs({-1.4,1.4}) do part("WindowFrame",Vector3.new(.18,3.1,.2),Vector3.new(x+dx,6,-2.48),cream) end
 for _,y in ipairs({4.45,7.55}) do part("WindowFrame",Vector3.new(3,.18,.2),Vector3.new(x,y,-2.48),cream) end
 part("WindowMullion",Vector3.new(.13,2.8,.22),Vector3.new(x,6,-2.45),cream)
end
board("HouseName",Vector3.new(104,8.4,-2.4),Vector3.new(5,1.1,.16),"BU SARI","RUMAH 01",teal)
part("DoorKnob",Vector3.new(.18,.18,.22),Vector3.new(105,4,-2.6),Color3.fromRGB(235,190,82),Enum.Material.Metal)
for _,x in ipairs({89,111}) do
 for z=0,10,2 do part("FencePicket",Vector3.new(.3,2.5,.7),Vector3.new(x,2.3,z),cream,Enum.Material.Wood) end
 part("FenceRail",Vector3.new(.25,.25,11),Vector3.new(x,2.5,5),cream,Enum.Material.Wood)
end
local function planter(x,z)
 part("Planter",Vector3.new(2.5,1.2,2.5),Vector3.new(x,1.65,z),terracotta,Enum.Material.ClayRoofTiles)
 local bush=part("PlanterLeaves",Vector3.new(3,2.6,3),Vector3.new(x,3.2,z),Color3.fromRGB(75,126,82),Enum.Material.Grass) bush.Shape=Enum.PartType.Ball
 for _,dx in ipairs({-.7,.6}) do local flower=part("Flower",Vector3.new(.6,.6,.6),Vector3.new(x+dx,4.1,z),Color3.fromRGB(247,196,94));flower.Shape=Enum.PartType.Ball end
end
planter(-11,-10) planter(11,-10) planter(90,-8) planter(112,-8)
-- Repeated subtle dashed lines clarify the safe loop without filling the screen.
for x=8,92,10 do part("SafeLaneDash",Vector3.new(3,.035,.22),Vector3.new(x,1.025,-40),cream) end
board("SafeRouteSign",Vector3.new(5,3.5,-19),Vector3.new(6,1.7,.2),"JALUR AMAN","IKUTI JALAN MEMUTAR",teal)
board("ShortcutSign",Vector3.new(12,3.7,6),Vector3.new(5,1.7,.2),"JALAN PINTAS","HATI-HATI PAKET JATUH",terracotta)
-- Existing HUD is hidden in Edit only; enabling at runtime is left unchanged.
game.Lighting.ClockTime=15.5 game.Lighting.Brightness=2.5 game.Lighting.GlobalShadows=true
game.Lighting.Ambient=Color3.fromRGB(112,119,125)
game.Lighting.OutdoorAmbient=Color3.fromRGB(155,153,141)
game.Lighting.ExposureCompensation=.1
world:SetAttribute("VisualRevision","Polish01")
return "Polish01 visual dressing applied: "..#folder:GetDescendants().." instances"
