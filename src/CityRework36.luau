-- City36: staged Edit-only repairs, coherent old-town street loop and building arrangement.
local B={}
local SS=game:GetService("ServerStorage")
local function ctx()
 assert(not game:GetService("RunService"):IsRunning(),"Edit only")
 local m=workspace.PaketKilat.Map return m,m.City36,m.DepotPad.CFrame,SS.PaketKilat_PreCity36
end
local function finish(x,p)x.Parent=p task.wait()end
local function part(parent,name,size,cf,col,mat,solid)
 local p=Instance.new("Part")p.Name=name p.Size=size p.CFrame=cf p.Color=col or Color3.fromRGB(185,180,164)
 p.Material=mat or Enum.Material.Pavement p.Anchored=true p.CanCollide=solid==true p.CanTouch=false p.CanQuery=solid==true p.CastShadow=solid==true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
local function record(instance,backup)
 local ref=Instance.new("ObjectValue")ref.Name=instance.Name ref.Value=instance
 ref:SetAttribute("OriginalPath36",instance:GetFullName())
 if instance:IsA("Model")then ref:SetAttribute("Pivot36",instance:GetPivot())
 elseif instance:IsA("BasePart")then ref:SetAttribute("CFrame36",instance.CFrame)ref:SetAttribute("Size36",instance.Size)ref:SetAttribute("Solid36",instance.CanCollide)ref:SetAttribute("Transparency36",instance.Transparency)end
 ref.Parent=backup:FindFirstChild("Changed")
end
local function archive(p,backup)
 p:SetAttribute("OriginalParent36",p.Parent:GetFullName())p.Parent=backup.Archive
end
function B.Setup()
 local m=workspace.PaketKilat.Map assert(not m:FindFirstChild("City36"),"City36 exists")
 local backup=Instance.new("Folder")backup.Name="PaketKilat_PreCity36"backup.Parent=SS
 for _,n in {"Changed","Archive","Sources"}do local f=Instance.new("Folder")f.Name=n f.Parent=backup end
 local r=Instance.new("Folder")r.Name="City36"r.Parent=m
 for _,n in {"Surfaces","Streets","Infill","PublicRealm","FutureAddresses"}do local f=Instance.new("Folder")f.Name=n f.Parent=r end
 local snapshot={anchors={},offices={},attributes=workspace.PaketKilat:GetAttributes()}
 for _,p in m:GetDescendants()do if p:IsA("BasePart")and(p.Name=="PickupPoint"or p.Name=="DestinationPoint"or p.Name=="RecoveryPoint"or p.Name=="PrototypeSpawn"or p:IsDescendantOf(m.RestStops27)or p:IsDescendantOf(m.City13.Stations))then
  table.insert(snapshot.anchors,{path=p:GetFullName(),cf={p.CFrame:GetComponents()},size={p.Size.X,p.Size.Y,p.Size.Z}})
 end end
 for _,office in m.Districts35.CivicCentre:GetChildren()do
  local p=office.OfficeBody table.insert(snapshot.offices,{path=office:GetFullName(),cf={p.CFrame:GetComponents()},size={p.Size.X,p.Size.Y,p.Size.Z},color={p.Color.R,p.Color.G,p.Color.B}})
 end
 local data=Instance.new("StringValue")data.Name="Snapshot"data.Value=game.HttpService:JSONEncode(snapshot)data.Parent=backup
 r:SetAttribute("Revision","CoherentCity36")
 return {anchors=#snapshot.anchors,offices=#snapshot.offices}
end
function B.Depot()
 local m,r,b,backup=ctx()
 local specs={{"BackWall",-7,6,-12},{"BackWallRight",3,6,-12},{"Roof",-2,11.5,-8},{"ShopPoint",-8,1.15,4}}
 for _,v in specs do local p=m.Depot[v[1]]record(p,backup)p.CFrame=b*CFrame.new(v[2],v[3],v[4])
  if v[1]=="Roof"then p.CanCollide=false p.CanQuery=false
  elseif v[1]=="ShopPoint"then p.CanCollide=false p.CanQuery=false p.Transparency=.3 end
 end
 -- Retired seam decals sat above the tile floor and looked like cracked/floating geometry.
 for _,p in m.Polish04:GetChildren()do if p.Name=="TileJoint"then archive(p,backup)end end
 return "Depot orthogonal; ShopPoint on floor"
end
function B.Realign()
 local m,r,b,backup=ctx()local moves={}
 local specs={{"TOKO ROTI",18,55},{"RUMAH SUSUN",48,56},{"BENGKEL",78,55},{"TOKO BUKU",-94,55.5},{"KANTOR KAMPUNG",-64,56}}
 for _,s in specs do
  local body=m.City13[s[1]].Body local old=b:PointToObjectSpace(body.Position)local delta=b:VectorToWorldSpace(Vector3.new(s[2]-old.X,0,s[3]-old.Z))
  local groups={m.City13[s[1]],m.City23[s[1]],m.City32[s[1].."_Details"]}
  if s[1]=="BENGKEL"then for _,n in {"BengkelDisplayBicycle","BengkelParkedBicycle","BengkelWorkshop"}do table.insert(groups,m.City32[n])end end
  for _,group in groups do record(group,backup)group:PivotTo(group:GetPivot()+delta)task.wait()end
  for _,p in m.City23.Access:GetChildren()do if p.Name=="CourtyardSign"then
   local at=b:PointToObjectSpace(p.Position)
   if math.abs(at.X-old.X)<.1 then record(p,backup)p.CFrame+=delta break end
  end end
  table.insert(moves,{name=s[1],dx=s[2]-old.X,dz=s[3]-old.Z})
 end
 return moves
end
function B.RelocateRoadProps()
 local m,r,b,backup=ctx()
 local shifts={
 {m.CityDecor15.ShadeTree8,7,0},{m.CityDecor15.ShadeTree9,2,0},
 {m.CityDecor15.ShadeTree12,-10,0},{m.CityDecor15.ShadeTree13,-11,4},
 {m.CityDecor15.Bench4,3,0},{m.City32.TamanTimur,-20,8},
 {m.City32.NeighbourhoodTree3,-20,-3},{m.City32.NeighbourhoodTree4,-14,12},
 {m.City32.EastGardenBench,-17,-6},{m.City32.EastGardenLamp,-16,-4}
 }
 for _,v in shifts do record(v[1],backup)v[1]:PivotTo(v[1]:GetPivot()+b:VectorToWorldSpace(Vector3.new(v[2],0,v[3])))task.wait()end
 for _,i in {5,6}do for _,n in {"Planter"..i,"Soil"..i,"PlanterFoliage"..i}do
  local p=m.City23.Spaces[n]record(p,backup)
  local delta=b:VectorToWorldSpace(Vector3.new(6,0,0))
  if p:IsA("Model")then p:PivotTo(p:GetPivot()+delta)else p.CFrame+=delta end
 end end
 -- Pocket props make room for three carefully fitted corner buildings.
 for _,v in {{1,-11,-7},{2,-12,10},{3,-10,-3}}do
  local f=m.Districts35.StreetDetails.QuayPockets35
  local tree=f:FindFirstChild("PocketTree"..v[1])local grate=f:FindFirstChild("TreeGrate"..v[1])
  for _,p in {tree,grate}do if p then record(p,backup)p:PivotTo(p:GetPivot()+b:VectorToWorldSpace(Vector3.new(v[2],0,v[3])))end end
 end
 return #shifts+6
end
local function uniq(t)table.sort(t)local a={}for _,v in t do if #a==0 or v-a[#a]>.001 then table.insert(a,v)end end return a end
local roadCuts={{-135,-125,35,137},{127,137,35,137}}
local walkCuts={{-138,-122,35,137},{124,141,35,137},{-12,6,38,70},{-49,-37,38,70}}
function B.RoadFloors(approachesOnly)
 local m,r,b,backup=ctx()local changed,created=0,0
 local inputs=m.Surface15:GetChildren()
 if approachesOnly then
  inputs={}
  for _,f in m.Districts35.Surface35:GetChildren()do
   if string.match(f.Name,"^OldTownApproach")then for _,p in f:GetDescendants()do if p:IsA("BasePart")then table.insert(inputs,p)end end end
  end
 end
 for _,old in inputs do
  if not old:IsA("BasePart")then continue end
  local c=b:PointToObjectSpace(old.Position)local bounds={c.X-old.Size.X/2,c.X+old.Size.X/2,c.Z-old.Size.Z/2,c.Z+old.Size.Z/2}
  for i=1,4 do bounds[i]=math.round(bounds[i]*1000)/1000 end
  local relevant={}local xs,zs={bounds[1],bounds[2]},{bounds[3],bounds[4]}
  for _,set in {roadCuts,walkCuts}do for _,cut in set do
   if math.min(bounds[2],cut[2])-math.max(bounds[1],cut[1])>.001 and math.min(bounds[4],cut[4])-math.max(bounds[3],cut[3])>.001 then
    table.insert(relevant,cut)for _,v in {cut[1],cut[2]}do if v>bounds[1]and v<bounds[2]then table.insert(xs,v)end end
    for _,v in {cut[3],cut[4]}do if v>bounds[3]and v<bounds[4]then table.insert(zs,v)end end
   end
  end end
  if #relevant==0 then continue end
  xs,zs=uniq(xs),uniq(zs)local g=Instance.new("Folder")g.Name="Partition"..changed
  for i=1,#xs-1 do for j=1,#zs-1 do
   local x,z=(xs[i]+xs[i+1])/2,(zs[j]+zs[j+1])/2 local mode
   for _,q in roadCuts do if x>q[1]and x<q[2]and z>q[3]and z<q[4]then mode="Road"end end
   if not mode then for _,q in walkCuts do if x>q[1]and x<q[2]and z>q[3]and z<q[4]then mode="Walk"end end end
   local color,mat=old.Color,old.Material
   if mode=="Road"then color=Color3.fromRGB(65,72,76)mat=Enum.Material.Asphalt
   elseif mode=="Walk"then color=Color3.fromRGB(185,180,164)mat=Enum.Material.Pavement end
   local p=part(g,mode or old.Name,Vector3.new(xs[i+1]-xs[i],.5,zs[j+1]-zs[j]),b*CFrame.new(x,.75,z),color,mat,true)
   p.CastShadow=false p:SetAttribute("Floor36",true)created+=1
  end end
  archive(old,backup)finish(g,r.Surfaces)changed+=1
 end
 -- Match all retained old asphalt to the new district and remove sub-millimetre height drift.
 local normalized=0
 for _,p in m.Surface15:GetChildren()do if p:IsA("BasePart")and p.Material==Enum.Material.Asphalt then
  record(p,backup)local v=b:PointToObjectSpace(p.Position)p.CFrame=b*CFrame.new(v.X,.75,v.Z)p.Color=Color3.fromRGB(65,72,76)normalized+=1
 end end
 return {retired=changed,new=created,normalized=normalized}
end
function B.Curbs()
 local m,r,b,backup=ctx()local count=0
 for _,f in {m.Polish05,m.City23.Access}do for _,p in f:GetChildren()do if p:IsA("BasePart")then
  local at=b:PointToObjectSpace(p.Position)
  if math.abs(at.Z-35)<.1 and(string.find(p.Name,"Parapet")or string.find(p.Name,"CanalParapet"))then archive(p,backup)count+=1 end
 end end end
 for i,a in {{-122,-95},{-85,-34},{-14,42},{52,124}}do
  part(r.Streets,"LowStreetCurb"..i,Vector3.new(a[2]-a[1],.18,.4),b*CFrame.new((a[1]+a[2])/2,1.09,35),Color3.fromRGB(224,215,192))
 end
 return count
end
function B.PatchSources()
 local m,r,b,backup=ctx()
 local shared=game.ReplicatedStorage.PaketKilat.Shared
 for _,name in {"Config","AudioProfile33"}do
  local p=shared[name]local saved=Instance.new("StringValue")saved.Name=name saved.Value=p.Source saved.Parent=backup.Sources
  if name=="Config"then
   local a,n=string.gsub(p.Source,"BoundsMin=Vector3.new%(%-126,%-14,%-55%), BoundsMax=Vector3.new%(136,96,154%)","BoundsMin=Vector3.new(-138,-14,-55), BoundsMax=Vector3.new(145,96,154)")
   assert(n==1,"Unexpected bounds source")p.Source=a
  else
   local a,n=string.gsub(p.Source,"Offset=Vector3.new%(135,3,72%)","Offset=Vector3.new(115,3,80)")
   assert(n==1,"Unexpected garden audio source")p.Source=a
  end
 end
 workspace.PaketKilat:SetAttribute("CityRevision","CoherentCity36")
 return "Old-town bounds and relocated garden ambience updated"
end
return B
