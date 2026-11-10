-- Edit-only public realm authoring; reuses vetted free Creator Store library.
local D={}
local SS=game:GetService("ServerStorage")
local P=require(script.Parent.Plan)
local cream=Color3.fromRGB(226,215,191)
local metal=Color3.fromRGB(48,64,68)
local teal=Color3.fromRGB(42,91,90)
local brass=Color3.fromRGB(182,144,79)
local function ctx()
 assert(not game:GetService("RunService"):IsRunning(),"Edit authoring only")
 local map=workspace.PaketKilat.Map return map.Districts35,map.DepotPad.CFrame
end
local function piece(m,n,size,cf,col,mat,solid)
 local p=Instance.new("Part")p.Name=n p.Size=size p.CFrame=cf p.Anchored=true
 p.Color=col or cream p.Material=mat or Enum.Material.Concrete p.CanCollide=solid==true
 p.CanTouch=false p.CanQuery=solid==true p.CastShadow=solid==true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=m return p
end
local function label(p,t,small)
 local g=Instance.new("SurfaceGui")g.Face=Enum.NormalId.Front g.PixelsPerStud=35 g.MaxDistance=110 g.ZOffset=.05 g.Parent=p
 local l=Instance.new("TextLabel")l.Size=UDim2.fromScale(.94,small and .58 or .88)l.Position=UDim2.fromScale(.03,.05)
 l.BackgroundTransparency=1 l.Text=t l.Font=Enum.Font.GothamBold l.TextColor3=cream l.TextScaled=true l.Parent=g
 if small then local c=l:Clone()c.Size=UDim2.fromScale(.94,.26)c.Position=UDim2.fromScale(.03,.68)c.Text=small c.Font=Enum.Font.Gotham c.Parent=g end
end
local function finish(m,p)m.Parent=p task.wait()end
local function asset(parent,b,lib,key,id,x,z,h,yaw)
 local src=SS:FindFirstChild("PaketKilat_CreatorAssets"..lib):FindFirstChild(key)
 local m=src:Clone()m.Name=id
 for _,q in m:GetDescendants()do
  if q:IsA("LuaSourceContainer")or q:IsA("Light")or q:IsA("Constraint")or q:IsA("JointInstance")or q:IsA("Sound")then q:Destroy()
  elseif q:IsA("BasePart")then q.Anchored=true q.CanCollide=false q.CanTouch=false q.CanQuery=true end
 end
 local _,size=m:GetBoundingBox()m:ScaleTo(m:GetScale()*h/size.Y)
 local box,sz=m:GetBoundingBox()local target=b*CFrame.new(x,1+sz.Y/2,z)*CFrame.Angles(0,math.rad(yaw or 0),0)
 m:PivotTo(target*CFrame.new(-box.Position)*m:GetPivot())
 finish(m,parent)
 -- Check each mesh foot locally; broad whole-model grids miss narrow tree trunks.
 local support=b.Position.Y+1 local low=math.huge
 for _,p in m:GetDescendants()do if p:IsA("BasePart")then
  local minX,maxX,minY,minZ,maxZ=math.huge,-math.huge,math.huge,math.huge,-math.huge
  for _,i in {-1,1}do for _,j in {-1,1}do for _,k in {-1,1}do
   local v=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(i,j,k)/2)
   minX=math.min(minX,v.X)maxX=math.max(maxX,v.X)minY=math.min(minY,v.Y)minZ=math.min(minZ,v.Z)maxZ=math.max(maxZ,v.Z)
  end end end
  if minY<support+.15 then
   local q=RaycastParams.new()q.FilterType=Enum.RaycastFilterType.Include q.FilterDescendantsInstances={p}
   for i=0,16 do for j=0,16 do
    local hit=workspace:Raycast(Vector3.new(minX+(maxX-minX)*i/16,support-.05,minZ+(maxZ-minZ)*j/16),Vector3.new(0,3,0),q)
    if hit then low=math.min(low,hit.Position.Y)end
   end end
  end
 end end
 local gap=low<math.huge and low-support or -999
 m:SetAttribute("SupportY35",b.Position.Y+1)m:SetAttribute("MeshFootGap35",gap)m:SetAttribute("PublicRealm35",true)
 for _,q in m:GetDescendants()do if q:IsA("BasePart")then q.CanQuery=false end end
 return m
end
local function planter(parent,b,n,x,z,yaw)
 local m=Instance.new("Model")m.Name=n local cf=b*CFrame.new(x,0,z)*CFrame.Angles(0,math.rad(yaw or 0),0)
 piece(m,"BrickPlanter",Vector3.new(5,1.2,3),cf*CFrame.new(0,1.6,0),Color3.fromRGB(139,82,62),Enum.Material.Brick,true)
 piece(m,"Soil",Vector3.new(4.6,.08,2.6),cf*CFrame.new(0,2.24,0),Color3.fromRGB(77,66,49),Enum.Material.Ground)
 finish(m,parent)
 local bush=asset(parent,b,"09","GardenBush",n.."_Plant",x,z,2.7,yaw)
 bush:PivotTo(bush:GetPivot()+Vector3.new(0,1.25,0))bush:SetAttribute("SupportY35",b.Position.Y+2.25)
end
function D.Park()
 local r,b=ctx()assert(not r.StreetDetails:FindFirstChild("CentralPark35"),"Park already authored")
 local f=Instance.new("Folder")f.Name="CentralPark35"f.Parent=r.StreetDetails
 asset(f,b,"23","Fountain","CivicFountain",-9,232,10.5,0)
 for i,v in {{-52,211},{38,211},{-52,255},{38,255},{-30,258},{16,258}}do asset(f,b,"07","BroadleafTree","ParkTree"..i,v[1],v[2],17+i%3,30*i)end
 for i,v in {{-25,232,90},{11,232,-90},{-17,249,180},{16,249,180},{-17,214,0},{16,214,0}}do asset(f,b,"07","ParkBench","CivicBench"..i,v[1],v[2],3.1,v[3])end
 for i,v in {{-52,220},{-52,244},{38,220},{38,244}}do asset(f,b,"09","GardenBush","ParkShrub"..i,v[1],v[2],2.5,0)end
 for i,v in {{-10,207},{10,262}}do asset(f,b,"09","StreetLamp","GardenLantern"..i,v[1],v[2],9,90)end
 local m=Instance.new("Model")m.Name="ParkEntrance"
 for _,x in {-10,10}do piece(m,"SignPost",Vector3.new(.25,4,.25),b*CFrame.new(x,3,199),metal,Enum.Material.Metal)end
 local p=piece(m,"ParkName",Vector3.new(20,1.6,.25),b*CFrame.new(0,4.2,199),teal)label(p,"TAMAN KOTA","CIVIC GARDENS")
 finish(m,f)
 return #f:GetChildren()
end
local function inside(v,r,extra)return v.X>r[1]-extra and v.X<r[2]+extra and v.Y>r[3]-extra and v.Y<r[4]+extra end
local function nearDiagonal(v,width)
 local a,c=P.Diagonal.a,P.Diagonal.b local d=c-a local t=(v-a):Dot(d)/d:Dot(d)
 return t>=0 and t<=1 and(v-(a+d*t)).Magnitude<width
end
local function roadPoint(v,district,except)
 local roads=district=="CivicCentre"and P.CivicRoads or P.QuayRoads
 for i,road in roads do if i~=except and inside(v,road,.2)then return true end end
 if inside(v,P.BridgeRoad,.2)then return true end
 return district=="BrickQuay"and nearDiagonal(v,10)
end
function D.Markings()
 local r,b=ctx()assert(not r.StreetDetails:FindFirstChild("RoadMarkings35"))
 local f=Instance.new("Folder")f.Name="RoadMarkings35"f.Parent=r.StreetDetails
 local count=0 local batch=Instance.new("Folder")batch.Name="Paint1"
 local function paint(name,x,z,w,d,angle)
  piece(batch,name,Vector3.new(w,.035,d),b*CFrame.new(x,1.03,z)*CFrame.Angles(0,angle or 0,0),Color3.fromRGB(224,219,198),Enum.Material.SmoothPlastic)
  count+=1 if #batch:GetChildren()>=65 then finish(batch,f)batch=Instance.new("Folder")batch.Name="Paint"..count end
 end
 for _,district in {"CivicCentre","BrickQuay"}do
  local roads=district=="CivicCentre"and P.CivicRoads or P.QuayRoads
  for i,a in roads do
   local alongX=a[2]-a[1]>a[4]-a[3]local start=alongX and a[1]or a[3]local stop=alongX and a[2]or a[4]
   for t=start+5,stop-4,10 do
    local x=alongX and t or(a[1]+a[2])/2 local z=alongX and(a[3]+a[4])/2 or t
    if not roadPoint(Vector2.new(x,z),district,i)then paint("CentreDash",x,z,alongX and 4 or .18,alongX and .18 or 4)end
   end
  end
 end
 local a,c=P.Diagonal.a,P.Diagonal.b local d=(c-a).Unit
 local angle=math.atan2(-d.Y,d.X)
 for t=8,(c-a).Magnitude-8,10 do
  local v=a+d*t local skip=false
  for _,road in P.QuayRoads do if inside(v,road,3)then skip=true end end
  if not skip then paint("DiagonalDash",v.X,v.Y,4,.18,angle)end
 end
 -- Pedestrian crossings sit before intersections; sidewalks remain clear.
 for _,v in {{-92,167,false},{76,167,false},{-92,260,false},{76,260,false},{-403,114,true},{-403,171,true},{-205,229,true},{-205,286,true}}do
  for j=-3,3 do paint("ZebraCrossing",v[1]+(v[3]and 0 or j*2),v[2]+(v[3]and j*2 or 0),v[3]and 3.6 or .9,v[3]and .9 or 3.6)end
 end
 if #batch:GetChildren()>0 then finish(batch,f)end
 return count
end
function D.Furniture()
 local r,b=ctx()assert(not r.StreetDetails:FindFirstChild("Furniture35"))
 local f=Instance.new("Folder")f.Name="Furniture35"f.Parent=r.StreetDetails
 local trees={{-133,172},{-133,198},{-133,267},{-109,301},{-45,301},{20,301},{96,301},{140,174},{140,202},{140,268},{-440,130},{-440,194},{-440,255},{-168,120},{-168,197},{-168,265}}
 for i,v in trees do asset(f,b,"07","BroadleafTree","AvenueTree"..i,v[1],v[2],13+i%3,23*i)end
 local lamps={{-104,186,180},{-104,251,180},{88,185,0},{88,257,0},{-47,294,90},{47,294,90},{-435,147,180},{-435,207,180},{-435,266,180},{-173,145,0},{-173,207,0},{-173,266,0},{-333,102,90},{-264,102,90},{-333,298,-90},{-264,298,-90}}
 for i,v in lamps do asset(f,b,"09","StreetLamp","StreetLamp"..i,v[1],v[2],10,v[3])end
 for i,v in {{-413,97,180},{-187,302,0},{-420,302,0},{-190,97,180}}do asset(f,b,"07","ParkBench","QuayBench"..i,v[1],v[2],3,v[3])end
 for i,v in {{-109,161},{94,161},{-435,112},{-168,286}}do planter(f,b,"Planter"..i,v[1],v[2],90)end
 -- Bus shelter placed outside office entrances and the walking corridor.
 local m=Instance.new("Model")m.Name="CivicBusShelter"local c=b*CFrame.new(98,0,192)
 for _,x in {-6,6}do for _,z in {-2,2}do piece(m,"SteelColumn",Vector3.new(.22,7,.22),c*CFrame.new(x,4.5,z),metal,Enum.Material.Metal,true)end end
 piece(m,"ShelterRoof",Vector3.new(13,.35,5.8),c*CFrame.new(0,8.15,0),metal,Enum.Material.Metal)
 local panel=piece(m,"ShelterName",Vector3.new(12,1,.18),c*CFrame.new(0,7.3,-2.1),teal)label(panel,"CIVIC GARDENS","HALTE PUSAT KOTA")
 finish(m,f)
 asset(f,b,"07","ParkBench","ShelterBench",98,192,2.8,0)
 for i,v in {{-109,168,"PUSAT KOTA","CIVIC CENTRE"},{-203,155,"BATA QUAY","RUKO / TEPI KANAL"}}do
  local g=Instance.new("Model")g.Name="DistrictSign"..i
  for _,x in {-5,5}do piece(g,"Post",Vector3.new(.2,4.7,.2),b*CFrame.new(v[1]+x,3.35,v[2]),metal,Enum.Material.Metal)end
  local p=piece(g,"DistrictName",Vector3.new(11,2.5,.25),b*CFrame.new(v[1],4.2,v[2]),teal)label(p,v[3],v[4])finish(g,f)
 end
 return #f:GetChildren()
end
function D.Quays()
 local r,b=ctx()assert(not r.StreetDetails:FindFirstChild("QuayEdges35"))
 local f=Instance.new("Folder")f.Name="QuayEdges35"f.Parent=r.StreetDetails
 local edges={{-445,94,-445,306},{-445,94,-163,94},{-445,306,-163,306},{-163,94,-163,131},{-163,157,-163,306},{-138,160,-138,310},{145,151,145,310},{-138,310,145,310}}
 for i,v in edges do
  local a=Vector3.new(v[1],0,v[2])local c=Vector3.new(v[3],0,v[4])local len=(c-a).Magnitude
  local mid=(a+c)/2 local cf=b*CFrame.lookAt(mid,mid+(c-a))
  local m=Instance.new("Model")m.Name="QuayEdge"..i
  piece(m,"RetainingBrick",Vector3.new(.65,6,len),cf*CFrame.new(0,-2.5,0),Color3.fromRGB(124,88,71),Enum.Material.Brick,true)
  piece(m,"StoneCap",Vector3.new(.85,.22,len),cf*CFrame.new(0,1.11,0),cream)
  for z=-len/2+.8,len/2-.5,18 do piece(m,"GuardPost",Vector3.new(.22,2.25,.22),cf*CFrame.new(0,2.13,z),metal,Enum.Material.Metal,true)end
  for _,y in {1.7,2.8}do piece(m,"GuardRail",Vector3.new(.16,.16,len),cf*CFrame.new(0,y,0),metal,Enum.Material.Metal,true)end
  finish(m,f)
 end
 return #edges
end
function D.Metadata()
 local r,b=ctx()
 r:SetAttribute("CandidateAddressCount",#r.FutureAddresses:GetChildren())
 r:SetAttribute("DeliveryExpansionEnabled",false)
 r:SetAttribute("FutureNote","Map-first; routes and rewards remain the original five destinations")
 local links={
 {"CivicWest",Vector3.new(-92,1,144),"OldTown,CivicWestNorth"},
 {"CivicWestNorth",Vector3.new(-92,1,282),"CivicWest,CivicEastNorth"},
 {"CivicEastNorth",Vector3.new(76,1,282),"CivicWestNorth,CivicEast"},
 {"CivicEast",Vector3.new(76,1,144),"CivicEastNorth,OldTown"},
 {"QuaySouthEast",Vector3.new(-185,1,114),"QuayEntry,QuaySouthWest,QuayNorthWest"},
 {"QuaySouthWest",Vector3.new(-423,1,114),"QuaySouthEast,QuayMidWest"},
 {"QuayMidWest",Vector3.new(-423,1,171),"QuaySouthWest,QuayMidEast,QuayUpperWest"},
 {"QuayMidEast",Vector3.new(-185,1,171),"QuayEntry,QuayMidWest,QuayUpperEast"},
 {"QuayUpperWest",Vector3.new(-423,1,229),"QuayMidWest,QuayUpperEast,QuayNorthWest"},
 {"QuayUpperEast",Vector3.new(-185,1,229),"QuayMidEast,QuayUpperWest,QuayNorthEast"},
 {"QuayNorthWest",Vector3.new(-423,1,286),"QuayUpperWest,QuayNorthEast,QuaySouthEast"},
 {"QuayNorthEast",Vector3.new(-185,1,286),"QuayNorthWest,QuayUpperEast"}
 }
 for _,v in links do
  local p=piece(r.NavigationNodes,v[1],Vector3.new(.3,.1,.3),b*CFrame.new(v[2]),teal)
  p.Transparency=1 p:SetAttribute("Neighbours35",v[3])
 end
 local legacy={OldTown="BridgeEast,CivicWest",BridgeEast="OldTown,BridgeWest",BridgeWest="BridgeEast,QuayEntry",QuayEntry="BridgeWest,QuaySouthEast,QuayMidEast"}
 for n,v in legacy do r.NavigationNodes[n]:SetAttribute("Neighbours35",v)end
 return #r.FutureAddresses:GetChildren()
end

function D.Pockets()
 local r,b=ctx()assert(not r.StreetDetails:FindFirstChild("QuayPockets35"))
 local f=Instance.new("Folder")f.Name="QuayPockets35"f.Parent=r.StreetDetails
 for i,v in {{-345,199},{-270,201},{-397,247}}do
  asset(f,b,"07","BroadleafTree","PocketTree"..i,v[1],v[2],13.5,45*i)
  local g=Instance.new("Model")g.Name="TreeGrate"..i
  piece(g,"CastIronGrate",Vector3.new(4,.05,4),b*CFrame.new(v[1],1.03,v[2]),metal,Enum.Material.DiamondPlate)
  finish(g,f)
 end
 for i,v in {{-345,191,0},{-270,210,180},{-402,251,90}}do asset(f,b,"07","ParkBench","PocketBench"..i,v[1],v[2],3,v[3])end
 local m=Instance.new("Model")m.Name="QuayClock"
 local cf=b*CFrame.new(-390,0,265)
 piece(m,"ClockPost",Vector3.new(.35,8,.35),cf*CFrame.new(0,5,0),metal,Enum.Material.Metal)
 local face=piece(m,"ClockCase",Vector3.new(3,3,.45),cf*CFrame.new(0,8.5,0),metal,Enum.Material.Metal)
 piece(m,"ClockFace",Vector3.new(2.6,2.6,.08),cf*CFrame.new(0,8.5,-.27),cream)
 for i=0,11 do local a=i*math.pi/6
  piece(m,"HourTick",Vector3.new(.10,.22,.04),cf*CFrame.new(math.sin(a)*1.02,8.5+math.cos(a)*1.02,-.33)*CFrame.Angles(0,0,-a),metal)
 end
 piece(m,"HourHand",Vector3.new(.09,.65,.05),cf*CFrame.new(.19,8.7,-.38)*CFrame.Angles(0,0,-.75),metal)
 piece(m,"MinuteHand",Vector3.new(.07,1,.05),cf*CFrame.new(0,9,-.4),metal)
 finish(m,f)
 return #f:GetChildren()
end

-- Run after owner edits a building. Candidate markers deliberately stay out of runtime logic.
function D.SyncAddresses()
 local r,b=ctx()local count=0
 for _,f in {r.BrickQuay,r.CivicCentre}do for _,m in f:GetChildren()do
  local id=m:GetAttribute("AddressId35")local point=id and r.FutureAddresses:FindFirstChild(id)
  local door=m:FindFirstChild("LobbyDoor")or m:FindFirstChild("ShopDoorGlass")
  if point and door then
   local pos=door.CFrame:PointToWorldSpace(Vector3.new(0,0,m:FindFirstChild("LobbyDoor")and -2.75 or -2.5))
   local at=b:PointToObjectSpace(pos)point.CFrame=b*CFrame.new(at.X,1,at.Z)count+=1
  end
 end end
 return count
end
return D
