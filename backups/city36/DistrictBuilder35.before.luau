-- Edit-only staged authoring. Nothing here is required by runtime Bootstrap.
local P=require(script.Parent.Plan)
local B={}
local SS=game:GetService("ServerStorage")
local cream=Color3.fromRGB(226,215,191)local slate=Color3.fromRGB(48,64,68)
local brass=Color3.fromRGB(182,144,79)local teal=Color3.fromRGB(42,91,90)
local brick=Color3.fromRGB(140,79,59)local glass=Color3.fromRGB(108,153,163)
local function context()
 assert(not game:GetService("RunService"):IsRunning(),"Edit only")
 local map=workspace.PaketKilat.Map
 return map,map.Districts35,map.DepotPad.CFrame,SS.PaketKilat_PreDistrict35
end
local function archive(p,backup)
 p:SetAttribute("OriginalParent35",p.Parent:GetFullName())p.Parent=backup
end
local function part(parent,name,size,cf,color,material,solid)
 local p=Instance.new("Part")p.Name=name p.Size=size p.CFrame=cf
 p.Color=color or cream p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true p.CanCollide=solid==true p.CanTouch=false p.CanQuery=solid==true
 p.CastShadow=solid==true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent return p
end
local function rectHit(x,z,r)return x>r[1]-.0001 and x<r[2]+.0001 and z>r[3]-.0001 and z<r[4]+.0001 end
local function expanded(r,n)return {r[1]-n,r[2]+n,r[3]-n,r[4]+n}end
local function unique(t)
 table.sort(t)local out={}
 for _,v in t do if #out==0 or v-out[#out]>.001 then table.insert(out,v)end end return out
end
local function sign(board,title,subtitle,face)
 local g=Instance.new("SurfaceGui")g.Face=face or Enum.NormalId.Front g.PixelsPerStud=30
 g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.MaxDistance=115 g.ZOffset=.08 g.Parent=board
 local l=Instance.new("TextLabel")l.BackgroundTransparency=1 l.Size=UDim2.fromScale(.96,subtitle and .62 or .9)
 l.Position=UDim2.fromScale(.02,.04)l.Font=Enum.Font.GothamBold l.TextScaled=true l.TextColor3=cream l.Text=title l.Parent=g
 if subtitle then local s=l:Clone()s.Position=UDim2.fromScale(.03,.68)s.Size=UDim2.fromScale(.94,.26)s.Text=subtitle s.Font=Enum.Font.GothamMedium s.Parent=g end
end
local function finish(m,parent)m.Parent=parent task.wait()end
local function floorStyle(mode,district)
 if mode=="Road"then return Color3.fromRGB(65,72,76),Enum.Material.Asphalt end
 if mode=="Grass"then return Color3.fromRGB(91,132,89),Enum.Material.Grass end
 if mode=="Walk"then return Color3.fromRGB(185,180,164),Enum.Material.Pavement end
 return district=="BrickQuay"and Color3.fromRGB(151,149,139)or Color3.fromRGB(175,178,165),Enum.Material.Pavement
end
function B.Setup()
 local map=workspace.PaketKilat.Map assert(not map:FindFirstChild("Districts35"),"District35 already exists")
 local backup=Instance.new("Folder")backup.Name="PaketKilat_PreDistrict35"backup.Parent=SS
 local objects=Instance.new("Folder")objects.Name="Objects"objects.Parent=backup
 local snapshot={anchors={},attributes=workspace.PaketKilat:GetAttributes()}
 for _,v in map:GetDescendants()do
  if v:IsA("BasePart")and(v.Name=="PickupPoint"or v.Name=="DestinationPoint"or v.Name=="RecoveryPoint"or v.Name=="PrototypeSpawn"or v:IsDescendantOf(map.City13.Stations)or v:IsDescendantOf(map.RestStops27))then
   table.insert(snapshot.anchors,{path=v:GetFullName(),cf={v.CFrame:GetComponents()},size={v.Size.X,v.Size.Y,v.Size.Z}})
  end
 end
 local s=Instance.new("StringValue")s.Name="Snapshot"s.Value=game.HttpService:JSONEncode(snapshot)s.Parent=backup
 local root=Instance.new("Folder")root.Name="Districts35"root.Parent=map
 for _,name in {"Surface35","CivicCentre","BrickQuay","RoadBridge","StreetDetails","FutureAddresses","NavigationNodes"}do local f=Instance.new("Folder")f.Name=name f.Parent=root end
 root:SetAttribute("DistrictRevision","TwinDistricts35")
 -- Preserve exact originals, then replace unsupported earth overhangs with continuous foundations.
 local main=map.Ground14.ContinuousEarth local second=workspace.ContinuousEarth
 for _,old in {main,second}do
  local parent=old.Parent local q=old:Clone()q:ClearAllChildren()
  archive(old,objects)q.Parent=parent
  local b=map.DepotPad.CFrame
  if parent==workspace then q.Size=Vector3.new(282,12.5,212)q.CFrame=b*CFrame.new(-304,-5.75,200)
  else q.Size=Vector3.new(283,12.5,334)q.CFrame=b*CFrame.new(3.5,-5.75,143)end
  q:SetAttribute("Foundation35",true)
 end
 local covers={}
 for _,p in map.Surface15:GetChildren()do if p:IsA("BasePart")and p.Material==Enum.Material.Grass and p.Size.X>250 and p.Size.Z>150 then table.insert(covers,p)end end
 assert(#covers==1,"Ambiguous civic grass cover")
 archive(covers[1],objects)archive(workspace.Grass,objects)
 return {anchors=#snapshot.anchors,originals=#objects:GetChildren()}
end
local function clip(poly,nx,nz,k,le)
 local out={}
 for i,a in poly do
  local c=poly[i%#poly+1]
  local da=nx*a.X+nz*a.Y-k local dc=nx*c.X+nz*c.Y-k
  local ina=le and da<=.000001 or not le and da>=-.000001
  local inc=le and dc<=.000001 or not le and dc>=-.000001
  if ina then table.insert(out,a)end
  if ina~=inc then local t=da/(da-dc)table.insert(out,a+(c-a)*t)end
 end
 return out
end
local function polygonArea(poly)
 local a=0 for i,p in poly do local q=poly[i%#poly+1]a+=p.X*q.Y-q.X*p.Y end return math.abs(a)/2
end
local function triangle(parent,a,b,c,basis,color,mat)
 local A=Vector3.new(a.X,.75,a.Y)local C=Vector3.new(c.X,.75,c.Y)local D=Vector3.new(b.X,.75,b.Y)
 local ab,ac,bc=D-A,C-A,C-D
 if ab:Dot(ab)>ac:Dot(ac)and ab:Dot(ab)>bc:Dot(bc)then C,A=A,C
 elseif ac:Dot(ac)>ab:Dot(ab)and ac:Dot(ac)>bc:Dot(bc)then A,D=D,A end
 ab,ac,bc=D-A,C-A,C-D
 if ac:Cross(ab).Magnitude<.00001 then return end
 local right=ac:Cross(ab).Unit local up=bc:Cross(right).Unit local back=bc.Unit
 local height=math.abs(ab:Dot(up))
 for _,s in {{(A+D)/2,right,up,back,math.abs(ab:Dot(back))},{(A+C)/2,-right,up,-back,math.abs(ac:Dot(back))}}do
  if s[5]>.001 and height>.001 then
   local w=Instance.new("WedgePart")w.Name="DiagonalSurface35"w.Size=Vector3.new(.5,height,s[5])
   w.CFrame=basis*CFrame.fromMatrix(s[1],s[2],s[3],s[4])w.Material=mat w.Color=color
   w.Anchored=true w.CanCollide=true w.CanTouch=false w.CanQuery=true w.CastShadow=false w:SetAttribute("Floor35",true)w.Parent=parent
  end
 end
end
local function polygon(parent,poly,basis,mode,district)
 if #poly<3 or polygonArea(poly)<.002 then return end
 local color,mat=floorStyle(mode,district)
 local xmin,xmax,zmin,zmax=math.huge,-math.huge,math.huge,-math.huge
 for _,v in poly do xmin=math.min(xmin,v.X)xmax=math.max(xmax,v.X)zmin=math.min(zmin,v.Y)zmax=math.max(zmax,v.Y)end
 if math.abs(polygonArea(poly)-(xmax-xmin)*(zmax-zmin))<.005 then
  local p=part(parent,mode.."35",Vector3.new(xmax-xmin,.5,zmax-zmin),basis*CFrame.new((xmin+xmax)/2,.75,(zmin+zmax)/2),color,mat,true)
  p.CastShadow=false p:SetAttribute("Floor35",true)
 else for i=2,#poly-1 do triangle(parent,poly[1],poly[i],poly[i+1],basis,color,mat)end end
end
local function classify(x,z,roads,district)
 if rectHit(x,z,P.BridgeRoad)then return "Road"end
 for _,r in roads do if rectHit(x,z,r)then return "Road"end end
 if rectHit(x,z,P.BridgeWalk)then return "Walk"end
 for _,r in roads do if rectHit(x,z,expanded(r,4))then return "Walk"end end
 if district=="CivicCentre"then
  if rectHit(x,z,P.Park)and not(math.abs(x)<4 or math.abs(z-232)<3 or rectHit(x,z,{-20,6,219,245}))then return "Grass"end
  if x< -130 or x>137 or z>302 then return "Grass"end
 else if x< -436 or x> -172 or z<101 or z>299 then return "Grass"end end
 return "Paving"
end
function B.Surface(district)
 local map,root,basis=context()local bounds=P[district=="CivicCentre"and "Main"or "Quay"]
 local roads=district=="CivicCentre"and P.CivicRoads or P.QuayRoads
 local xs,zs={bounds.x1,bounds.x2},{bounds.z1,bounds.z2}
 local function add(r)
  for _,x in {r[1],r[2]}do if x>bounds.x1 and x<bounds.x2 then table.insert(xs,x)end end
  for _,z in {r[3],r[4]}do if z>bounds.z1 and z<bounds.z2 then table.insert(zs,z)end end
 end
 for _,r in roads do add(r)add(expanded(r,4))end
 add(P.BridgeRoad)add(P.BridgeWalk)
 if district=="CivicCentre"then add(P.Park)add({-20,6,219,245})add({-4,4,151,310})add({-138,145,229,235})add({-130,137,151,302})
 else add({-436,-172,101,299})end
 xs,zs=unique(xs),unique(zs)
 local floor=Instance.new("Folder")floor.Name=district floor.Parent=root.Surface35
 local diagonal=P.Diagonal local normal=Vector2.new(-(diagonal.b-diagonal.a).Y,(diagonal.b-diagonal.a).X).Unit
 local k=normal:Dot(diagonal.a)
 local sum=0 local flushes=0 local batch=Instance.new("Folder")batch.Name="Tiles1"
 local function flush()
  if #batch:GetChildren()>0 then batch.Parent=floor flushes+=1 task.wait()batch=Instance.new("Folder")batch.Name="Tiles"..(flushes+1)end
 end
 for i=1,#xs-1 do for j=1,#zs-1 do
  local x1,x2,z1,z2=xs[i],xs[i+1],zs[j],zs[j+1]
  local poly={Vector2.new(x1,z1),Vector2.new(x2,z1),Vector2.new(x2,z2),Vector2.new(x1,z2)}
  local mode=classify((x1+x2)/2,(z1+z2)/2,roads,district)
  if district=="BrickQuay"and mode~="Road"then
   local direction=(diagonal.b-diagonal.a).Unit
   local t0=direction:Dot(diagonal.a)local t1=direction:Dot(diagonal.b)
   local before=clip(poly,direction.X,direction.Y,t0,true)
   local after=clip(poly,direction.X,direction.Y,t1,false)
   for _,outside in {before,after}do if #outside>=3 then sum+=polygonArea(outside)polygon(batch,outside,basis,mode,district)end end
   local middle=clip(poly,direction.X,direction.Y,t0,false)
   if #middle>=3 then middle=clip(middle,direction.X,direction.Y,t1,true)end
   for _,band in {{-math.huge,-13,nil},{-13,-9,"Walk"},{-9,9,"Road"},{9,13,"Walk"},{13,math.huge,nil}}do
    local p=middle if #p>=3 and band[1]>-math.huge then p=clip(p,normal.X,normal.Y,k+band[1],false)end
    if #p>=3 and band[2]<math.huge then p=clip(p,normal.X,normal.Y,k+band[2],true)end
    if #p>=3 then sum+=polygonArea(p)polygon(batch,p,basis,band[3]or mode,district)end
   end
  else sum+=(x2-x1)*(z2-z1)polygon(batch,poly,basis,mode,district)end
  if #batch:GetChildren()>=80 then flush()end
 end end
 flush()floor:SetAttribute("CoverageArea",sum)
 return {district=district,area=sum,expected=(bounds.x2-bounds.x1)*(bounds.z2-bounds.z1),batches=flushes}
end
function B.Approaches()
 local map,root,basis,backup=context()
 local cut={-138,-124,131,151}
 local count=0
 for _,old in map.Surface15:GetChildren()do
  if not old:IsA("BasePart")then continue end
  local c=basis:PointToObjectSpace(old.Position)
  local r={c.X-old.Size.X/2,c.X+old.Size.X/2,c.Z-old.Size.Z/2,c.Z+old.Size.Z/2}
  if math.min(r[2],cut[2])-math.max(r[1],cut[1])<.005 or math.min(r[4],cut[4])-math.max(r[3],cut[3])<.005 then continue end
  local xs,zs={r[1],r[2]},{r[3],r[4]}
  for _,x in {cut[1],cut[2]}do if x>r[1]and x<r[2]then table.insert(xs,x)end end
  for _,z in {cut[3],cut[4]}do if z>r[3]and z<r[4]then table.insert(zs,z)end end
  xs,zs=unique(xs),unique(zs)
  local g=Instance.new("Folder")g.Name="OldTownApproach"..count
  for i=1,#xs-1 do for j=1,#zs-1 do
   local x,z=(xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2
   if rectHit(x,z,cut)then
    polygon(g,{Vector2.new(xs[i],zs[j]),Vector2.new(xs[i+1],zs[j]),Vector2.new(xs[i+1],zs[j+1]),Vector2.new(xs[i],zs[j+1])},basis,z>=135 and "Road"or "Walk","CivicCentre")
   else local p=old:Clone()p.Size=Vector3.new(xs[i+1]-xs[i],old.Size.Y,zs[j+1]-zs[j])p.CFrame=basis*CFrame.new(x,c.Y,z)p:SetAttribute("Floor35",true)p.Parent=g end
  end end
  archive(old,backup.Objects)finish(g,root.Surface35)count+=1
 end
 -- The old canal parapet now faces city land; replace it with a low curb with real openings.
 local retired=0
 for _,p in map.Polish05:GetChildren()do
  if p:IsA("BasePart")then local v=basis:PointToObjectSpace(p.Position)
   if math.abs(v.Z-151)<.2 and(p.Name=="CanalParapet"or p.Name=="ParapetCap"or p.Name=="ParapetPost")then archive(p,backup.Objects)retired+=1 end
  end
 end
 local edges={{-122,-105},{-79,-5},{5,63},{89,139}}
 for i,r in edges do part(root.StreetDetails,"OldTownCurb"..i,Vector3.new(r[2]-r[1],.18,.35),basis*CFrame.new((r[1]+r[2])/2,1.09,151),cream)end
 return {floorTilesRetired=count,parapetPiecesRetired=retired}
end
local function address(root,cf,id,name,district)
 local p=part(root.FutureAddresses,id,Vector3.new(3,.1,3),cf,teal)
 p.Transparency=1 p:SetAttribute("AddressId35",id)p:SetAttribute("DisplayName",name)p:SetAttribute("District",district)p:SetAttribute("CandidateOnly",true)
 game.CollectionService:AddTag(p,"FutureDelivery35")
end
local function localPiece(m,cf,n,size,x,y,z,col,mat,solid)
 return part(m,n,size,cf*CFrame.new(x,y,z),col,mat,solid)
end
local function shop(root,basis,id,name,x,z,index)
 local m=Instance.new("Model")m.Name=id.."_"..name
 local cf=basis*CFrame.new(x,0,z)local w,d=21,22 local h=26+(index%3)*4
 local color=({Color3.fromRGB(143,75,56),Color3.fromRGB(171,102,71),Color3.fromRGB(132,83,69),Color3.fromRGB(189,153,111)})[index%4+1]
 local accent=({teal,slate,Color3.fromRGB(113,83,52),Color3.fromRGB(86,108,86)})[index%4+1]
 localPiece(m,cf,"BrickBody",Vector3.new(w,h,d),0,1+h/2,0,color,Enum.Material.Brick,true)
 localPiece(m,cf,"StoneBase",Vector3.new(w+.25,.5,d+.25),0,1.25,0,cream,Enum.Material.Concrete)
 for _,y in {8.3,h+1}do localPiece(m,cf,"StoneCornice",Vector3.new(w+.6,.35,d+.6),0,y,0,cream)end
 localPiece(m,cf,"SlateRoof",Vector3.new(w+1,.35,d+1),0,h+1.38,0,slate,Enum.Material.Slate,true)
 localPiece(m,cf,"Parapet",Vector3.new(w+1,1,.35),0,h+2,-d/2-.2,color,Enum.Material.Brick)
 for y=12,h-1,7 do
  for _,dx in {-6.3,0,6.3}do
   localPiece(m,cf,"WindowSurround",Vector3.new(3.6,4.2,.17),dx,y,-d/2-.14,cream)
   localPiece(m,cf,"TallWindow",Vector3.new(3.05,3.65,.12),dx,y,-d/2-.28,glass)
   localPiece(m,cf,"WindowMullion",Vector3.new(.1,3.65,.08),dx,y,-d/2-.36,cream)
  end
  for _,dx in {-5.5,5.5}do localPiece(m,cf,"RearWindow",Vector3.new(3,3.8,.15),dx,y,d/2+.12,glass)end
 end
 localPiece(m,cf,"ShopDoorFrame",Vector3.new(3.8,5.8,.2),-6,3.9,-d/2-.15,cream)
 localPiece(m,cf,"ShopDoorGlass",Vector3.new(3.2,5.2,.12),-6,3.9,-d/2-.3,accent)
 for _,dx in {0,6.2}do
  localPiece(m,cf,"DisplayFrame",Vector3.new(5.4,4.8,.2),dx,4,-d/2-.15,cream)
  localPiece(m,cf,"DisplayWindow",Vector3.new(4.9,4.3,.12),dx,4,-d/2-.3,glass)
 end
 localPiece(m,cf,"DoorHandle",Vector3.new(.1,.8,.1),-4.9,3.8,-d/2-.42,brass,Enum.Material.Metal)
 localPiece(m,cf,"Canopy",Vector3.new(w-1,.25,2.6),0,7.2,-d/2-1.2,accent)
 local board=localPiece(m,cf,"ShopSign",Vector3.new(w-1,1.35,.28),0,8.1,-d/2-.35,accent)
 sign(board,string.upper(name),id.." · BATA QUAY")
 localPiece(m,cf,"Downpipe",Vector3.new(.15,h,.15),w/2-.45,1+h/2,-d/2-.2,slate)
 if index%3==0 then
  for _,dx in {-4.7,4.7}do localPiece(m,cf,"BalconyPost",Vector3.new(.13,1.5,.13),dx,10.4,-d/2-1,slate)end
  localPiece(m,cf,"BalconyRail",Vector3.new(9.5,.13,.13),0,11.1,-d/2-1,slate)
  localPiece(m,cf,"BalconyLedge",Vector3.new(10,.18,1.2),0,9.6,-d/2-.6,cream)
 end
 m:SetAttribute("AddressId35",id)m:SetAttribute("District","BrickQuay")
 finish(m,root.BrickQuay)
 address(root,cf*CFrame.new(-6,1,-d/2-2.8),id,name,"BrickQuay")
end
local function lotClear(x,z,w,d)
 local hx,hz=w/2+1,d/2+2.8
 for _,r in P.QuayRoads do
  local q=expanded(r,4)
  if x+hx>q[1]and x-hx<q[2]and z+hz>q[3]and z-hz<q[4]then return false end
 end
 local direction=P.Diagonal.b-P.Diagonal.a
 local normal=Vector2.new(-direction.Y,direction.X).Unit
 local distance=normal:Dot(Vector2.new(x,z)-P.Diagonal.a)
 local extent=math.abs(normal.X)*hx+math.abs(normal.Y)*hz
 return math.abs(distance)>13+extent
end
function B.Shops()
 local map,root,basis=context()assert(#root.BrickQuay:GetChildren()==0,"Shops already built")
 local count=0 local skipped={}
 for _,z in {142.5,200,257.5}do for i=0,8 do
  local x=-397+i*22.4
  if lotClear(x,z,21,22)then count+=1;shop(root,basis,string.format("BQ%02d",count),P.Shops[count]or("Ruko "..count),x,z,count)
  else table.insert(skipped,{x=x,z=z})end
 end end
 root:SetAttribute("ShopCount",count)
 return {shops=count,rejectedForStreet=#skipped}
end
function B.Offices()
 local map,root,basis=context()
 for index,s in P.Offices do
  local id,name,x,z,w,d,h,yaw=table.unpack(s)
  local m=Instance.new("Model")m.Name=id.."_"..name local cf=basis*CFrame.new(x,0,z)*CFrame.Angles(0,math.rad(yaw),0)
  localPiece(m,cf,"OfficeBody",Vector3.new(w,h,d),0,1+h/2,0,index%2==0 and cream or Color3.fromRGB(177,185,176),Enum.Material.Concrete,true)
  localPiece(m,cf,"BrickPodium",Vector3.new(w+.3,7,d+.3),0,4.5,0,brick,Enum.Material.Brick)
  for y=12,h-2,7 do
   localPiece(m,cf,"FrontWindowBand",Vector3.new(w-3,3.8,.18),0,y,-d/2-.12,glass)
   localPiece(m,cf,"RearWindowBand",Vector3.new(w-3,3.8,.18),0,y,d/2+.12,glass)
   for _,side in {-1,1}do localPiece(m,cf,"SideWindowBand",Vector3.new(.18,3.8,d-3),side*(w/2+.12),y,0,glass)end
  end
  for _,dx in {-w*.28,0,w*.28}do localPiece(m,cf,"FacadeFin",Vector3.new(.3,h-7,.38),dx,(h+9)/2,-d/2-.26,cream)end
  localPiece(m,cf,"OfficeRoof",Vector3.new(w+1,.6,d+1),0,h+1.3,0,slate,Enum.Material.Slate,true)
  localPiece(m,cf,"RoofPlant",Vector3.new(5,2.4,4),w*.25,h+2.8,0,teal)
  localPiece(m,cf,"LobbyDoor",Vector3.new(5,6,.25),0,4,-d/2-.25,slate)
  localPiece(m,cf,"DoorMullion",Vector3.new(.13,6,.1),0,4,-d/2-.43,cream)
  localPiece(m,cf,"LobbyCanopy",Vector3.new(12,.3,4),0,7.8,-d/2-1.7,slate)
  local board=localPiece(m,cf,"OfficeSign",Vector3.new(w-1,1.6,.25),0,9,-d/2-.35,teal)
  sign(board,string.upper(name),id.." · PUSAT KOTA")
  m:SetAttribute("AddressId35",id)m:SetAttribute("District","CivicCentre")finish(m,root.CivicCentre)
  address(root,cf*CFrame.new(0,1,-d/2-3),id,name,"CivicCentre")
 end
 return {offices=#P.Offices}
end
local function span(parent,name,a,b,width,depth,basis,color,mat,solid)
 local A=basis:PointToWorldSpace(a)local C=basis:PointToWorldSpace(b)
 return part(parent,name,Vector3.new(width,depth,(C-A).Magnitude),CFrame.lookAt((A+C)/2,C),color,mat,solid)
end
function B.Bridge()
 local map,root,basis=context()
 local g=Instance.new("Model")g.Name="CanalRoadBridge"
 part(g,"Carriageway",Vector3.new(25,.5,18),basis*CFrame.new(-150.5,.75,144),Color3.fromRGB(65,72,76),Enum.Material.Asphalt,true)
 for _,z in {133,155}do
  part(g,"PedestrianDeck",Vector3.new(25,.5,4),basis*CFrame.new(-150.5,.75,z),cream,Enum.Material.Pavement,true)
  part(g,"StoneFascia",Vector3.new(25,1.6,1),basis*CFrame.new(-150.5,-.3,z+(z<144 and -1.6 or 1.6)),brick,Enum.Material.Brick)
 end
 for _,x in {-138.5,-162.5}do
  part(g,"ShoreAbutment",Vector3.new(2,8,26),basis*CFrame.new(x,-3.5,144),brick,Enum.Material.Brick,true)
 end
 for _,z in {131,157}do
  for i=0,8 do local x=-163+25*i/8 part(g,"IronRailPost",Vector3.new(.18,2.6,.18),basis*CFrame.new(x,2.3,z),slate,Enum.Material.Metal,true)end
  for _,y in {1.65,3.55}do part(g,"IronHandrail",Vector3.new(25,.12,.12),basis*CFrame.new(-150.5,y,z),slate,Enum.Material.Metal,true)end
  for i=0,7 do
   local u1=-1+i/4 local u2=-1+(i+1)/4
   span(g,"CanalArch",Vector3.new(-150.5+12.5*u1,-7.2+6.2*(1-u1*u1),z),Vector3.new(-150.5+12.5*u2,-7.2+6.2*(1-u2*u2),z),1,.8,basis,slate,Enum.Material.Metal)
  end
 end
 for _,x in {-161,-155,-149,-143}do part(g,"BridgeCentreDash",Vector3.new(3,.035,.15),basis*CFrame.new(x,1.025,144),cream)end
 finish(g,root.RoadBridge)
 local nodes={{"OldTown",-124,144},{"BridgeEast",-138,144},{"BridgeWest",-163,144},{"QuayEntry",-185,144}}
 for _,s in nodes do
  local n=part(root.NavigationNodes,s[1],Vector3.new(.1,.1,.1),basis*CFrame.new(s[2],1,s[3]),teal)n.Transparency=1
 end
 return {waterSpan=25,totalRoadConnection=62}
end

-- Merge neighbouring native floor cells; diagonal wedge polygons retain their exact boundaries.
function B.Coalesce(district)
 local _,root,basis=context()local f=root.Surface35[district]local rects={}local originals={}
 local function q(n)return math.round(n*1000)/1000 end
 local area=0
 for _,p in f:GetDescendants()do if p:IsA("Part")and p:GetAttribute("Floor35")then
  local v=basis:PointToObjectSpace(p.Position)local a={x1=q(v.X-p.Size.X/2),x2=q(v.X+p.Size.X/2),z1=q(v.Z-p.Size.Z/2),z2=q(v.Z+p.Size.Z/2),mode=string.gsub(p.Name,"35","")}
  area+=(a.x2-a.x1)*(a.z2-a.z1)table.insert(rects,a)table.insert(originals,p)
 end end
 local function merge(axis)
  local groups={}local horizontal=axis=="X"
  for _,a in rects do
   local key=a.mode..":"..tostring(horizontal and a.z1 or a.x1)..":"..tostring(horizontal and a.z2 or a.x2)
   groups[key]=groups[key]or{}table.insert(groups[key],a)
  end
  local out={}
  for _,rows in groups do
   table.sort(rows,function(a,c)return (horizontal and a.x1 or a.z1)<(horizontal and c.x1 or c.z1)end)
   local last
   for _,a in rows do
    if last and math.abs((horizontal and last.x2 or last.z2)-(horizontal and a.x1 or a.z1))<.0001 then
     if horizontal then last.x2=a.x2 else last.z2=a.z2 end
    else last=table.clone(a)table.insert(out,last)end
   end
  end
  rects=out
 end
 for i=1,5 do local n=#rects merge("X")merge("Z")if n==#rects then break end end
 local newArea=0 local batch=Instance.new("Folder")batch.Name="MergedFloor35_1"local chunk=1
 for _,a in rects do
  newArea+=(a.x2-a.x1)*(a.z2-a.z1)
  polygon(batch,{Vector2.new(a.x1,a.z1),Vector2.new(a.x2,a.z1),Vector2.new(a.x2,a.z2),Vector2.new(a.x1,a.z2)},basis,a.mode,district)
  if #batch:GetChildren()>=80 then finish(batch,f)chunk+=1 batch=Instance.new("Folder")batch.Name="MergedFloor35_"..chunk end
 end
 assert(math.abs(newArea-area)<.005,"Floor merge changed area")
 if #batch:GetChildren()>0 then finish(batch,f)end
 for _,p in originals do p:Destroy()end
 for _,g in f:GetChildren()do if #g:GetChildren()==0 then g:Destroy()end end
 return {district=district,before=#originals,after=#rects,area=area,mergedArea=newArea}
end
return B
