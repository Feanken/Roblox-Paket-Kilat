-- Edit migration. All additions live in one removable folder; no terrain writes.
local map=workspace.PaketKilat.Map
assert(not map:FindFirstChild('City13'),'City13 already exists; inspect before rebuilding')
local city=Instance.new('Folder')city.Name='City13'city.Parent=map
local y=map.DepotPad.Position.Y+1
local function part(name,size,pos,color,solid,parent)
 local p=Instance.new('Part')p.Name=name p.Size=size p.Position=Vector3.new(pos.X,y+pos.Y,pos.Z)
 p.Anchored=true p.CanCollide=solid==true p.CanTouch=false p.Material=Enum.Material.SmoothPlastic
 p.Color=color p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=parent or city return p
end
local cream=Color3.fromRGB(225,213,185)local teal=Color3.fromRGB(40,111,109)local gold=Color3.fromRGB(249,197,81)
local function sign(p,text)
 local b=Instance.new('BillboardGui')b.Size=UDim2.fromOffset(150,34)b.StudsOffset=Vector3.new(0,3,0)b.MaxDistance=65 b.AlwaysOnTop=false b.Parent=p
 local l=Instance.new('TextLabel')l.Size=UDim2.fromScale(1,1)l.BackgroundColor3=teal l.BackgroundTransparency=.1 l.TextColor3=cream l.Text=text l.TextSize=13 l.Font=Enum.Font.GothamBold l.Parent=b
end
part('EastBlock',Vector3.new(96,8,58),Vector3.new(50,-4,67),cream,true)
part('WestBlock',Vector3.new(78,8,58),Vector3.new(-70,-4,67),cream,true)
part('MarketPlaza',Vector3.new(82,8,39),Vector3.new(52,-4,116.5),Color3.fromRGB(192,186,166),true)
part('MarketEntry',Vector3.new(12,.3,8),Vector3.new(52,.15,140),cream,true)
local function building(x,z,w,d,h,color,title)
 local m=Instance.new('Model')m.Name=title m.Parent=city
 part('Body',Vector3.new(w,h,d),Vector3.new(x,h/2,z),color,true,m)
 part('Roof',Vector3.new(w+1,1,d+1),Vector3.new(x,h+.5,z),teal,false,m)
 for level=1,math.floor(h/7)do for _,dx in ipairs({-w*.28,w*.28})do
  part('Window',Vector3.new(3,3,.25),Vector3.new(x+dx,level*6-1,z+d/2+.15),Color3.fromRGB(144,203,207),false,m)
 end end
 local door=part('Entrance',Vector3.new(4,6,.3),Vector3.new(x,3,z+d/2+.25),teal,false,m)sign(door,title)
 part('RoofTank',Vector3.new(4,4,4),Vector3.new(x+3,h+3,z),Color3.fromRGB(97,144,151),false,m)
end
building(18,59,19,18,20,Color3.fromRGB(232,173,124),'TOKO ROTI')
building(49,55,20,20,34,Color3.fromRGB(158,187,171),'RUMAH SUSUN')
building(81,61,18,18,25,Color3.fromRGB(220,190,142),'BENGKEL')
building(-88,57,20,19,24,Color3.fromRGB(184,170,194),'TOKO BUKU')
building(-57,59,20,20,31,Color3.fromRGB(207,166,139),'KANTOR KAMPUNG')
for i,x in ipairs({22,47,72})do
 part('MarketCounter',Vector3.new(15,3,8),Vector3.new(x,1.5,107),teal,true)
 local roof=part('MarketAwning',Vector3.new(18,1,12),Vector3.new(x,8,107),i==2 and gold or Color3.fromRGB(208,109,78),false)sign(roof,({'WARUNG','PASAR PAGI','BUAH SEGAR'})[i])
 for _,dx in ipairs({-7,7})do part('AwningPost',Vector3.new(.6,8,.6),Vector3.new(x+dx,4,110),cream,false)end
 for j=1,3 do part('ProduceCrate',Vector3.new(3,1.5,3),Vector3.new(x-5+j*2.5,3.75,107),j==2 and gold or Color3.fromRGB(111,159,95),false)end
end
-- Landmark and low planters leave the existing road lanes clear.
part('ClockBase',Vector3.new(7,1,7),Vector3.new(52,.5,126),teal,true)
part('ClockColumn',Vector3.new(2,17,2),Vector3.new(52,9,126),cream,true)
local clock=part('ClockFace',Vector3.new(7,7,1),Vector3.new(52,19,126),teal,false)sign(clock,'PASAR KILAT')
part('ClockHand',Vector3.new(.4,2.4,.25),Vector3.new(52,20,126.7),gold,false)
part('ClockHand',Vector3.new(2,.4,.25),Vector3.new(53,19,126.7),gold,false)
for _,v in ipairs({Vector3.new(9,0,84),Vector3.new(88,0,84),Vector3.new(-101,0,84),Vector3.new(-39,0,84)})do
 part('Planter',Vector3.new(8,2,5),v+Vector3.new(0,1,0),teal,true)
 part('Hedge',Vector3.new(7,3,4),v+Vector3.new(0,3,0),Color3.fromRGB(79,136,97),false)
end
local stations=Instance.new('Folder')stations.Name='Stations'stations.Parent=city
for i,v in ipairs({Vector3.new(45,3,28),Vector3.new(-60,3,28),Vector3.new(-22,3,80),Vector3.new(55,3,144),Vector3.new(-65,3,144)})do
 local p=part('Pos'..i,Vector3.new(4,.2,4),v,gold,false,stations)p.Material=Enum.Material.Neon p.Transparency=.15
 sign(p,'POS BONUS · LEWATI')
end
workspace.PaketKilat:SetAttribute('CityRevision','CityChoices13')

-- Raised pedestrian choice; supports sit on the new city foundations.
local city=workspace.PaketKilat.Map.City13 local y=workspace.PaketKilat.Map.DepotPad.Position.Y+1
local function span(name,a,b,width,color)
 local p=Instance.new('Part')p.Name=name p.Size=Vector3.new(width,.6,(b-a).Magnitude)
 p.CFrame=CFrame.lookAt((a+b)/2+Vector3.new(0,y,0),b+Vector3.new(0,y,0))
 p.Anchored=true p.CanTouch=false p.Color=color p.Material=Enum.Material.Concrete p.Parent=city return p
end
local teal=Color3.fromRGB(40,111,109)
span('WestRamp',Vector3.new(-52,.3,80),Vector3.new(-32,10.3,80),8,teal)
span('PedestrianBridge',Vector3.new(-32,10.3,80),Vector3.new(2,10.3,80),8,teal)
span('EastRamp',Vector3.new(2,10.3,80),Vector3.new(22,.3,80),8,teal)
for _,x in ipairs({-32,2})do
 local p=Instance.new('Part')p.Name='BridgeSupport'p.Size=Vector3.new(2,10,8)p.Position=Vector3.new(x,y+5,80)p.Anchored=true p.Color=teal p.Parent=city
end
for _,z in ipairs({75.8,84.2})do
 local p=Instance.new('Part')p.Name='BridgeRailing'p.Size=Vector3.new(36,2,.4)p.Position=Vector3.new(-15,y+11.3,z)p.Anchored=true p.Color=Color3.fromRGB(249,197,81)p.Parent=city
end
city.Stations.Pos3.Position=Vector3.new(-15,y+13,80)
return 'Pedestrian bridge ready'