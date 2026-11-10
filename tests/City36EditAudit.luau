-- Edit geometry audit. Candidate markers are metadata, not live delivery endpoints.
local m=workspace.PaketKilat.Map local r=m.City36 local b=m.DepotPad.CFrame local out={anchors={},offices={},floors={},lanes={},addresses={},ground={},counts={}}
local snap=game.HttpService:JSONDecode(game.ServerStorage.PaketKilat_PreCity36.Snapshot.Value)
local function resolve(path)local p=game for n in string.gmatch(path,"[^%.]+")do p=p and p:FindFirstChild(n)end return p end
for _,a in snap.anchors do local p=resolve(a.path)local cf=CFrame.new(table.unpack(a.cf))
 table.insert(out.anchors,{path=a.path,positionDelta=p and(p.Position-cf.Position).Magnitude or -1,sizeDelta=p and(p.Size-Vector3.new(table.unpack(a.size))).Magnitude or -1})
end
for _,a in snap.offices do local p=resolve(a.path).OfficeBody local cf=CFrame.new(table.unpack(a.cf))
 table.insert(out.offices,{path=a.path,positionDelta=(p.Position-cf.Position).Magnitude,sizeDelta=(p.Size-Vector3.new(table.unpack(a.size))).Magnitude,colorDelta=(Vector3.new(p.Color.R,p.Color.G,p.Color.B)-Vector3.new(table.unpack(a.color))).Magnitude})
end
local floors={m.Surface15,r.Surfaces,m.Districts35.Surface35,m.Districts35.RoadBridge}
local params=RaycastParams.new()params.FilterType=Enum.RaycastFilterType.Include params.FilterDescendantsInstances=floors
local function floor(x,z)
 local h=workspace:Raycast(b:PointToWorldSpace(Vector3.new(x,1.15,z)),Vector3.new(0,-.4,0),params)
 return h and b:PointToObjectSpace(h.Position).Y,h
end
for _,s in {{"OldTown",-138,144,-24,151},{"Civic",-138,145,151,310},{"Quay",-445,-163,94,306}}do
 local q={samples=0,holes=0,wrongHeight=0,examples={}}
 for x=s[2]+.71,s[3]-.3,3.7 do for z=s[4]+.93,s[5]-.3,3.9 do
  local y=floor(x,z)q.samples+=1
  if not y then q.holes+=1 if #q.examples<7 then table.insert(q.examples,{x,z})end
  elseif math.abs(y-1)>.01 then q.wrongHeight+=1 end
 end end
 out.floors[s[1]]=q task.wait()
end
local ray=RaycastParams.new()ray.RespectCanCollide=true
for _,s in {{"OldSouth",-130,28,132,28,4},{"OldNorth",-130,144,132,144,4},{"OldSpine",-24,29,-24,143,4},{"WestLoop",-130,28,-130,144,3},{"EastLoop",132,28,132,144,3},{"Bridge",-130,144,-185,144,4},{"QuayDiagonal",-185,114,-423,286,4},{"CivicWest",-92,148,-92,280,5},{"CivicEast",76,148,76,280,5}}do
 local a,c=Vector3.new(s[2],3,s[3]),Vector3.new(s[4],3,s[5])local normal=Vector3.new(-(c-a).Z,0,(c-a).X).Unit local blockers={}
 for _,o in {-s[6],0,s[6]}do local start=b:PointToWorldSpace(a+normal*o)local stop=b:PointToWorldSpace(c+normal*o)
  local hit=workspace:Raycast(start,stop-start,ray)if hit then table.insert(blockers,hit.Instance:GetFullName())end
 end
 local holes,edgeRays=0,0
 for t=0,1,.02 do local p=a:Lerp(c,t)if not floor(p.X,p.Z)then
  edgeRays+=1 local near=false for _,dx in {-.005,.005}do for _,dz in {-.005,.005}do if floor(p.X+dx,p.Z+dz)then near=true end end end
  if not near then holes+=1 end
 end end
 table.insert(out.lanes,{name=s[1],blockers=blockers,holes=holes,exactEdgeMisses=edgeRays})
end
for _,p in r.FutureAddresses:GetChildren()do
 local v=b:PointToObjectSpace(p.Position)local y=floor(v.X,v.Z)
 local owner for _,model in r.Infill:GetChildren()do if model:GetAttribute("AddressId36")==p.Name then owner=model break end end
 local head=p.Position+Vector3.new(0,2,0)
 local overlap=workspace:GetPartBoundsInBox(CFrame.new(head),Vector3.new(2,3,2))
 local blockers={}for _,q in overlap do if q.CanCollide and q:IsDescendantOf(owner)then table.insert(blockers,q.Name)end end
 table.insert(out.addresses,{id=p.Name,name=p:GetAttribute("DisplayName"),district=p:GetAttribute("District"),localPosition={v.X,v.Y,v.Z},supported=y~=nil,blockers=blockers,candidateOnly=p:GetAttribute("CandidateOnly")})
end
for _,p in r.PublicRealm:GetDescendants()do if p:IsA("Model")and p:GetAttribute("PublicRealm36")then
 local cf,size=p:GetBoundingBox()table.insert(out.ground,{name=p.Name,bboxGap=cf.Position.Y-size.Y/2-(b.Position.Y+1)})
end end
local function counts(root)
 local t={parts=0,mesh=0,colliders=0,code=0,lights=0}
 for _,p in root:GetDescendants()do if p:IsA("BasePart")then t.parts+=1 if p:IsA("MeshPart")then t.mesh+=1 end if p.CanCollide then t.colliders+=1 end end if p:IsA("LuaSourceContainer")then t.code+=1 end if p:IsA("Light")then t.lights+=1 end end return t
end
out.counts.city36=counts(r)out.counts.districts35=counts(m.Districts35)
out.oldSetbacks={}for _,model in m.City13:GetChildren()do if model:IsA("Model")then local v=b:PointToObjectSpace(model.Body.Position)table.insert(out.oldSetbacks,{name=model.Name,x=v.X,frontZ=v.Z-model.Body.Size.Z/2})end end
out.shopPoint={cf={m.Depot.ShopPoint.CFrame:GetComponents()},upDot=m.Depot.ShopPoint.CFrame.UpVector:Dot(Vector3.yAxis),localY=b:PointToObjectSpace(m.Depot.ShopPoint.Position).Y}
return game.HttpService:JSONEncode(out)