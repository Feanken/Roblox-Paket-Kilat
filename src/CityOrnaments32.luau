-- City32: append-only Edit art migration. No runtime scripts, terrain writes or anchor movement.
local RunService=game:GetService("RunService")
assert(not RunService:IsRunning(),"City32 requires Edit")
local map=workspace.PaketKilat.Map
assert(not map:FindFirstChild("City32"),"City32 already installed")
local root=Instance.new("Folder") root.Name="City32" root.Parent=map
local basis=map.DepotPad.CFrame
local cream=Color3.fromRGB(236,224,199)
local teal=Color3.fromRGB(44,101,102)
local wood=Color3.fromRGB(128,86,59)
local soil=Color3.fromRGB(83,65,46)
local ink=Color3.fromRGB(42,59,62)
local coral=Color3.fromRGB(205,116,86)
local gold=Color3.fromRGB(224,182,76)
local green=Color3.fromRGB(91,139,93)
local floorRay=RaycastParams.new() floorRay.FilterType=Enum.RaycastFilterType.Include floorRay.FilterDescendantsInstances={map.Surface15}
local audit={groups={},skipped={},ground={}}
local blockers={}
local function bounds(p)
 local cf=basis:ToObjectSpace(p.CFrame) local s=p.Size/2
 local r,u,l=cf.RightVector,cf.UpVector,cf.LookVector
 local e=Vector3.new(math.abs(r.X)*s.X+math.abs(u.X)*s.Y+math.abs(l.X)*s.Z,math.abs(r.Y)*s.X+math.abs(u.Y)*s.Y+math.abs(l.Y)*s.Z,math.abs(r.Z)*s.X+math.abs(u.Z)*s.Y+math.abs(l.Z)*s.Z)
 return cf.Position-e,cf.Position+e
end
for _,p in map:GetDescendants() do
 if p:IsA("BasePart") and p.Transparency<.95 then
  local lo,hi=bounds(p)
  if hi.Y>1.3 and lo.Y<15 then table.insert(blockers,{lo=lo,hi=hi,name=p:GetFullName()})end
 end
end
local function clear(x,z,w,d,h)
 local lo=Vector3.new(x-w/2-.25,1.15,z-d/2-.25)
 local hi=Vector3.new(x+w/2+.25,1+h,z+d/2+.25)
 for _,b in blockers do if lo.X<b.hi.X and hi.X>b.lo.X and lo.Y<b.hi.Y and hi.Y>b.lo.Y and lo.Z<b.hi.Z and hi.Z>b.lo.Z then return false,b.name end end
 -- Full street lanes and bridge approaches remain untouched by standing props.
 if math.abs(z-28)<8+d/2 or math.abs(z-144)<8+d/2 then return false,"street" end
 if z>28 and z<144 and math.abs(x+24)<8+w/2 then return false,"central street" end
 if x+w/2>-62 and x-w/2<25 and z+d/2>73 and z-d/2<87 then return false,"bridge approach" end
 for _,a in {{-2,-6},{-8,5},{6,4},{98,3},{-102,3},{-5,114},{108,114},{-102,114}} do
  local dx=math.max(math.abs(x-a[1])-w/2,0) local dz=math.max(math.abs(z-a[2])-d/2,0)
  if dx*dx+dz*dz<64 then return false,"interaction clearance"end
 end
 return true
end
local function floorAt(x,z)
 local hit=workspace:Raycast(basis:PointToWorldSpace(Vector3.new(x,10,z)),Vector3.new(0,-20,0),floorRay)
 assert(hit,"Missing existing surface "..x..","..z)
 return hit.Position.Y-basis.Position.Y
end
local function group(name)
 local m=Instance.new("Model")m.Name=name return m
end
local function flush(m,tag)
 m:SetAttribute("City32Zone",tag or m.Name)
 m.Parent=root
 local n=0 for _,p in m:GetDescendants()do if p:IsA("BasePart")then n+=1 end end
 table.insert(audit.groups,{name=m.Name,parts=n})
 task.wait()
end
local function part(m,name,size,pos,color,rot,shape)
 local p=Instance.new("Part")p.Name=name p.Size=size
 p.CFrame=basis*CFrame.new(pos)*(rot or CFrame.identity)
 p.Color=color or cream p.Material=Enum.Material.SmoothPlastic
 p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
 p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end
 p.Parent=m return p
end
local function text(p,title,face,size)
 local gui=Instance.new("SurfaceGui")gui.Face=face or Enum.NormalId.Front gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.PixelsPerStud=size or 35
 gui.MaxDistance=100 gui.LightInfluence=.35 gui.Parent=p
 local l=Instance.new("TextLabel")l.Size=UDim2.fromScale(.92,.86)l.Position=UDim2.fromScale(.04,.07)
 l.BackgroundTransparency=1 l.Text=title l.TextScaled=true l.Font=Enum.Font.GothamBold l.TextColor3=cream l.Parent=gui
end
local function template(parent,source,name,x,z,height,angle,support)
 local m=source:Clone()m.Name=name
 for _,v in m:GetDescendants()do
  assert(not v:IsA("LuaSourceContainer"),"Unclean template")
  if v:IsA("BasePart")then v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=true end
  if v:IsA("Light")then v:Destroy()end
 end
 local _,s=m:GetBoundingBox()m:ScaleTo(m:GetScale()*height/s.Y)
 m:PivotTo(basis*CFrame.new(x,0,z)*CFrame.Angles(0,math.rad(angle or 0),0))
 local cf,sz=m:GetBoundingBox()local target=basis.Position.Y+(support or floorAt(x,z))
 m:PivotTo(m:GetPivot()+Vector3.new(0,target-(cf.Position.Y-sz.Y/2),0))
 m:SetAttribute("SupportY32",target) m.Parent=parent
 table.insert(audit.ground,{name=parent.Name.."/"..name,model=m})
 return m
end
local function tryTemplate(source,name,x,z,h,angle)
 local _,s=source:GetBoundingBox()local scale=h/s.Y
 local w,d=s.X*scale,s.Z*scale
 if (angle or 0)%180~=0 then w,d=d,w end
 local ok,why=clear(x,z,w,d,h)
 if not ok then table.insert(audit.skipped,{name=name,reason=why})return end
 local g=group(name)
 local m=template(g,source,name,x,z,h,angle)
 for _,p in m:GetDescendants()do if p:IsA("BasePart")then local lo,hi=bounds(p)table.insert(blockers,{lo=lo,hi=hi,name=name})end end
 flush(g,"green spaces")return m
end
local assets07=game.ServerStorage.PaketKilat_CreatorAssets07
local assets09=game.ServerStorage.PaketKilat_CreatorAssets09
-- Three planted pockets use existing grass; the rim/soil/flowers form supported objects.
for _,spec in {
 {"KebunWarga",-62,1,18,5},{"TamanTimur",135,72,5,14},{"KebunPiknik",-60,101,18,4}
} do
 local name,x,z,w,d=table.unpack(spec)
 local ok,why=clear(x,z,w,d,3.1)
 if ok then
  local g=group(name)local y=floorAt(x,z)
  part(g,"TerracottaBed",Vector3.new(w,.55,d),Vector3.new(x,y+.275,z),coral)
  part(g,"InsetSoil",Vector3.new(w-.35,.12,d-.35),Vector3.new(x,y+.57,z),soil)
  for i=-1,1 do
   local bx=x+(w>d and i*(w/3) or 0)local bz=z+(d>w and i*(d/3) or 0)
   template(g,assets09.GardenBush,"GardenShrub"..i,bx,bz,1.7,0,y+.63)
   for k=-1,1 do
    local fx=bx+(w>d and k*.7 or 1.3)local fz=bz+(w>d and 1.25 or k*.7)
    part(g,"FlowerStem",Vector3.new(.09,.6,.09),Vector3.new(fx,y+.93,fz),green)
    part(g,"Flower",Vector3.new(.4,.23,.4),Vector3.new(fx,y+1.28,fz),k==0 and gold or cream,nil,Enum.PartType.Ball)
   end
  end
  for _,p in g:GetDescendants()do if p:IsA("BasePart")then local lo,hi=bounds(p)table.insert(blockers,{lo=lo,hi=hi,name=name})end end
  flush(g,"green spaces")
 else table.insert(audit.skipped,{name=name,reason=why})end
end
for i,s in {{-79,5,12},{-43,4,13},{136,47,12},{136,118,13},{-40,112,11}}do
 tryTemplate(assets07.BroadleafTree,"NeighbourhoodTree"..i,s[1],s[2],s[3],i*29)
end
tryTemplate(assets07.ParkBench,"KebunBench",-60,-5,2.9,0)
tryTemplate(assets07.ParkBench,"EastGardenBench",136,99,2.9,90)
tryTemplate(assets09.StreetLamp,"EastGardenLamp",139,94,8.5,0)
-- Small stone pavers are deliberately raised, spaced accents on the grass, not new floor sheets.
local walk=group("GardenApproach")
for _,z in {7,10,13,16}do
 local ok=clear(-62,z,2.8,1.7,.1)
 if ok then local y=floorAt(-62,z)part(walk,"SteppingStone",Vector3.new(2.8,.1,1.7),Vector3.new(-62,y+.05,z),cream)end
end
if #walk:GetChildren()>0 then flush(walk,"green spaces")else walk:Destroy()end
-- Facade microdetail is attached to existing walls, not standing in the delivery corridor.
for _,name in {"TOKO ROTI","RUMAH SUSUN","BENGKEL","TOKO BUKU","KANTOR KAMPUNG"}do
 local body=map.City13[name].Body local c=basis:PointToObjectSpace(body.Position)
 local w,d=body.Size.X,body.Size.Z local front=c.Z-d/2-.22 local top=c.Y+body.Size.Y/2
 local g=group(name.."_Details")
 part(g,"RainGutter",Vector3.new(w+.5,.22,.35),Vector3.new(c.X,top+.4,front-.2),ink)
 part(g,"Downpipe",Vector3.new(.18,top-.6,.18),Vector3.new(c.X+w/2-.7,(top+1.6)/2,front-.38),teal)
 part(g,"DrainElbow",Vector3.new(.18,.18,.6),Vector3.new(c.X+w/2-.7,1.48,front-.6),teal)
 for _,height in {4.5,top-2}do part(g,"PipeClip",Vector3.new(.38,.12,.15),Vector3.new(c.X+w/2-.7,height,front-.48),cream)end
 for _,dx in {-w*.27,w*.27}do
  local x=c.X+dx
  part(g,"WindowBox",Vector3.new(3.6,.5,.95),Vector3.new(x,9.52,front-.55),coral)
  part(g,"WindowBoxSoil",Vector3.new(3.3,.08,.7),Vector3.new(x,9.8,front-.55),soil)
  for k=-1,1 do
   part(g,"WindowLeaves",Vector3.new(.9,.42,.55),Vector3.new(x+k,10.05,front-.63),green,nil,Enum.PartType.Ball)
   part(g,"WindowFlower",Vector3.new(.3,.26,.3),Vector3.new(x+k,10.32,front-.79),name=="TOKO BUKU" and cream or gold,nil,Enum.PartType.Ball)
  end
  for _,sx in {-1.15,1.15}do part(g,"WindowBoxBracket",Vector3.new(.13,.65,.65),Vector3.new(x+sx,9.12,front-.35),teal)end
 end
 -- One compact AC and raised vent slats on the side wall.
 local ax=c.X+w/2+.6
 part(g,"ACCase",Vector3.new(1.15,1.6,2.8),Vector3.new(ax,15,c.Z+1),cream)
 for _,dy in {-.4,0,.4}do part(g,"ACVent",Vector3.new(.06,.13,2.35),Vector3.new(ax+.6,15+dy,c.Z+1),ink)end
 part(g,"ACMount",Vector3.new(1.3,.15,2.4),Vector3.new(ax,14.12,c.Z+1),teal)
 local roof=top+1.6
 part(g,"RoofVentBase",Vector3.new(1.8,.25,1.8),Vector3.new(c.X-4,roof,c.Z+3),ink)
 part(g,"RoofVent",Vector3.new(.9,1.1,.9),Vector3.new(c.X-4,roof+.65,c.Z+3),teal)
 part(g,"VentRainCap",Vector3.new(1.4,.18,1.4),Vector3.new(c.X-4,roof+1.29,c.Z+3),cream)
 flush(g,"facades")
end
-- A real bicycle forecourt for the existing bicycle repair shop.
local bike=game.ServerStorage.PaketKilat_CreatorAssets32.Bicycle
tryTemplate(bike,"BengkelDisplayBicycle",83.5,43.5,3.6,90)
tryTemplate(bike,"BengkelParkedBicycle",92,57,3.6,0)
local shop=group("BengkelWorkshop")
local bx=88.45 local z=65
part(shop,"ToolBoard",Vector3.new(.25,3.3,5.2),Vector3.new(bx,4.3,z),wood)
for i=-1,1 do
 part(shop,"ToolHook",Vector3.new(.22,.18,.25),Vector3.new(bx+.22,5,z+i*1.3),cream)
 part(shop,"HangingSpanner",Vector3.new(.12,1.15,.16),Vector3.new(bx+.32,4.45,z+i*1.3),cream)
 part(shop,"SpannerHead",Vector3.new(.15,.35,.5),Vector3.new(bx+.32,5.05,z+i*1.3),cream)
end
local blade=part(shop,"RepairBladeSign",Vector3.new(.28,1.8,3.5),Vector3.new(88.6,7.2,51),teal)
text(blade,"SERVIS",Enum.NormalId.Right)text(blade,"SERVIS",Enum.NormalId.Left)
flush(shop,"shop identity")
-- Market-specific chalkboards, discreet counter tags and an overhead festoon.
for _,s in {{20,"ROTI HANGAT","Baru dari oven"},{45,"SAYUR SEGAR","Wortel panen pagi"},{70,"BUAH SEGAR","Pilihan hari ini"}}do
 local x=s[1]-9.7 local z=107 local g=group("MarketBoard"..s[1])
 local ok,why=clear(x,z,2.6,1.3,4.3)
 if ok then
  local y=floorAt(x,z)
  for _,dx in {-1,1}do part(g,"ChalkboardFoot",Vector3.new(.18,1.3,1.2),Vector3.new(x+dx,y+.65,z),wood)end
  local board=part(g,"Chalkboard",Vector3.new(2.6,3,.22),Vector3.new(x,y+2.7,z),ink)
  for _,dx in {-1.35,1.35}do part(g,"BoardFrame",Vector3.new(.15,3.2,.3),Vector3.new(x+dx,y+2.7,z),wood)end
  text(board,s[2].."\n\n"..s[3],Enum.NormalId.Back) text(board,s[2].."\n\n"..s[3],Enum.NormalId.Front)
  flush(g,"market")
 else g:Destroy()table.insert(audit.skipped,{name="MarketBoard"..s[1],reason=why})end
end
local festoon=group("MarketFestoon")
for _,x in {10,81}do
 local y=floorAt(x,98)
 part(festoon,"FestoonFoot",Vector3.new(.75,.25,.75),Vector3.new(x,y+.125,98),cream)
 part(festoon,"FestoonPost",Vector3.new(.2,11.5,.2),Vector3.new(x,y+5.75,98),teal)
end
local function wire(a,b)
 local av=basis:PointToWorldSpace(a)local bv=basis:PointToWorldSpace(b)
 local p=part(festoon,"FestoonCable",Vector3.new(.055,.055,(bv-av).Magnitude),Vector3.zero,ink)
 p.CFrame=CFrame.lookAt((av+bv)/2,bv)
end
for i=0,11 do
 local x1=10+71*i/12 local x2=10+71*(i+1)/12
 local y1=12.5-1.25*math.sin(math.pi*i/12)local y2=12.5-1.25*math.sin(math.pi*(i+1)/12)
 wire(Vector3.new(x1,y1,98),Vector3.new(x2,y2,98))
 if i>0 and i<11 then
  local p=Instance.new("WedgePart")p.Name="MarketPennant"p.Size=Vector3.new(.07,1.25,1.65)
  p.CFrame=basis*CFrame.new(x1,y1-.65,98)*CFrame.Angles(0,math.pi/2,math.pi)
  p.Color=({teal,coral,gold,cream})[i%4+1]p.Material=Enum.Material.SmoothPlastic
  p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Parent=festoon
 end
end
flush(festoon,"market")
-- Curb drains are thin supported insets; no standing objects obstruct crossings.
local drains=group("StreetDrains")
for i,s in {{-114,21.65},{-76,34.35},{-48,21.65},{20,34.35},{74,21.65},{114,34.35},{-30.3,102},{-17.7,119}}do
 local x,z=s[1],s[2]local y=floorAt(x,z)
 part(drains,"DrainFrame",Vector3.new(1.05,.065,1.7),Vector3.new(x,y+.0325,z),ink)
 for _,dz in {-.5,0,.5}do part(drains,"DrainSlot",Vector3.new(.78,.02,.12),Vector3.new(x,y+.075,z+dz),teal)end
end
flush(drains,"street detail")
for _,s in {{"PESISIR",-110,40},{"ALUN-ALUN",100,40},{"PASAR PAGI",105,131}}do
 local name,x,z=table.unpack(s)local ok,why=clear(x,z,4.4,.5,7)
 if ok then
  local g=group("StreetName_"..name)local y=floorAt(x,z)
  part(g,"StreetSignPole",Vector3.new(.22,6.6,.22),Vector3.new(x,y+3.3,z),teal)
  local sign=part(g,"StreetName",Vector3.new(4.4,.9,.22),Vector3.new(x,y+6.2,z),teal)
  text(sign,name,Enum.NormalId.Front)text(sign,name,Enum.NormalId.Back)
  flush(g,"street detail")
 else table.insert(audit.skipped,{name=name,reason=why})end
end
-- True mesh support sampling: ray upward into each newly placed imported model.
local rp=RaycastParams.new()rp.FilterType=Enum.RaycastFilterType.Include
for _,entry in audit.ground do
 local model=entry.model local cf,size=model:GetBoundingBox()
 local r,u,l=cf.RightVector,cf.UpVector,cf.LookVector
 local ex=math.abs(r.X)*size.X/2+math.abs(u.X)*size.Y/2+math.abs(l.X)*size.Z/2
 local ez=math.abs(r.Z)*size.X/2+math.abs(u.Z)*size.Y/2+math.abs(l.Z)*size.Z/2
 local step=math.max(.08,math.max(ex,ez)/22)
 rp.FilterDescendantsInstances={model}
 local target=model:GetAttribute("SupportY32")local low=math.huge local hits=0
 for x=cf.Position.X-ex,cf.Position.X+ex,step do for z=cf.Position.Z-ez,cf.Position.Z+ez,step do
  local hit=workspace:Raycast(Vector3.new(x,target-2,z),Vector3.new(0,25,0),rp)
  if hit then low=math.min(low,hit.Position.Y)hits+=1 end
 end end
 local gap=low~=math.huge and low-target or nil
 local shift=gap and gap>.015 and gap<1.5 and -gap or 0
 if shift~=0 then model:PivotTo(model:GetPivot()+Vector3.new(0,shift,0))end
 for _,v in model:GetDescendants()do if v:IsA("BasePart")then v.CanQuery=false end end
 model:SetAttribute("SupportGap32",gap and gap+shift)
 entry.gap=gap and gap+shift entry.hits=hits entry.shift=shift entry.model=nil
 assert(entry.gap and math.abs(entry.gap)<.06,"Review mesh support: "..entry.name)
 task.wait()
end
local count=0 for _,p in root:GetDescendants()do if p:IsA("BasePart")then count+=1 end end
audit.parts=count
root:SetAttribute("BuildAudit32",game.HttpService:JSONEncode(audit))
workspace.PaketKilat:SetAttribute("CityRevision","NeighbourhoodDetails32")
return game.HttpService:JSONEncode(audit)
