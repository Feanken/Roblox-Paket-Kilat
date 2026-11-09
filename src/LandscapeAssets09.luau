-- Edit migration, preserves owner terrain. Free sources must be audited in Review09 first.
local ss=game.ServerStorage local w=workspace.PaketKilat local map=w.Map local origin=map.DepotPad.Position
assert(ss:FindFirstChild("PaketKilat_PrePolish09"),"Back up first")
assert(not map:FindFirstChild("Landscape09"),"Already installed")
local review=ss.CreatorStoreReview09
local library=Instance.new("Folder") library.Name="PaketKilat_CreatorAssets09" library.Parent=ss
local result=Instance.new("Folder") result.Name="Landscape09" result.Parent=map
local function clean(source,name,id,creator)
 local model=source:Clone() model.Name=name
 for _,v in ipairs(model:GetDescendants()) do
  if v:IsA("LuaSourceContainer") or v:IsA("PackageLink") or v:IsA("JointInstance") or v:IsA("Constraint") or v:IsA("GuiBase2d") or v:IsA("Sound") or v:IsA("ProximityPrompt") or v:IsA("ClickDetector") then v:Destroy()
  elseif v:IsA("BasePart") then
   v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=false
   if v:IsA("Seat") or v:IsA("VehicleSeat") then v.Disabled=true end
  elseif v:IsA("Light") then v.Shadows=false v.Brightness=.8 v.Range=14 v.Color=Color3.fromRGB(255,224,167) end
 end
 model:SetAttribute("CreatorStoreAssetId",id) model:SetAttribute("CreatorName",creator)
 model:SetAttribute("SourceURL","https://create.roblox.com/store/asset/"..id) model:SetAttribute("FreeAtReview",true)
 model.Parent=library return model
end
local lamp=clean(review.StreetLamp,"StreetLamp","3302675003","FredrikAustra")
local bush=clean(review.GardenBush,"GardenBush","7191673673","ChickenNuggets2go")
local rock=clean(review.GardenRocks,"GardenRocks","14603612772","neervu")
-- Strip the original lamp's long, thin ground plate before placing its actual foot.
for _,v in ipairs(lamp:GetDescendants()) do
 if v:IsA("BasePart") then
  if v.Size.Y<.15 and v.Size.Z>4 then v:Destroy()
  elseif v:IsA("UnionOperation") then v.UsePartColor=true v.Color=Color3.fromRGB(46,72,69)
  elseif not v:FindFirstChildWhichIsA("Light") then v.Color=Color3.fromRGB(46,72,69) v.Material=Enum.Material.Metal end
 end
end
for _,p in ipairs(rock:GetDescendants()) do if p:IsA("BasePart") then p.Color=Color3.fromRGB(156,153,139) end end
local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Include params.FilterDescendantsInstances={map,workspace.Terrain} params.RespectCanCollide=true
local function ground(x,z)
 local hit=workspace:Raycast(origin+Vector3.new(x,3,z),Vector3.new(0,-18,0),params)
 assert(hit and hit.Normal.Y>.8,"No supported surface at "..x..","..z)
 return hit.Position
end
local function cloneAt(template,name,pos,height,yaw,footprint,footAnchor)
 local model=template:Clone() model.Name=name
 local cf,size=model:GetBoundingBox()
 local scale=height and height/size.Y or footprint/math.max(size.X,size.Z)
 model:ScaleTo(model:GetScale()*scale) cf,size=model:GetBoundingBox()
 local target=CFrame.new(pos+Vector3.new(0,size.Y/2,0))*CFrame.Angles(0,yaw or 0,0)
 local relative=model:GetPivot():ToObjectSpace(cf)
 if footAnchor then
  local base,bottom=nil,math.huge
  for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") and p.Position.Y-p.Size.Y/2<bottom then base=p bottom=p.Position.Y-p.Size.Y/2 end end
  local localFoot=model:GetPivot():ToObjectSpace(CFrame.new(base.Position.X,bottom,base.Position.Z))
  model:PivotTo(CFrame.new(pos)*CFrame.Angles(0,yaw or 0,0)*localFoot:Inverse())
 else model:PivotTo(target*relative:Inverse()) end
 model:SetAttribute("SurfaceY",pos.Y) model.Parent=result return model
end
for i,p in ipairs({{-60,19.5},{60,19.5},{-65,135.5},{65,135.5}}) do cloneAt(lamp,"StreetLamp"..i,ground(p[1],p[2]),10.5,0,nil,true) end
-- Replace existing spherical foliage while retaining its supporting pots.
local pots={} local oldPlants={}
for _,p in ipairs(map:GetDescendants()) do if p:IsA("BasePart") then
 if p.Name=="Planter" or p.Name=="FlowerPot" then table.insert(pots,p) end
 if p.Name=="PlanterLeaves" or p.Name=="Flowers" or p.Name=="Flower" then table.insert(oldPlants,p) end
end end
for i,pot in ipairs(pots) do
 local center=pot.Position local top=center.Y+pot.Size.Y/2
 for _,leaf in ipairs(oldPlants) do
  if leaf.Parent and Vector2.new(leaf.Position.X-center.X,leaf.Position.Z-center.Z).Magnitude<1.9 and leaf.Position.Y>top-.1 and leaf.Position.Y<top+5 then leaf:Destroy() end
 end
 cloneAt(bush,"PottedShrub"..i,Vector3.new(center.X,top-.08,center.Z),nil,math.rad(i*39),math.min(pot.Size.X,pot.Size.Z)*1.3)
end
for i=1,5 do
 local house=map[string.format("Rumah%02d",i)] local pad=i==1 and map.HousePad or house["HousePad"..i]
 local at=pad.Position-origin
 for j,p in ipairs({{at.X-10,at.Z-9},{at.X+10,at.Z+10}}) do cloneAt(bush,"GardenShrub"..i.."_"..j,ground(p[1],p[2]),1.4,math.rad(i*41+j*55)) end
end
-- A small stone grouping beside each existing tree, fully within the garden inset.
for i,tree in ipairs(map.CreatorStore07:GetChildren()) do
 if tree.Name:find("GardenTree") then
  local cf=tree:GetBoundingBox() local at=cf.Position-origin
  cloneAt(rock,"TreeRocks"..i,ground(at.X+1.6,at.Z-1.6),.85,math.rad(i*57))
 end
end
if workspace:FindFirstChild("CreatorStorePreview09") then workspace.CreatorStorePreview09:Destroy() end
review:Destroy()
w:SetAttribute("LandscapeRevision","CreatorStore09")
return {pots=#pots,models=#result:GetChildren(),parts=(function()local n=0 for _,v in ipairs(result:GetDescendants())do if v:IsA("BasePart")then n+=1 end end return n end)()}
