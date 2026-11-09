-- Edit migration: continuous precise Part ground; no Terrain voxel clearing.
local map=workspace.PaketKilat.Map
assert(not map:FindFirstChild('Ground14'),'Inspect existing Ground14 before applying again')
local base=map.DepotPad.Position.Y+1
local folder=Instance.new('Folder')folder.Name='Ground14'folder.Parent=map
local grass=Color3.fromRGB(119,155,98)local paving=Color3.fromRGB(175,175,160)
local function slab(name,size,x,z,top,color,material)
 local p=Instance.new('Part')p.Name=name p.Size=size p.Position=Vector3.new(x,base+top-size.Y/2,z)
 p.Anchored=true p.CanTouch=false p.Color=color p.Material=material p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=folder return p
end
-- Top stays below existing roads/floors: no overlay over houses or gameplay anchors.
slab('ContinuousEarth',Vector3.new(282,12.45,180),5,66,-.55,Color3.fromRGB(118,106,81),Enum.Material.Ground)
slab('ContinuousGrass',Vector3.new(282,.3,180),5,66,-.25,grass,Enum.Material.Grass)
local water=map.Polish01.CanalWater local bed=map.Polish01.CanalBed
water.Size=Vector3.new(334,water.Size.Y,234)water.Position=Vector3.new(5,water.Position.Y,65)
bed.Size=Vector3.new(334,bed.Size.Y,234)bed.Position=Vector3.new(5,bed.Position.Y,65)
-- Existing thick blocks are buried in the unified earth; surfaces use one paving family.
for _,name in ipairs({'EastBlock','WestBlock','MarketPlaza'})do
 local p=map.City13[name]p.Material=Enum.Material.Pavement p.Color=paving
end
for _,p in ipairs(map:GetDescendants())do
 if p:IsA('BasePart')and p.Name:match('^HousePad')and p.Material==Enum.Material.Grass then
  -- Continuous lawn replaces these overlapping plot surfaces; retain objects for rollback.
  p.Transparency=1 p.CanCollide=false p.CastShadow=false
 end
 if p:IsA('BasePart')and(p.Name=='FrontSidewalk'or p.Name=='DoorstepPath')then
  p.Material=Enum.Material.Pavement p.Color=paving
 end
end
slab('SouthStreetWalk',Vector3.new(274,.2,3),4,36.5,0,paving,Enum.Material.Pavement)
slab('MarketStreetWalk',Vector3.new(263,.2,3),9.5,152.5,0,paving,Enum.Material.Pavement)
-- Connect the short gaps between plot edges and the existing front sidewalks.
for _,x in ipairs({-100,0,100})do slab('FrontHomeConnection',Vector3.new(7,.15,4),x,16,.03,paving,Enum.Material.Pavement)end
for _,x in ipairs({-100,-3,110})do slab('MarketHomeConnection',Vector3.new(7,.15,10),x,130,.03,paving,Enum.Material.Pavement)end
-- Replace the missing west city frontage with a continuous pedestrian strip.
slab('WestCityWalk',Vector3.new(5,.2,96),-35,86,0,paving,Enum.Material.Pavement)
slab('EastCityWalk',Vector3.new(5,.2,96),-12,86,0,paving,Enum.Material.Pavement)
-- Lawn-to-plaza transitions, away from the ramp and house plots.
slab('WestGardenPath',Vector3.new(7,.15,38),-70,115,.01,paving,Enum.Material.Pavement)
slab('EastGardenPath',Vector3.new(5,.15,8),52,96,.01,paving,Enum.Material.Pavement)
-- Ground is now continuous under old isolated decorations. Clear the ramp planters.
for _,p in ipairs(map.City13:GetChildren())do
 if p:IsA('BasePart')and(p.Name=='Planter'or p.Name=='Hedge')and(math.abs(p.Position.X-9)<.1 or math.abs(p.Position.X+39)<.1)then p.Position+=Vector3.new(0,0,8)end
end
workspace.PaketKilat:SetAttribute('GroundRevision','ContinuousDistrict14')
return {created=#folder:GetChildren(),top=base-.25,bounds={-136,146,-24,156}}
