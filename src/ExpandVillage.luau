-- Tambahan T11-T15, hanya Edit; mempertahankan depot, Rumah01 dan map awal.
local W=workspace.PaketKilat
assert(not W.Map:FindFirstChild("Expansion"),"Perluasan sudah ada; inspeksi sebelum mengubah")
local C=require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local origin=W.Map.DepotPad.Position
local ex=Instance.new("Folder") ex.Name="Expansion"
local roads=Instance.new("Folder") roads.Name="Roads" roads.Parent=ex
local hazards=Instance.new("Folder") hazards.Name="Hazards" hazards.Parent=ex
local decor=Instance.new("Folder") decor.Name="Decor" decor.Parent=ex
local function part(name,size,offset,color,parent,collide)
	local p=Instance.new("Part")
	p.Name,p.Size,p.Position=name,size,origin+offset
	p.Anchored,p.Color,p.Material=true,color,Enum.Material.SmoothPlastic
	p.CanCollide=collide~=false
	if collide==false then p.CanTouch=false; p.CanQuery=false end
	p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
	p.Parent=parent or decor
	return p
end
local function sign(p,text,width)
	local b=Instance.new("BillboardGui") b.Name="Sign" b.Size=UDim2.fromOffset(width or 220,46) b.StudsOffset=Vector3.new(0,3,0)
	b.MaxDistance=85 b.Parent=p
	local t=Instance.new("TextLabel") t.Name="TextLabel" t.Size=UDim2.fromScale(1,1)
	t.BackgroundColor3,t.BackgroundTransparency=Color3.fromRGB(28,43,56),0.18
	t.TextColor3,t.Font,t.TextSize,t.TextWrapped=Color3.new(1,1,1),Enum.Font.GothamBold,15,true
	t.Text,t.Parent=text,b
end
local gray=Color3.fromRGB(112,128,139)
local green=Color3.fromRGB(111,190,114)
local function road(name,size,offset)
	local p=part(name,size,offset,gray,roads)
	p.Material=Enum.Material.Concrete
	return p
end
road("WestSafeAcross",Vector3.new(112,2,12),Vector3.new(-50,0,-40))
road("WestSafeHouse",Vector3.new(12,2,40),Vector3.new(-100,0,-26))
road("WestShortcut",Vector3.new(72,2,8),Vector3.new(-50,0,0))
road("NorthEntry",Vector3.new(38,2,12),Vector3.new(-12,0,8))
road("NorthStreet",Vector3.new(14,2,136),Vector3.new(-24,0,70))
road("MarketStreet",Vector3.new(248,2,14),Vector3.new(0,0,132))
road("BarrierBypassSouth",Vector3.new(38,2,14),Vector3.new(-36,0,44))
road("BarrierBypassWest",Vector3.new(14,2,56),Vector3.new(-48,0,65))
road("BarrierBypassNorth",Vector3.new(38,2,14),Vector3.new(-36,0,86))
local pool=part("Puddle",Vector3.new(24,0.12,7.5),Vector3.new(-50,1.08,0),Color3.fromRGB(91,188,225),hazards)
pool.Material,pool.Transparency,pool.Reflectance=Enum.Material.Ice,0.2,0.12
pool.CustomPhysicalProperties=PhysicalProperties.new(1,0.02,0.05,100,100)
pool:SetAttribute("HazardType","Slip")
sign(pool,"GENANGAN LICIN\nPelan-pelan atau pilih jalan aman",245)
local bar=part("MovingBarrier",Vector3.new(4,5,2),Vector3.new(-24,3.5,65),Color3.fromRGB(255,156,60),hazards,false)
bar:SetAttribute("HazardType","Barrier")
local face=Instance.new("SurfaceGui") face.Face=Enum.NormalId.Front face.CanvasSize=Vector2.new(240,180) face.Parent=bar
local warning=Instance.new("TextLabel") warning.Size=UDim2.fromScale(1,1) warning.BackgroundTransparency=1
warning.Text,warning.TextScaled,warning.Font,warning.TextColor3,warning.Parent="///\nAWAS\n///",true,Enum.Font.GothamBlack,Color3.fromRGB(30,39,45),face
part("BarrierZone",Vector3.new(26,0.12,6),Vector3.new(-24,1.08,65),Color3.fromRGB(249,196,74),hazards,false).Transparency=0.35
for _,x in ipairs({-37,-11}) do part("BarrierPost",Vector3.new(1,5,1),Vector3.new(x,3.5,65),Color3.fromRGB(255,232,176),hazards,false) end
local notice=part("BypassSign",Vector3.new(1,4,1),Vector3.new(-33,3,40),Color3.fromRGB(128,88,53),decor,false)
sign(notice,"PENGHALANG BERGERAK\nJalan aman: jalur memutar",240)
local entry=part("VillageSign",Vector3.new(1,5,1),Vector3.new(-12,3.5,15),Color3.fromRGB(128,88,53),decor,false)
sign(entry,"KAMPUNG KILAT\nUtara: Bu Rina · Pak Agus · Bu Dewi",280)
-- Flush satu kelompok kecil sebelum membuat rumah.
ex.Parent=W.Map
task.wait()
local colors={Color3.fromRGB(83,189,206),Color3.fromRGB(244,168,91),Color3.fromRGB(175,142,219),Color3.fromRGB(123,197,150),Color3.fromRGB(246,218,104)}
for i=2,5 do
	local id=string.format("Rumah%02d",i)
	assert(not W.Map:FindFirstChild(id),"Tujuan sudah ada")
	local offset=C.Routes[id].Offset
	local model=Instance.new("Model") model.Name=id
	part("HousePad"..i,Vector3.new(28,2,28),offset,green,model)
	part("Body",Vector3.new(13,9,10),offset+Vector3.new(4,5.5,-8),colors[i],model)
	local roof=part("Roof",Vector3.new(16,2,13),offset+Vector3.new(4,11,-8),Color3.fromRGB(213,103+8*i,83),model)
	roof.Material=Enum.Material.Brick
	part("Door",Vector3.new(3,6,0.3),offset+Vector3.new(4,4,-2.85),Color3.fromRGB(112,77,50),model)
	for _,x in ipairs({0,8}) do
		part("Window",Vector3.new(2.4,2.8,0.35),offset+Vector3.new(x,6,-2.75),Color3.fromRGB(219,243,250),model,false)
	end
	local target=part("DestinationPoint",Vector3.new(5,0.3,5),offset+Vector3.new(0,1.15,3),colors[i],model)
	target:SetAttribute("DestinationId",id)
	sign(target,string.format("%02d · %s\n%s",i,C.Routes[id].Name,C.Routes[id].Landmark),240)
	model:SetAttribute("DestinationId",id)
	if i==2 then
		part("WarungAwning",Vector3.new(15,0.5,5),offset+Vector3.new(4,9,-1),Color3.fromRGB(231,83,78),model,false)
		local shop=part("WarungBoard",Vector3.new(9,1,0.3),offset+Vector3.new(4,8,-3),Color3.fromRGB(255,234,176),model,false)
		sign(shop,"WARUNG BUDI",180)
	elseif i==3 then
		for _,x in ipairs({-9,10}) do
			part("FlowerPot",Vector3.new(2,1.4,2),offset+Vector3.new(x,1.7,8),Color3.fromRGB(184,107,73),model,false)
			local f=part("Flower",Vector3.new(2.5,1.5,2.5),offset+Vector3.new(x,3.1,8),Color3.fromRGB(248,154,202),model,false) f.Shape=Enum.PartType.Ball
		end
	elseif i==4 then
		for k=1,3 do part("Crate",Vector3.new(3,3,3),offset+Vector3.new(10,2.5+(k==3 and 3 or 0),k==2 and 7 or 4),Color3.fromRGB(161,113,69),model,false).Material=Enum.Material.WoodPlanks end
	elseif i==5 then
		local tank=part("WaterTank",Vector3.new(5,6,5),offset+Vector3.new(4,15,-8),Color3.fromRGB(92,162,191),model,false)
		tank.Shape=Enum.PartType.Cylinder tank.CFrame=CFrame.new(tank.Position)*CFrame.Angles(0,0,math.pi/2)
	end
	model.Parent=W.Map
	task.wait()
end
-- Dekor buatan sendiri, tidak menutup jalur.
for _,p in ipairs({Vector3.new(16,0,12),Vector3.new(-114,0,128),Vector3.new(114,0,128),Vector3.new(-65,0,43),Vector3.new(24,0,144)}) do
	part("TreePatch",Vector3.new(8,2,8),p,green,decor)
	part("TreeTrunk",Vector3.new(1.6,6,1.6),p+Vector3.new(0,4,0),Color3.fromRGB(143,104,61),decor,false)
	local crown=part("TreeCrown",Vector3.new(7,7,7),p+Vector3.new(0,9,0),Color3.fromRGB(71,156,96),decor,false) crown.Shape=Enum.PartType.Ball
end
local old=W.Map.Rumah01
local v=Instance.new("Folder") v.Name="Stage3Visuals"
for _,x in ipairs({100,108}) do part("Window",Vector3.new(2.4,2.8,0.35),Vector3.new(x,6,-2.75),Color3.fromRGB(218,245,252),v,false) end
local pot=part("FlowerPot",Vector3.new(2,1.4,2),Vector3.new(110,1.7,7),Color3.fromRGB(184,107,73),v,false)
part("Flowers",Vector3.new(3,2,3),Vector3.new(110,3.4,7),Color3.fromRGB(246,162,198),v,false).Shape=Enum.PartType.Ball
v.Parent=old
old.DestinationPoint.Sign.TextLabel.Text="01 · Rumah Bu Sari\nBiru · pot bunga"
old.DestinationPoint.Sign.MaxDistance=85
W.Map.Depot.PickupPoint.Sign.TextLabel.Text="PAKET KILAT! · DEPOT\nTujuan dan jenis bergilir · Ambil pesanan"
W.Map.NarrowPlank.Sign.MaxDistance=80
W:SetAttribute("Stage","T11-T15")
return {houses=5,expansionParts=#ex:GetDescendants(),origin=tostring(origin)}
