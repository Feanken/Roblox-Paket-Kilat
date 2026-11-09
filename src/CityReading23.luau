-- A small reading corner gives the office/bookshop courtyard a purpose.
local map=workspace.PaketKilat.Map local root=map.City23
assert(not root:FindFirstChild('ReadingCorner'),'Reading corner exists')
local f=Instance.new('Model')f.Name='ReadingCorner'f.Parent=root
local base=map.DepotPad.CFrame
local frame=base*CFrame.new(-66,0,89)*CFrame.Angles(0,math.pi/2,0)
local wood=Color3.fromRGB(122,89,66)local cream=Color3.fromRGB(239,229,207)
local function piece(name,size,x,y,z,color)
	local p=Instance.new('Part')p.Name=name p.Size=size p.CFrame=frame*CFrame.new(x,y,z)
	p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Color=color p.Material=Enum.Material.SmoothPlastic p.Parent=f return p
end
for _,x in {-2.2,2.2}do for _,z in {-.65,.65}do piece('CabinetLeg',Vector3.new(.25,1,.25),x,1.5,z,wood)end end
piece('CabinetBase',Vector3.new(5,.25,2),0,2.125,0,wood)
piece('CabinetBack',Vector3.new(5,3,.18),0,3.75,.9,wood)
for _,x in {-2.4,2.4}do piece('CabinetSide',Vector3.new(.2,3,2),x,3.75,0,cream)end
piece('CabinetShelf',Vector3.new(4.7,.15,1.7),0,3.5,0,cream)
local colors={Color3.fromRGB(198,119,84),Color3.fromRGB(74,129,131),Color3.fromRGB(199,169,75),Color3.fromRGB(119,109,151)}
for row=1,2 do for i=0,6 do
	local h=.85+(i%3)*.12
	piece('BookSpine',Vector3.new(.48,h,.8),-1.8+i*.6,(row==1 and 2.3 or 3.6)+h/2,-.2,colors[(i+row)%#colors+1])
end end
local glass=piece('WeatherCover',Vector3.new(4.6,2.8,.08),0,3.75,-.94,Color3.fromRGB(174,209,205))glass.Transparency=.78 glass.CastShadow=false
piece('CabinetRoof',Vector3.new(5.6,.25,2.6),0,5.4,0,wood)
local board=piece('ReadingSign',Vector3.new(5.2,.85,.2),0,5.7,-1,Color3.fromRGB(47,103,103))
local gui=Instance.new('SurfaceGui')gui.Face=Enum.NormalId.Front gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.PixelsPerStud=40 gui.Parent=board
local label=Instance.new('TextLabel')label.Size=UDim2.fromScale(1,1)label.BackgroundTransparency=1 label.Text='POJOK BACA'label.TextScaled=true label.Font=Enum.Font.GothamBold label.TextColor3=cream label.Parent=gui
for i,p in {{-88,82,0},{-72,82,0}}do
	local m=game.ServerStorage.PaketKilat_CreatorAssets07.ParkBench:Clone()m.Name='ReadingBench'..i
	for _,v in m:GetDescendants()do assert(not v:IsA('LuaSourceContainer'));if v:IsA('BasePart')then v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=false end end
	local _,s=m:GetBoundingBox()m:ScaleTo(m:GetScale()*2.9/s.Y)
	m:PivotTo(base*CFrame.new(p[1],1,p[2])*CFrame.Angles(0,math.rad(p[3]),0))
	local cf,size=m:GetBoundingBox()m:PivotTo(m:GetPivot()+Vector3.new(0,base.Position.Y+1-(cf.Position.Y-size.Y/2),0))
	m.Parent=f
end
return {parts=#f:GetDescendants()}
