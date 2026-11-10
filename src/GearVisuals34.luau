-- Native, reusable gear geometry. Cosmetics never apply rewards or movement stats.
local V={}
local ink=Color3.fromRGB(35,53,58)local cream=Color3.fromRGB(239,225,195)
local metal=Color3.fromRGB(196,193,166)local leather=Color3.fromRGB(91,64,48)
local function piece(m,n,size,at,color,shape,material)
 local p=Instance.new("Part")p.Name=n p.Size=size p.CFrame=CFrame.new(at)p.Color=color
 p.Material=material or Enum.Material.Fabric p.Anchored=true p.Massless=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
 p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth
 if shape==Enum.PartType.Ball then
  local mesh=Instance.new("SpecialMesh")mesh.MeshType=Enum.MeshType.Sphere mesh.Parent=p
 elseif shape then p.Shape=shape p.Size=size end
 p.Parent=m return p
end
local function badge(m,z)
 local p=piece(m,"CourierBadge",Vector3.new(.46,.28,.025),Vector3.new(0,.03,z),cream,nil,Enum.Material.SmoothPlastic)
 local g=Instance.new("SurfaceGui")g.Face=Enum.NormalId.Back g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.PixelsPerStud=70 g.MaxDistance=35 g.ZOffset=.02 g.Parent=p
 local l=Instance.new("TextLabel")l.Size=UDim2.fromScale(1,1)l.BackgroundTransparency=1 l.Text="KILAT"l.Font=Enum.Font.GothamBlack l.TextColor3=ink l.TextScaled=true l.Parent=g
end
function V.Bag(id,color)
 local m=Instance.new("Model")m.Name="PaketKilatBag"m:SetAttribute("CosmeticId",id)m:SetAttribute("VisualRevision","Tailored34")
 local body
 if id=="TasStandar"then
  body=piece(m,"SatchelBody",Vector3.new(1.68,1.25,.58),Vector3.zero,color,Enum.PartType.Ball)
  piece(m,"SatchelFlap",Vector3.new(1.52,.5,.16),Vector3.new(0,.35,.28),leather,Enum.PartType.Ball)
  piece(m,"StitchedFlapEdge",Vector3.new(1.24,.035,.035),Vector3.new(0,.18,.37),cream)
  for _,x in {-.47,.47}do
   piece(m,"LeatherClosure",Vector3.new(.11,.52,.06),Vector3.new(x,.05,.34),leather)
   piece(m,"BrassBuckle",Vector3.new(.19,.16,.08),Vector3.new(x,-.05,.38),metal,nil,Enum.Material.Metal)
  end
  piece(m,"SideMailPocket",Vector3.new(.4,.55,.3),Vector3.new(.72,-.15,.03),leather,Enum.PartType.Ball)
  piece(m,"ShoulderWebbing",Vector3.new(1.35,.12,.12),Vector3.new(0,.58,-.15),leather)
  badge(m,.34)
 elseif id=="TasBiru"then
  body=piece(m,"RolltopBody",Vector3.new(1.42,1.72,.67),Vector3.zero,color,Enum.PartType.Ball)
  local roll=piece(m,"RolledClosure",Vector3.new(1.4,.31,.31),Vector3.new(0,.8,0),ink,Enum.PartType.Cylinder)
  piece(m,"RolltopClip",Vector3.new(.18,.6,.1),Vector3.new(0,.64,.24),leather)
  piece(m,"FrontPocket",Vector3.new(1.1,.58,.3),Vector3.new(0,-.35,.29),color:Lerp(ink,.3),Enum.PartType.Ball)
  piece(m,"PocketZip",Vector3.new(.8,.035,.04),Vector3.new(0,-.2,.45),metal)
  piece(m,"ZipPull",Vector3.new(.07,.13,.04),Vector3.new(.32,-.26,.47),metal,nil,Enum.Material.Metal)
  piece(m,"BottleSleeve",Vector3.new(.38,.65,.38),Vector3.new(.66,-.28,0),ink,Enum.PartType.Ball)
  badge(m,.36)
 elseif id=="TasHijau"then
  body=piece(m,"FieldPackBody",Vector3.new(1.5,1.68,.7),Vector3.zero,color,Enum.PartType.Ball)
  piece(m,"RoundedHood",Vector3.new(1.58,.55,.8),Vector3.new(0,.65,.02),color:Lerp(ink,.2),Enum.PartType.Ball)
  for _,x in {-.76,.76}do
   piece(m,"UtilitySidePouch",Vector3.new(.4,.8,.45),Vector3.new(x,-.23,0),color:Lerp(ink,.3),Enum.PartType.Ball)
   piece(m,"PouchWebbing",Vector3.new(.22,.07,.07),Vector3.new(x,-.05,.23),cream)
  end
  for _,x in {-.39,.39}do
   piece(m,"CompressionStrap",Vector3.new(.105,1.25,.07),Vector3.new(x,.04,.36),leather)
   piece(m,"ClipBuckle",Vector3.new(.19,.18,.08),Vector3.new(x,.15,.4),ink,nil,Enum.Material.SmoothPlastic)
  end
  badge(m,.4)
 else
  body=piece(m,"PaddedCourierBody",Vector3.new(1.58,1.8,.8),Vector3.zero,color,Enum.PartType.Ball)
  piece(m,"LargeFrontPocket",Vector3.new(1.28,.85,.32),Vector3.new(0,-.28,.36),color:Lerp(ink,.2),Enum.PartType.Ball)
  piece(m,"FrontZip",Vector3.new(1.02,.035,.045),Vector3.new(0,.02,.53),metal)
  piece(m,"ZipPull",Vector3.new(.065,.14,.04),Vector3.new(.45,-.05,.56),metal,nil,Enum.Material.Metal)
  for _,y in {-.5,.52}do piece(m,"ReflectiveBand",Vector3.new(1.17,.08,.035),Vector3.new(0,y,.41),cream,nil,Enum.Material.SmoothPlastic)end
  piece(m,"CarryHandle",Vector3.new(.65,.1,.12),Vector3.new(0,.91,-.02),ink)
  for _,x in {-.3,.3}do piece(m,"HandleMount",Vector3.new(.1,.18,.12),Vector3.new(x,.82,-.02),ink)end
  badge(m,.56)
 end
 for _,x in {-.5,.5}do
  piece(m,"PaddedBackStrap",Vector3.new(.2,1.2,.17),Vector3.new(x,.1,-.34),ink,Enum.PartType.Ball)
  piece(m,"StrapAdjuster",Vector3.new(.23,.16,.09),Vector3.new(x,-.48,-.34),metal,nil,Enum.Material.Metal)
 end
 m.PrimaryPart=body return m
end
function V.Glove(level,side,size)
 level=math.clamp(level,1,3)local m=Instance.new("Model")m.Name="PaketKilatGlove"..side m:SetAttribute("GripLevel",level)m:SetAttribute("VisualRevision","Tailored34")
 local w,h,d=size.X,size.Y,size.Z local c=({Color3.fromRGB(139,100,69),Color3.fromRGB(46,111,106),Color3.fromRGB(174,128,44)})[level]
 local body=piece(m,"ShapedPalm",Vector3.new(w,h,d),Vector3.zero,c,Enum.PartType.Ball)
 piece(m,"ReinforcedCuff",Vector3.new(w*1.02,h*.28,d*.96),Vector3.new(0,h*.3,0),c:Lerp(ink,.38),Enum.PartType.Ball)
 piece(m,"CuffStitch",Vector3.new(w*.75,h*.035,.025),Vector3.new(0,h*.32,-d*.47),cream)
 local sign=side=="Left"and 1 or -1
 piece(m,"Thumb",Vector3.new(w*.29,h*.48,d*.42),Vector3.new(sign*w*.43,-h*.08,-d*.18),c,Enum.PartType.Ball)
 for i=-1,1 do
  piece(m,"FingerCap",Vector3.new(w*.27,h*.32,d*.64),Vector3.new(i*w*.26,-h*.37,-d*.06),c,Enum.PartType.Ball)
 end
 if level==1 then
  piece(m,"LeatherGripPanel",Vector3.new(w*.66,h*.35,d*.09),Vector3.new(0,-h*.02,-d*.47),leather,Enum.PartType.Ball)
 else
  for i=-1,1 do piece(m,"KnucklePad",Vector3.new(w*.24,h*.3,d*.13),Vector3.new(i*w*.26,h*.04,-d*.49),ink,Enum.PartType.Ball)end
  piece(m,"WristFastener",Vector3.new(w*.23,h*.2,d*.12),Vector3.new(sign*w*.3,h*.36,-d*.53),metal,nil,Enum.Material.Metal)
 end
 if level==3 then
  for _,x in {-.24,.24}do for _,y in {-.18,.14}do
   piece(m,"SiliconeGrip",Vector3.new(w*.12,h*.12,d*.06),Vector3.new(w*x,h*y,d*.49),cream,Enum.PartType.Ball,Enum.Material.SmoothPlastic)
  end end
  piece(m,"ProCuffStripe",Vector3.new(w*.7,h*.075,.035),Vector3.new(0,h*.3,-d*.49),cream,nil,Enum.Material.SmoothPlastic)
 end
 m.PrimaryPart=body return m
end
return V
