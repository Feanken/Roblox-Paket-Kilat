-- Edit-only town furnishing pass. Old routes, homes and gameplay anchors stay in place.
local map=workspace.PaketKilat.Map
local root=map:WaitForChild('City23')
assert(not root:FindFirstChild('Spaces'),'City23 spaces exist')
local folder=Instance.new('Folder')folder.Name='Spaces'folder.Parent=root
local basis=map.DepotPad.CFrame
local wood=Color3.fromRGB(122,89,66)local cream=Color3.fromRGB(235,223,198)local teal=Color3.fromRGB(47,103,103)
local groundModels={}
local function part(parent,name,size,x,y,z,color,material,rot)
	local p=Instance.new('Part')p.Name=name p.Size=size p.CFrame=basis*CFrame.new(x,y,z)*(rot or CFrame.identity)
	p.Color=color p.Material=material or Enum.Material.SmoothPlastic p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
	p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
local floorRay=RaycastParams.new()floorRay.FilterType=Enum.RaycastFilterType.Include floorRay.FilterDescendantsInstances={map.Surface15}
local function floorAt(x,z)
	local p=basis:PointToWorldSpace(Vector3.new(x,6,z))
	local hit=workspace:Raycast(p,Vector3.new(0,-12,0),floorRay)
	assert(hit,'Missing floor at '..x..','..z)return hit.Position.Y
end
local function place(template,name,x,z,height,angle,support)
	local model=template:Clone()model.Name=name
	for _,v in model:GetDescendants()do
		assert(not v:IsA('LuaSourceContainer'),'Template contains code')
		if v:IsA('BasePart')then v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=true end
	end
	local _,s=model:GetBoundingBox()model:ScaleTo(model:GetScale()*height/s.Y)
	model:PivotTo(basis*CFrame.new(x,1,z)*CFrame.Angles(0,math.rad(angle or 0),0))
	local cf,size=model:GetBoundingBox()local target=support or floorAt(x,z)
	model:PivotTo(model:GetPivot()+Vector3.new(0,target-(cf.Position.Y-size.Y/2),0))
	model:SetAttribute('SupportY23',target)model.Parent=folder
	table.insert(groundModels,model)return model
end
local a07=game.ServerStorage.PaketKilat_CreatorAssets07
local a09=game.ServerStorage.PaketKilat_CreatorAssets09

-- Market square: a small fountain, opposing seats and low planting.
local fountain=place(game.ServerStorage.PaketKilat_CreatorAssets23.Fountain,'PlazaFountain',48,86,10.5,0)
fountain:SetAttribute('SourceAssetId','13782728612')
place(a07.ParkBench,'PlazaBenchWest',36,86,2.9,90)
place(a07.ParkBench,'PlazaBenchEast',60,86,2.9,-90)
local plaque=part(folder,'PlazaPlaque',Vector3.new(7,1.1,.3),48,2.2,94.3,teal)
local gui=Instance.new('SurfaceGui')gui.Face=Enum.NormalId.Back gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.PixelsPerStud=35 gui.Parent=plaque
local text=Instance.new('TextLabel')text.Size=UDim2.fromScale(1,1)text.BackgroundTransparency=1 text.Text='ALUN-ALUN KILAT'text.Font=Enum.Font.GothamBold text.TextScaled=true text.TextColor3=cream text.Parent=gui
for _,x in {45,51}do part(folder,'PlaquePost',Vector3.new(.25,.65,.25),x,1.325,94.3,wood)end

-- Pergola over the existing picnic table; walking routes remain open around it.
local pergola=Instance.new('Model')pergola.Name='ParkPergola'pergola.Parent=folder
for _,x in {57.5,68.5}do for _,z in {-4.5,6.5}do
	part(pergola,'Foot',Vector3.new(.85,.3,.85),x,1.15,z,cream)
	part(pergola,'Post',Vector3.new(.5,7,.5),x,4.8,z,wood)
end end
for _,z in {-4.5,6.5}do part(pergola,'CrossBeam',Vector3.new(13,.5,.65),63,8.3,z,wood)end
for x=57,69,1.5 do part(pergola,'ShadeSlat',Vector3.new(.65,.3,13),x,8.7,1,cream)end
for _,x in {59,62,65,68}do
	local bulb=part(pergola,'WarmBulb',Vector3.new(.22,.22,.22),x,8,6.5,Color3.fromRGB(255,218,139),Enum.Material.Neon)bulb.Shape=Enum.PartType.Ball
end

-- Coastal walk: sea-facing seats, restrained railing and two existing free lamp templates.
for i,x in {-72,0,96}do place(a07.ParkBench,'CoastBench'..i,x,-21.6,2.9,0)end
for i,x in {-95,117}do place(a09.StreetLamp,'CoastLamp'..i,x,-22.1,8.5,0)end
for x=-123,133,16 do part(folder,'CoastRailPost',Vector3.new(.3,2,.3),x,2,-23.7,teal)end
for _,y in {1.55,2.8}do part(folder,'CoastRail',Vector3.new(258,.15,.15),5,y,-23.7,teal)end
for _,x in {-124,134}do part(folder,'CoastRailEnd',Vector3.new(.4,2.2,.4),x,2.1,-23.7,teal)end

-- Planters sit on the existing paving; foliage is supported by planter soil, not the street.
for i,p in {{29,95},{67,95},{35,-16.5},{94,-16.5},{-123,49},{-123,92},{121,48},{121,92}}do
	local x,z=p[1],p[2]
	part(folder,'Planter'..i,Vector3.new(4.2,.9,1.8),x,1.45,z,cream)
	part(folder,'Soil'..i,Vector3.new(3.8,.1,1.4),x,1.91,z,Color3.fromRGB(88,72,54))
	local bush=place(a09.GardenBush,'PlanterFoliage'..i,x,z,1.35,0,basis.Position.Y+1.96)
	bush:SetAttribute('Planter23',true)
end

-- Painted crossings are slightly raised decals made from Parts, with no duplicate ground slab.
for _,x in {47,-90}do
	for _,z in {22.5,24.3,26.1,29.9,31.7,33.5}do part(folder,'CrosswalkStripe',Vector3.new(7,.035,.85),x,1.025,z,cream)end
	for _,dx in {-4.5,4.5}do for _,z in {19.4,36.5}do
		part(folder,'CrossingBollard',Vector3.new(.35,2,.35),x+dx,2,z,teal)
	end end
end
for _,p in {{32,-7},{87,119},{-80,74}}do
	local x,z=p[1],p[2]
	part(folder,'LitterBin',Vector3.new(1.25,2,1.25),x,2,z,teal)
	part(folder,'BinLid',Vector3.new(1.4,.18,1.4),x,3.08,z,cream)
end

-- Geometry support check, including mesh feet. Small bounded grids run only in Edit.
local rp=RaycastParams.new()rp.FilterType=Enum.RaycastFilterType.Include
local audit={}
for _,model in groundModels do
	local cf,size=model:GetBoundingBox()
	local ex=math.abs(cf.RightVector.X)*size.X/2+math.abs(cf.LookVector.X)*size.Z/2
	local ez=math.abs(cf.RightVector.Z)*size.X/2+math.abs(cf.LookVector.Z)*size.Z/2
	local pitch=math.max(.1,math.max(ex,ez)*2/40)
	rp.FilterDescendantsInstances={model}
	local target=model:GetAttribute('SupportY23')local low=math.huge local samples=0 local hits=0
	for x=cf.Position.X-ex,cf.Position.X+ex,pitch do for z=cf.Position.Z-ez,cf.Position.Z+ez,pitch do
		local hit=workspace:Raycast(Vector3.new(x,target-3,z),Vector3.new(0,30,0),rp)
		if hit then low=math.min(low,hit.Position.Y)hits+=1 end
		samples+=1 if samples%1000==0 then task.wait()end
	end end
	local gap=low~=math.huge and low-target or nil
	local shift=0
	if gap and gap>.025 and gap<1.5 then shift=-gap model:PivotTo(model:GetPivot()+Vector3.new(0,shift,0))end
	for _,v in model:GetDescendants()do if v:IsA('BasePart')then v.CanQuery=false end end
	model:SetAttribute('SupportGap23',gap and gap+shift)
	table.insert(audit,{name=model.Name,samples=samples,hits=hits,gapBefore=gap,shift=shift,gapAfter=gap and gap+shift,review=not gap or math.abs(gap+shift)>.06})
	task.wait()
end
folder:SetAttribute('GroundAudit23',game.HttpService:JSONEncode(audit))
workspace.PaketKilat:SetAttribute('CityRevision','LivedInTown23')
return {models=#groundModels,children=#folder:GetChildren(),audit=audit}
