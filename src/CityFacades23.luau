-- Edit migration. Add street-facing details while keeping existing building colliders/pivots.
local map=workspace.PaketKilat.Map
assert(not map:FindFirstChild("City23"),"City23 exists")
local root=Instance.new("Folder")root.Name="City23"root.Parent=map
local basis=map.DepotPad.CFrame
local cream=Color3.fromRGB(239,229,207)
local ink=Color3.fromRGB(44,78,78)
local glass=Color3.fromRGB(93,155,169)
local function part(parent,name,size,pos,color,rotation)
	local p=Instance.new("Part")p.Name=name p.Size=size p.CFrame=basis*CFrame.new(pos)*(rotation or CFrame.identity)
	p.Color=color p.Material=Enum.Material.SmoothPlastic p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
	p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent return p
end
local function window(parent,cf)
	local frame=part(parent,"WindowFrame",Vector3.new(3.5,3.9,.18),Vector3.zero,cream)frame.CFrame=cf
	local pane=part(parent,"WindowGlass",Vector3.new(2.9,3.3,.12),Vector3.zero,glass)pane.CFrame=cf*CFrame.new(0,0,-.14)
	local mullion=part(parent,"WindowMullion",Vector3.new(.1,3.3,.09),Vector3.zero,cream)mullion.CFrame=cf*CFrame.new(0,0,-.23)
end
local function sign(board,title,subtitle,face)
	local gui=Instance.new("SurfaceGui")gui.Face=face or Enum.NormalId.Front gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.PixelsPerStud=35 gui.MaxDistance=180 gui.ZOffset=1 gui.Parent=board
	local l=Instance.new("TextLabel")l.Size=UDim2.fromScale(1,.62)l.BackgroundTransparency=1 l.Font=Enum.Font.GothamBold l.Text=title l.TextScaled=true l.TextColor3=cream l.Parent=gui
	local s=l:Clone()s.Position=UDim2.fromScale(0,.63)s.Size=UDim2.fromScale(1,.3)s.Font=Enum.Font.GothamMedium s.Text=subtitle s.Parent=gui
end
local buildings={
	{"TOKO ROTI","ROTI KAMPUNG","DIPANGGANG SETIAP PAGI",Color3.fromRGB(170,86,61)},
	{"RUMAH SUSUN","WISMA KILAT","HUNIAN WARGA",Color3.fromRGB(59,113,118)},
	{"BENGKEL","BENGKEL SEPEDA","SERVIS & SUKU CADANG",Color3.fromRGB(181,141,63)},
	{"TOKO BUKU","BUKU & CERITA","BACA · TULIS · BELAJAR",Color3.fromRGB(99,98,139)},
	{"KANTOR KAMPUNG","BALAI WARGA","KAMPUNG KILAT",Color3.fromRGB(76,120,102)},
}
local counts={}
for _,spec in buildings do
	local original=map.City13[spec[1]]local body=original.Body
	local center=basis:PointToObjectSpace(body.Position)
	local w,d=body.Size.X,body.Size.Z
	local folder=Instance.new("Model")folder.Name=spec[1]folder.Parent=root
	local front=center.Z-d/2-.22
	local top=center.Y+body.Size.Y/2
	local accent=spec[4]
	original.Roof.Color=accent
	original.RoofTank.Transparency=1 original.RoofTank.CanCollide=false original.RoofTank.CanQuery=false original.RoofTank.CastShadow=false
	-- Continuous trim rings are deliberately proud of the wall, never coplanar.
	for _,height in {1.5,8.3,top-.4}do part(folder,"Cornice",Vector3.new(w+.45,.32,d+.45),Vector3.new(center.X,height,center.Z),cream)end
	for _,dx in {-w/2+.25,w/2-.25}do
		part(folder,"CornerTrim",Vector3.new(.5,body.Size.Y,.4),Vector3.new(center.X+dx,center.Y,front+.12),cream)
	end
	for height=11.8,top-2,6 do
		for _,x in {-w*.27,w*.27}do window(folder,basis*CFrame.new(center.X+x,height,front))end
		for _,side in {-1,1}do
			for _,z in {-d*.25,d*.25}do
				window(folder,basis*CFrame.new(center.X+side*(w/2+.2),height,center.Z+z)*CFrame.Angles(0,-side*math.pi/2,0))
			end
		end
	end
	-- Existing courtyard windows gain raised surrounds, keeping their original panes.
	for _,p in original:GetChildren()do if p:IsA("BasePart")and p.Name=="Window"then
		local trim=part(folder,"CourtyardWindowTrim",Vector3.new(3.6,3.6,.12),Vector3.zero,cream)
		trim.CFrame=p.CFrame*CFrame.new(0,0,-.08)
	end end
	local door=part(folder,"StreetDoor",Vector3.new(3.4,5.4,.25),Vector3.new(center.X,3.7,front-.05),ink)
	part(folder,"DoorGlass",Vector3.new(2.65,3.6,.12),Vector3.new(center.X,4.2,front-.23),glass)
	part(folder,"DoorHandle",Vector3.new(.13,.8,.12),Vector3.new(center.X+1.1,3.4,front-.34),cream)
	for _,x in {-w*.28,w*.28}do
		part(folder,"ShopWindowFrame",Vector3.new(4.6,4.7,.22),Vector3.new(center.X+x,3.7,front-.04),cream)
		part(folder,"ShopWindow",Vector3.new(4,4.1,.12),Vector3.new(center.X+x,3.7,front-.21),glass)
	end
	local board=part(folder,"StreetSign",Vector3.new(w-1,1.6,.35),Vector3.new(center.X,8.6,front-.35),accent)
	sign(board,spec[2],spec[3])
	local awning=part(folder,"ShopCanopy",Vector3.new(w-1,.3,3),Vector3.new(center.X,7.4,front-1.7),accent,CFrame.Angles(math.rad(8),0,0))
	for i=0,math.floor((w-1)/2)-1 do
		part(folder,"AwningStripe",Vector3.new(.8,.05,2.9),Vector3.new(center.X-(w-2)/2+1+i*2,7.58,front-1.7),cream,CFrame.Angles(math.rad(8),0,0))
	end
	-- Parapets and a round tank replace the five identical rooftop cubes.
	local roofY=top+1
	for _,z in {-d/2,d/2}do part(folder,"RoofParapet",Vector3.new(w+1,1.1,.35),Vector3.new(center.X,roofY+.55,center.Z+z),cream)end
	for _,x in {-w/2,w/2}do part(folder,"RoofParapet",Vector3.new(.35,1.1,d),Vector3.new(center.X+x,roofY+.55,center.Z),cream)end
	local tank=part(folder,"RoundRoofTank",Vector3.new(3.6,4,4),Vector3.new(center.X+3,roofY+2.2,center.Z),Color3.fromRGB(103,139,145),CFrame.Angles(0,0,math.pi/2))tank.Shape=Enum.PartType.Cylinder
	for _,dy in {.38,4.02}do local cap=part(folder,"TankRim",Vector3.new(.16,4.15,4.15),Vector3.new(center.X+3,roofY+dy,center.Z),ink,CFrame.Angles(0,0,math.pi/2))cap.Shape=Enum.PartType.Cylinder end
	for _,x in {-1.3,1.3}do for _,z in {-1.3,1.3}do part(folder,"TankSupport",Vector3.new(.3,.4,.3),Vector3.new(center.X+3+x,roofY+.2,center.Z+z),ink)end end
	counts[spec[1]]=#folder:GetDescendants()
	task.wait()
end
root:SetAttribute("Facade23",true)
root:SetAttribute("CanopyClearance23",true)
return counts
