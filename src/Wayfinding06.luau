-- Edit migration; physical signage on existing, supported sidewalks.
local w=workspace.PaketKilat local m=w.Map local o=m.DepotPad.Position
assert(not m:FindFirstChild("Wayfinding06"),"Already installed")
local f=Instance.new("Folder") f.Name="Wayfinding06" f.Parent=m
local function part(name,size,pos,color)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=o+pos p.Anchored=true
 p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Color=color
 p.Material=Enum.Material.Wood p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=f return p
end
local function sign(x,z,title,line)
 part("SignPost",Vector3.new(.35,5,.35),Vector3.new(x,3.5,z),Color3.fromRGB(118,86,60))
 local p=part("DirectionBoard",Vector3.new(7,2.3,.25),Vector3.new(x,5.2,z),Color3.fromRGB(33,91,91))
 for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back}) do
  local gui=Instance.new("SurfaceGui") gui.Face=face gui.CanvasSize=Vector2.new(640,200) gui.LightInfluence=.4 gui.Parent=p
  local text=Instance.new("TextLabel") text.Size=UDim2.fromScale(.94,.52) text.Position=UDim2.fromScale(.03,.04)
  text.BackgroundTransparency=1 text.Font=Enum.Font.GothamBold text.TextScaled=true text.Text=title text.TextColor3=Color3.fromRGB(247,231,197) text.Parent=gui
  local sub=text:Clone() sub.Position=UDim2.fromScale(.03,.63) sub.Size=UDim2.fromScale(.94,.25) sub.Font=Enum.Font.GothamMedium sub.Text=line sub.Parent=gui
 end
end
sign(-8,19.5,"01 SARI  |  02 BUDI","Timur: Sari   /   Barat: Budi")
sign(-35,50.2,"JALUR AMAN","Lewat jalan memutar penghalang")
sign(-36,135.5,"03 RINA  /  04 AGUS  /  05 DEWI","Barat: Dewi   /   Timur: Rina, Agus")
return "Three supported two-sided direction signs installed"
