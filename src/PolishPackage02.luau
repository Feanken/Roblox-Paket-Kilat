-- Edit-only, additive SurfaceGui decoration; no new physics bodies or scripts.
local p=game.ServerStorage.PaketKilat.PackageTemplate
assert(not p:FindFirstChild("ShippingFront"),"P02 template already installed")
local function frame(parent,size,pos,color)
 local f=Instance.new("Frame") f.BorderSizePixel=0 f.Size=size f.Position=pos f.BackgroundColor3=color f.Parent=parent return f
end
local cream=Color3.fromRGB(245,232,202)
local ink=Color3.fromRGB(33,76,76)
for _,face in ipairs({Enum.NormalId.Top,Enum.NormalId.Front,Enum.NormalId.Back}) do
 local g=Instance.new("SurfaceGui") g.Name="Shipping"..face.Name g.Face=face
 g.CanvasSize=Vector2.new(480,360) g.LightInfluence=.7 g.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize g.Parent=p
 frame(g,UDim2.fromScale(.14,1),UDim2.fromScale(.43,0),cream)
 if face==Enum.NormalId.Top then
  frame(g,UDim2.fromScale(1,.08),UDim2.fromScale(0,.46),cream)
 else
  local label=frame(g,UDim2.fromScale(.72,.66),UDim2.fromScale(.14,.17),cream)
  local t=Instance.new("TextLabel") t.Name="Brand" t.Size=UDim2.fromScale(.9,.28) t.Position=UDim2.fromScale(.05,.05)
  t.BackgroundTransparency=1 t.TextColor3=ink t.Text="PAKET KILAT!" t.Font=Enum.Font.GothamBlack t.TextScaled=true t.Parent=label
  local sub=t:Clone() sub.Name="Handling" sub.Position=UDim2.fromScale(.05,.38) sub.Size=UDim2.fromScale(.9,.18)
  sub.Font=Enum.Font.GothamMedium sub.Text="KIRIM DENGAN HATI" sub.Parent=label
  for i=1,20 do frame(label,UDim2.new(0,i%3==0 and 6 or 3,.2,0),UDim2.new(.1,i*11,.7,0),ink) end
 end
end
p.Material=Enum.Material.SmoothPlastic
p.Label.MaxDistance=30 p.Label.Size=UDim2.fromOffset(160,38)
p.Label.TextLabel.TextSize=12
p.Label.TextLabel.BackgroundColor3=ink
return "Shipping label and packing tape added; original collider retained"
