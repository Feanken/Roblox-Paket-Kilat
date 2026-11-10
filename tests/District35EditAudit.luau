-- Edit geometry checks; refreshes candidate nearest-road-node attributes.
local r=workspace.PaketKilat.Map.Districts35 local b=workspace.PaketKilat.Map.DepotPad.CFrame
local result={floors={},lanes={},assets={models=0,maxGap=0,bad={}},anchors={},counts={},addresses={}}
local floorParams=RaycastParams.new()floorParams.FilterType=Enum.RaycastFilterType.Include floorParams.FilterDescendantsInstances={r.Surface35,r.RoadBridge,workspace.PaketKilat.Map.Surface15}
for _,spec in {{"CivicCentre",-138,145,151,310},{"BrickQuay",-445,-163,94,306}}do
 local f={samples=0,holes=0,min=math.huge,max=-math.huge,wrong=0,examples={}}
 for x=spec[2]+.73,spec[3]-.2,3.7 do for z=spec[4]+.91,spec[5]-.2,3.9 do
  local hit=workspace:Raycast(b:PointToWorldSpace(Vector3.new(x,1.15,z)),Vector3.new(0,-.35,0),floorParams)
  f.samples+=1
  if not hit then f.holes+=1 if #f.examples<6 then table.insert(f.examples,{x,z})end
  else local y=b:PointToObjectSpace(hit.Position).Y f.min=math.min(f.min,y)f.max=math.max(f.max,y)if math.abs(y-1)>.008 then f.wrong+=1 end end
 end end
 result.floors[spec[1]]=f task.wait()
end
local lanes={
 {"Bridge",-124,144,-185,144},
 {"CivicWest",-92,146,-92,282},{"CivicEast",76,146,76,282},{"CivicNorth",-118,282,126,282},
 {"QuayWest",-423,114,-423,286},{"QuayEast",-185,114,-185,286},
 {"QuaySouth",-423,114,-185,114},{"QuayLower",-423,171,-185,171},
 {"QuayUpper",-423,229,-185,229},{"QuayNorth",-423,286,-185,286},{"QuayDiagonal",-185,114,-423,286}
}
local laneParams=RaycastParams.new()laneParams.RespectCanCollide=true
for _,v in lanes do
 local a,c=Vector3.new(v[2],3,v[3]),Vector3.new(v[4],3,v[5])
 local normal=Vector3.new(-(c-a).Z,0,(c-a).X).Unit local blockers={}
 for _,offset in {-5,0,5}do
  local A=b:PointToWorldSpace(a+normal*offset)local C=b:PointToWorldSpace(c+normal*offset)
  local hit=workspace:Raycast(A,C-A,laneParams)
  if hit then table.insert(blockers,hit.Instance:GetFullName())end
 end
 local holes,seams=0,0 for t=0,1,.02 do
  local p=a:Lerp(c,t)local hit=workspace:Raycast(b:PointToWorldSpace(Vector3.new(p.X,1.15,p.Z)),Vector3.new(0,-.35,0),floorParams)
  if not hit then
   seams+=1 local recovered=false
   for _,dx in {-.005,.005}do for _,dz in {-.005,.005}do
    if workspace:Raycast(b:PointToWorldSpace(Vector3.new(p.X+dx,1.15,p.Z+dz)),Vector3.new(0,-.35,0),floorParams)then recovered=true end
   end end
   if not recovered then holes+=1 end
  end
 end
 table.insert(result.lanes,{name=v[1],blockers=blockers,holes=holes,exactEdgeRayMisses=seams})
end
for _,m in r.StreetDetails:GetDescendants()do if m:IsA("Model")and m:GetAttribute("PublicRealm35")then
 result.assets.models+=1 local gap=m:GetAttribute("MeshFootGap35")or 0 result.assets.maxGap=math.max(result.assets.maxGap,gap)
 if math.abs(gap)>.08 then table.insert(result.assets.bad,{m.Name,gap})end
end end
local snapshot=game.HttpService:JSONDecode(game.ServerStorage.PaketKilat_PreDistrict35.Snapshot.Value)
for _,a in snapshot.anchors do local p=game
 for s in string.gmatch(a.path,"[^%.]+")do if s~="game"then p=p and p:FindFirstChild(s)end end
 local delta=p and(p.Position-CFrame.new(table.unpack(a.cf)).Position).Magnitude or -1
 table.insert(result.anchors,{path=a.path,positionDelta=delta,sizeDelta=p and(p.Size-Vector3.new(table.unpack(a.size))).Magnitude or -1})
end
for _,p in r.FutureAddresses:GetChildren()do
 local lp=b:PointToObjectSpace(p.Position)local hit=workspace:Raycast(p.Position+Vector3.new(0,.15,0),Vector3.new(0,-.4,0),floorParams)
 local near,dist=nil,math.huge
 for _,n in r.NavigationNodes:GetChildren()do local d=(p.Position-n.Position).Magnitude if d<dist then near=n dist=d end end
 p:SetAttribute("NearestRoadNode35",near and near.Name or "")
 table.insert(result.addresses,{id=p.Name,name=p:GetAttribute("DisplayName"),district=p:GetAttribute("District"),localPosition={lp.X,lp.Y,lp.Z},floorSupported=hit~=nil,candidateOnly=p:GetAttribute("CandidateOnly"),nearestNode=near and near.Name or ""})
end
local codeCount,parts,mesh,collide,lights=0,0,0,0,0
for _,v in r:GetDescendants()do
 if v:IsA("BasePart")then parts+=1 if v.CanCollide then collide+=1 end if v:IsA("MeshPart")then mesh+=1 end end
 if v:IsA("LuaSourceContainer")then codeCount+=1 end if v:IsA("Light")then lights+=1 end
end
result.counts={parts=parts,meshes=mesh,colliders=collide,code=codeCount,lights=lights,shops=#r.BrickQuay:GetChildren(),offices=#r.CivicCentre:GetChildren(),futureAddresses=#r.FutureAddresses:GetChildren(),nodes=#r.NavigationNodes:GetChildren()}
return game.HttpService:JSONEncode(result)