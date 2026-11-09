-- One visible ground surface at each XZ point. Legacy surfaces stay hidden for rollback.
local m=workspace.PaketKilat.Map local y=m.DepotPad.Position.Y+1
assert(not m:FindFirstChild('Surface15'),'Surface15 exists; inspect before running')
local f=Instance.new('Folder')f.Name='Surface15'f.Parent=m
f:SetAttribute('SurfaceY',y)
local rects={}local originals={}
local function rect(x1,x2,z1,z2,kind,rank)
 table.insert(rects,{x1=x1,x2=x2,z1=z1,z2=z2,kind=kind,rank=rank})
end
rect(-136,146,-24,156,'Grass',0)
for _,p in ipairs(m:GetDescendants())do
 if p:IsA('BasePart')and p.Transparency<1 then
  local n=p.Name
  local road=p.Material==Enum.Material.Asphalt and p.Size.Y<=2.1
  local walk=n=='DepotPad'or n=='FrontSidewalk'or n=='AlignedGardenWalk'or n=='DoorstepPath'or n=='PorchLanding'or n=='FrontTerrace'or n=='DepotPadTerrace'or n=='HousePadTerrace'
  local block=p.Parent==m.City13 and(n=='EastBlock'or n=='WestBlock'or n=='MarketPlaza'or n=='MarketEntry')
  local g=p.Parent==m.Ground14 and n~='ContinuousEarth'
  local tile=n=='DepotTileFloor'
  if road or walk or block or g or tile then
   assert(math.abs(p.CFrame.UpVector.Y)>.999,'Rotated surface requires review: '..p:GetFullName())
   local x,z=p.Position.X,p.Position.Z local sx,sz=p.Size.X/2,p.Size.Z/2
   rect(x-sx,x+sx,z-sz,z+sz,road and 'Asphalt'or tile and 'Tiles'or n=='ContinuousGrass'and 'Grass'or 'Pavement',road and 30 or tile and 40 or 20)
   table.insert(originals,p)
  elseif n=='TreePatch'then table.insert(originals,p)end
 end
end
-- Close the accidental one-stud grass seam through the market and connect its entrance.
rect(2,98,38,137,'Pavement',21)
-- A connected shaded pocket park between depot and east house.
rect(19,83,10,15,'Pavement',21)rect(46,52,-11,19,'Pavement',21)
local function snap(v)return math.round(v*100)/100 end
local xs,zs={-136,146},{-24,156}
for _,r in ipairs(rects)do
 r.x1=math.max(-136,snap(r.x1))r.x2=math.min(146,snap(r.x2))
 r.z1=math.max(-24,snap(r.z1))r.z2=math.min(156,snap(r.z2))
 table.insert(xs,r.x1)table.insert(xs,r.x2)table.insert(zs,r.z1)table.insert(zs,r.z2)
end
local function unique(t)table.sort(t)local o={}for _,v in ipairs(t)do if #o==0 or v-o[#o]>.019 then table.insert(o,v)end end return o end
xs=unique(xs)zs=unique(zs)
local patches={}local previous={}
for j=1,#zs-1 do
 local z1,z2=zs[j],zs[j+1]local z=(z1+z2)/2 local runs={}local run
 for i=1,#xs-1 do
  local x1,x2=xs[i],xs[i+1]local x=(x1+x2)/2 local best
  for _,r in ipairs(rects)do if x>r.x1 and x<r.x2 and z>r.z1 and z<r.z2 and(not best or r.rank>best.rank)then best=r end end
  local kind=best and best.kind or 'Grass'
  if run and run.kind==kind then run.x2=x2 else run={x1=x1,x2=x2,z1=z1,z2=z2,kind=kind}table.insert(runs,run)end
 end
 local current={}
 for _,r in ipairs(runs)do
  local key=r.kind..':'..r.x1..':'..r.x2 local old=previous[key]
  if old then old.z2=z2 current[key]=old else table.insert(patches,r)current[key]=r end
 end previous=current
end
local colors={Grass=Color3.fromRGB(119,155,98),Pavement=Color3.fromRGB(175,175,160),Asphalt=Color3.fromRGB(82,94,94),Tiles=Color3.fromRGB(235,226,207)}
for i,r in ipairs(patches)do
 local p=Instance.new('Part')p.Name=r.kind p.Size=Vector3.new(r.x2-r.x1,.5,r.z2-r.z1)p.Position=Vector3.new((r.x1+r.x2)/2,y-.25,(r.z1+r.z2)/2)
 p.Anchored=true p.CanTouch=false p.Material=r.kind=='Tiles'and Enum.Material.CeramicTiles or Enum.Material[r.kind]p.Color=colors[r.kind]p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=f
 if i%100==0 then task.wait()end
end
for _,p in ipairs(originals)do p.Transparency=1 p.CanCollide=false p.CastShadow=false end
workspace.PaketKilat:SetAttribute('SurfaceRevision','SingleSurface15')
return {patches=#patches,retired=#originals}
