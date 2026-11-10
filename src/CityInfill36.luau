-- City36: human-scale infill and public realm. Edit only, no runtime generation.
local A={}
local SS=game:GetService("ServerStorage")
local cream=Color3.fromRGB(231,221,199)local ink=Color3.fromRGB(45,67,69)
local brass=Color3.fromRGB(192,153,81)local glass=Color3.fromRGB(105,151,158)
local function ctx()assert(not game.RunService:IsRunning(),"Edit only")local m=workspace.PaketKilat.Map return m,m.City36,m.DepotPad.CFrame end
local function part(m,n,size,cf,c,mat,solid)
 local p=Instance.new("Part")p.Name=n p.Size=size p.CFrame=cf p.Color=c or cream p.Material=mat or Enum.Material.SmoothPlastic p.Anchored=true p.CanCollide=solid==true p.CanQuery=solid==true p.CanTouch=false p.CastShadow=solid==true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=m return p
end
local function finish(m,p)m.Parent=p task.wait()end
local function sign(p,t,small)
 local g=Instance.new("SurfaceGui")g.Face=Enum.NormalId.Front g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.PixelsPerStud=34 g.MaxDistance=105 g.ZOffset=.05 g.Parent=p
 local l=Instance.new("TextLabel")l.BackgroundTransparency=1 l.Size=UDim2.fromScale(.94,small and .62 or .88)l.Position=UDim2.fromScale(.03,.04)l.Text=t l.TextScaled=true l.Font=Enum.Font.GothamBold l.TextColor3=cream l.Parent=g
 if small then local q=l:Clone()q.Position=UDim2.fromScale(.03,.7)q.Size=UDim2.fromScale(.94,.24)q.Font=Enum.Font.Gotham q.Text=small q.Parent=g end
end
local specs={
 {"OT01","STUDIO JAHIT",-43,55,12,16,16,0,"OldTown"},
 {"OT02","POS & KERTAS",-3,55,16,18,20,0,"OldTown"},
 {"CV01","KOPI TAMAN",-64,162,14,12,16,0,"CivicCentre"},
 {"CV02","GALERI KOTA",52,162,14,12,18,0,"CivicCentre"},
 {"CQ01","KAFE PERSIMPANGAN",-338,194,14,10,16,-144.15,"BrickQuay"},
 {"CQ02","FLORIS SUDUT",-266,207,14,10,15,35.85,"BrickQuay"},
 {"CQ03","BATA RECORDS",-398,241,14,10,18,-144.15,"BrickQuay"},
 {"PK01","KIOS KORAN",-78,300,12,7,7,0,"CivicCentre"},
 {"PK02","TEH TAMAN",-12,300,12,7,7,0,"CivicCentre"},
 {"PK03","BUNGA KOTA",65,300,12,7,7,0,"CivicCentre"}
}
local function building(r,b,s,index)
 local id,title,x,z,w,d,h,yaw,district=table.unpack(s)
 local cf=b*CFrame.new(x,0,z)*CFrame.Angles(0,math.rad(yaw),0)
 local m=Instance.new("Model")m.Name=id.."_"..title
 m:SetAttribute("AddressId36",id)m:SetAttribute("District",district)
 local color=({Color3.fromRGB(148,86,65),Color3.fromRGB(188,166,123),Color3.fromRGB(145,153,137),Color3.fromRGB(158,112,84)})[(index-1)%4+1]
 local accent=({ink,Color3.fromRGB(54,104,99),Color3.fromRGB(117,87,67),Color3.fromRGB(117,116,72)})[(index-1)%4+1]
 local function p(n,size,v,c,mat,solid)return part(m,n,size,cf*CFrame.new(v),c,mat,solid)end
 p("Body",Vector3.new(w,h,d),Vector3.new(0,1+h/2,0),color,h>8 and Enum.Material.Brick or Enum.Material.WoodPlanks,true)
 p("StonePlinth",Vector3.new(w+.2,.45,d+.2),Vector3.new(0,1.225,0),cream,Enum.Material.Concrete)
 p("FlatRoof",Vector3.new(w+.8,.45,d+.8),Vector3.new(0,h+1.23,0),ink,Enum.Material.Slate,true)
 for _,side in {-1,1}do
  p("RoofCoping",Vector3.new(w+1,.25,.3),Vector3.new(0,h+1.6,side*(d/2+.35)),cream,Enum.Material.Concrete)
  p("RoofCoping",Vector3.new(.3,.25,d+1),Vector3.new(side*(w/2+.35),h+1.6,0),cream,Enum.Material.Concrete)
 end
 local front=-d/2-.15
 if h>8 then
  for _,side in {-1,1}do p("CornerQuoin",Vector3.new(.35,h,.35),Vector3.new(side*(w/2-.18),1+h/2,front),cream)end
  for y=12,h-1,7 do
   for _,dx in {-w*.27,w*.27}do
    p("WindowFrame",Vector3.new(3.6,3.8,.16),Vector3.new(dx,y,front-.06),cream)
    p("WindowPane",Vector3.new(3.1,3.3,.12),Vector3.new(dx,y,front-.2),glass)
    p("Mullion",Vector3.new(.1,3.3,.08),Vector3.new(dx,y,front-.3),cream)
   end
   for _,side in {-1,1}do p("SideWindow",Vector3.new(.12,3.2,2.8),Vector3.new(side*(w/2+.1),y,0),glass)end
  end
 end
 local dx=-w*.27
 p("DoorFrame",Vector3.new(3.4,5.8,.18),Vector3.new(dx,3.95,front-.06),cream)
 p("Door",Vector3.new(2.9,5.3,.12),Vector3.new(dx,3.95,front-.21),accent)
 p("DoorHandle",Vector3.new(.1,.65,.12),Vector3.new(dx+.95,3.7,front-.31),brass)
 p("DisplayFrame",Vector3.new(w*.46,4.8,.18),Vector3.new(w*.18,3.9,front-.06),cream)
 p("DisplayPane",Vector3.new(w*.46-.45,4.35,.12),Vector3.new(w*.18,3.9,front-.21),glass)
 p("Canopy",Vector3.new(w-.5,.25,2.8),Vector3.new(0,7.4,front-1.1),accent,Enum.Material.Metal)
 local board=p("BusinessSign",Vector3.new(w-.8,1.3,.22),Vector3.new(0,h>8 and 8.6 or 6.6,front-.25),accent)
 sign(board,title,id.." / "..(district=="BrickQuay"and"BATA QUAY"or district=="OldTown"and"KOTA LAMA"or"CIVIC GARDENS"))
 if h>8 then
  p("Cornice",Vector3.new(w+.35,.3,d+.35),Vector3.new(0,9.6,0),cream)
  p("RainPipe",Vector3.new(.13,h,.13),Vector3.new(w/2-.2,1+h/2,d/2+.15),ink,Enum.Material.Metal)
  local side=p("ProjectingSign",Vector3.new(.15,2.4,2),Vector3.new(w/2+.7,10.6,front),accent)
  p("SignBracket",Vector3.new(1.7,.13,.15),Vector3.new(w/2+.6,12,front),ink,Enum.Material.Metal)
 end
 finish(m,r.Infill)
 local point=part(r.FutureAddresses,id,Vector3.new(3,.1,3),cf*CFrame.new(dx,1,-d/2-2.8),accent)
 point.Transparency=1 point:SetAttribute("DisplayName",title)point:SetAttribute("District",district)point:SetAttribute("CandidateOnly",true)point:SetAttribute("AddressId36",id)
 game.CollectionService:AddTag(point,"FutureDelivery36")
 return m
end
function A.Buildings()
 local _,r,b=ctx()assert(#r.Infill:GetChildren()==0,"Infill already exists")
 for i,s in specs do building(r,b,s,i)end
 return {buildings=#specs,candidateAddresses=#r.FutureAddresses:GetChildren()}
end
local function cleanTemplate(parent,b,lib,key,id,x,z,h,yaw)
 local m=SS["PaketKilat_CreatorAssets"..lib][key]:Clone()m.Name=id
 for _,p in m:GetDescendants()do
  if p:IsA("LuaSourceContainer")or p:IsA("Light")or p:IsA("Constraint")or p:IsA("JointInstance")or p:IsA("Sound")then p:Destroy()
  elseif p:IsA("BasePart")then p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false end
 end
 local cf,size=m:GetBoundingBox()m:ScaleTo(m:GetScale()*h/size.Y)cf,size=m:GetBoundingBox()
 m:PivotTo(b*CFrame.new(x,1+size.Y/2,z)*CFrame.Angles(0,math.rad(yaw or 0),0)*CFrame.new(-cf.Position)*m:GetPivot())
 m:SetAttribute("SupportY36",b.Position.Y+1)m:SetAttribute("PublicRealm36",true)
 finish(m,parent)return m
end
function A.PublicRealm()
 local _,r,b=ctx()assert(not r.PublicRealm:FindFirstChild("StreetFurniture36"))
 local f=Instance.new("Folder")f.Name="StreetFurniture36"f.Parent=r.PublicRealm
 local lamps={{-121,45,180},{-121,95,180},{-121,129,180},{122,45,0},{122,82,0},{122,130,0},{-75,166,0},{62,170,180},{-65,298,90},{2,298,90},{80,298,90}}
 for i,v in lamps do cleanTemplate(f,b,"09","StreetLamp","LoopLamp"..i,v[1],v[2],9,v[3])end
 for i,v in {{-109,84},{-53,131},{-43,12},{83,12},{-72,205},{58,252}}do cleanTemplate(f,b,"07","BroadleafTree","InfillTree"..i,v[1],v[2],12+i%3,27*i)end
 for i,v in {{-73,170,180},{42,170,180},{-81,305,0},{-16,305,0},{61,305,0}}do cleanTemplate(f,b,"07","ParkBench","CityBench"..i,v[1],v[2],2.8,v[3])end
 for i,v in {{-53,48},{9,51},{-74,158},{63,158}}do cleanTemplate(f,b,"09","GardenBush","LowShrub"..i,v[1],v[2],2,0)end
 for i,v in {{-77,160,90},{66,161,90}}do cleanTemplate(f,b,"32","Bicycle","ParkedBicycle"..i,v[1],v[2],3.2,v[3])end
 -- Bistro seating at the corner cafe; physical feet stand on the existing paving.
 for _,v in {{-347,201},{-281,211},{-406.5,251}}do
  local m=Instance.new("Model")m.Name="CafeBistro"
  local cf=b*CFrame.new(v[1],0,v[2])
  local top=part(m,"RoundTable",Vector3.new(.18,2.5,2.5),cf*CFrame.new(0,3.1,0)*CFrame.Angles(0,0,math.pi/2),cream,Enum.Material.Wood)
  top.Shape=Enum.PartType.Cylinder
  part(m,"TableStem",Vector3.new(.18,2,.18),cf*CFrame.new(0,2,0),ink,Enum.Material.Metal)
  part(m,"TableFoot",Vector3.new(1.5,.08,1.5),cf*CFrame.new(0,1.04,0),ink,Enum.Material.Metal)
  for _,x in {-2.2,2.2}do
   part(m,"ChairSeat",Vector3.new(1.5,.18,1.5),cf*CFrame.new(x,2.25,0),Color3.fromRGB(129,88,62),Enum.Material.WoodPlanks)
   for _,dx in {-.55,.55}do for _,z in {-.55,.55}do part(m,"ChairLeg",Vector3.new(.1,1.2,.1),cf*CFrame.new(x+dx,1.6,z),ink,Enum.Material.Metal)end end
   part(m,"ChairBack",Vector3.new(.14,1.6,1.5),cf*CFrame.new(x+(x<0 and -.65 or .65),3,0),ink,Enum.Material.Metal)
  end
  finish(m,f)
 end
 -- Two tree-sided civic loading spaces, marked without adding an overlapping asphalt slab.
 for _,v in {{-71,184},{98,264}}do
  local m=Instance.new("Model")m.Name="LoadingBay"
  for _,x in {-4.8,4.8}do part(m,"BayLine",Vector3.new(.12,.035,11),b*CFrame.new(v[1]+x,1.03,v[2]),cream)end
  for _,z in {-5.5,5.5}do part(m,"BayLine",Vector3.new(9.7,.035,.12),b*CFrame.new(v[1],1.03,v[2]+z),cream)end
  finish(m,f)
 end
 return #f:GetChildren()
end
function A.Streets()
 local _,r,b=ctx()assert(not r.Streets:FindFirstChild("Paint36"))
 local f=Instance.new("Folder")f.Name="Paint36"f.Parent=r.Streets
 local batch=Instance.new("Model")batch.Name="LoopMarkings"
 for _,x in {-130,132}do
  for z=44,130,10 do part(batch,"CentreDash",Vector3.new(.16,.035,3.8),b*CFrame.new(x,1.03,z),cream)end
  for _,z in {39,132}do for k=-2,2 do
   part(batch,"LoopCrossing",Vector3.new(.9,.035,3),b*CFrame.new(x+k*1.8,1.03,z),cream)
  end end
 end
 finish(batch,f)
 for i,v in {{-117,40,"JALAN LINGKAR","KOTA LAMA"},{120,134,"JALAN KANAL","KE BATA QUAY"},{-14,40,"JALAN POS","DEPOT / PASAR"}}do
  local m=Instance.new("Model")m.Name="StreetSign"..i
  part(m,"Post",Vector3.new(.18,5,.18),b*CFrame.new(v[1],3.5,v[2]),ink,Enum.Material.Metal)
  local p=part(m,"StreetPlate",Vector3.new(7,1.5,.18),b*CFrame.new(v[1],5.2,v[2]),ink)sign(p,v[3],v[4])finish(m,f)
 end
 -- Each shophouse receives a small side-mounted address flag with a real bracket.
 local quay=workspace.PaketKilat.Map.Districts35.BrickQuay
 local count=0
 for _,m in quay:GetChildren()do
  count+=1
  if count%3~=1 then continue end
  local body=m:FindFirstChild("BrickBody")
  if body then local cf=body.CFrame*CFrame.new(body.Size.X/2+.7,10-body.Size.Y/2,-body.Size.Z/2)
   local g=Instance.new("Model")g.Name="QuayAddressFlag"
   part(g,"Bracket",Vector3.new(1.8,.12,.12),cf,ink,Enum.Material.Metal)
   local board=part(g,"Flag",Vector3.new(.15,2.2,1.8),cf*CFrame.new(.4,-1,0),Color3.fromRGB(117,87,67))
   local gui=Instance.new("SurfaceGui")gui.Face=Enum.NormalId.Right gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud gui.PixelsPerStud=35 gui.MaxDistance=70 gui.Parent=board
   local text=Instance.new("TextLabel")text.Size=UDim2.fromScale(1,1)text.BackgroundTransparency=1 text.Text=m:GetAttribute("AddressId35")or"BQ"text.Font=Enum.Font.GothamBold text.TextScaled=true text.TextColor3=cream text.Parent=gui
   finish(g,f)
  end
 end
 return #f:GetChildren()
end
function A.PocketPlanting()
 local _,r,b=ctx()local f=Instance.new("Folder")f.Name="PocketPlanting36"f.Parent=r.PublicRealm
 for i,v in {{-356,208},{-319,189},{-288,204},{-256,189}}do cleanTemplate(f,b,"09","GardenBush","QuayShrub"..i,v[1],v[2],1.8,30*i)end
 return #f:GetChildren()
end
function A.Grounding()
 local m,r,b=ctx()local models={}
 for _,v in r.PublicRealm:GetDescendants()do if v:IsA("Model")and v:GetAttribute("PublicRealm36")then table.insert(models,v)end end
 for _,f in {m.CityDecor15,m.City32}do for _,v in f:GetChildren()do
  if v:IsA("Model")and(string.match(v.Name,"^ShadeTree")or string.match(v.Name,"^NeighbourhoodTree")or string.match(v.Name,"^Bench%d")or v.Name=="EastGardenBench"or v.Name=="EastGardenLamp"or v.Name=="KebunBench"or v.Name=="ParkPicnic"or v.Name=="GardenPicnic")then table.insert(models,v)end
 end end
 local result={models=#models,bad={},adjusted={}}
 for _,v in models do
  local lowest=math.huge
  for _,p in v:GetDescendants()do if p:IsA("BasePart")and p.Transparency<.95 then
   for _,x in {-1,1}do for _,y in {-1,1}do for _,z in {-1,1}do lowest=math.min(lowest,p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2).Y)end end end
  end end
  local delta=b.Position.Y+1-lowest
  if math.abs(delta)>.025 and math.abs(delta)<3 then
   -- Snapshot old free-standing props before normalization.
   if not v:GetAttribute("PublicRealm36")then local ref=Instance.new("ObjectValue")ref.Name=v.Name ref.Value=v ref:SetAttribute("Pivot36",v:GetPivot())ref.Parent=SS.PaketKilat_PreCity36:FindFirstChild("Changed")end
   v:PivotTo(v:GetPivot()+Vector3.new(0,delta,0))table.insert(result.adjusted,{v.Name,delta})
  end
  if math.abs(delta)>=3 then table.insert(result.bad,{v.Name,delta})end
  v:SetAttribute("SupportY36",b.Position.Y+1)
  task.wait()
 end
 return result
end
function A.Finalize()
 local m,r,b=ctx()
 require(SS.PaketKilat_District35Authoring.Details).SyncAddresses()
 r:SetAttribute("CandidateOnly",true)r:SetAttribute("AdditionalAddressCount",#r.FutureAddresses:GetChildren())
 r:SetAttribute("GroundTopY",b.Position.Y+1)
 workspace.PaketKilat:SetAttribute("CityRevision","CoherentCity36")
 return {newAddresses=#r.FutureAddresses:GetChildren(),totalCandidates=#r.FutureAddresses:GetChildren()+#m.Districts35.FutureAddresses:GetChildren()}
end

function A.Merchandise()
 local _,r=ctx()assert(not r.PublicRealm:FindFirstChild("ShopDisplays36"))
 local f=Instance.new("Folder")f.Name="ShopDisplays36"f.Parent=r.PublicRealm
 for _,owner in r.Infill:GetChildren()do
  local body=owner.Body local w,h,d=body.Size.X,body.Size.Y,body.Size.Z
  local cf=body.CFrame*CFrame.new(0,-1-h/2,0)
  local id=owner:GetAttribute("AddressId36")local m=Instance.new("Model")m.Name=id.."_Display"
  local x,z=w*.18,-d/2-.8
  local function p(n,size,v,c,mat,rot)
   return part(m,n,size,cf*CFrame.new(v)*(rot or CFrame.identity),c,mat)
  end
  local function cylinder(n,height,diam,v,c)
   local q=p(n,Vector3.new(height,diam,diam),v,c,Enum.Material.SmoothPlastic,CFrame.Angles(0,0,math.pi/2))q.Shape=Enum.PartType.Cylinder return q
  end
  p("CounterTop",Vector3.new(w*.44,.18,1.4),Vector3.new(x,2.65,z),cream,Enum.Material.WoodPlanks)
  for _,dx in {-w*.17,w*.17}do p("CounterLeg",Vector3.new(.18,1.55,.85),Vector3.new(x+dx,1.775,z),ink,Enum.Material.Metal)end
  if id=="PK03"or id=="CQ02"then
   for i=-1,1 do
    cylinder("TerracottaPot",.65,.65,Vector3.new(x+i*1.4,3.06,z),Color3.fromRGB(163,91,66))
    p("FlowerStem",Vector3.new(.06,.9,.06),Vector3.new(x+i*1.4,3.8,z),Color3.fromRGB(68,112,65))
    for j=0,4 do local angle=j*math.pi*2/5
     local q=p("FlowerPetal",Vector3.new(.28,.22,.28),Vector3.new(x+i*1.4+math.sin(angle)*.2,4.23,z+math.cos(angle)*.2),i==0 and brass or i==1 and Color3.fromRGB(210,126,116)or cream)
     local mesh=Instance.new("SpecialMesh")mesh.MeshType=Enum.MeshType.Sphere mesh.Parent=q
    end
   end
  elseif id=="PK01"then
   for i=-1,1 do for j=0,2 do
    local q=p("NewspaperBundle",Vector3.new(1.15,.12,.85),Vector3.new(x+i*1.4,2.86+j*.13,z),i==0 and Color3.fromRGB(179,188,169)or cream)
    if j==2 then local g=Instance.new("SurfaceGui")g.Face=Enum.NormalId.Top g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.PixelsPerStud=55 g.MaxDistance=35 g.Parent=q
     local t=Instance.new("TextLabel")t.Size=UDim2.fromScale(1,1)t.BackgroundTransparency=1 t.Text="KOTA\nHARI INI"t.TextScaled=true t.TextColor3=ink t.Font=Enum.Font.GothamBold t.Parent=g
    end
   end end
  elseif id=="OT01"then
   for i=-2,2 do cylinder("FabricRoll",.9,.6,Vector3.new(x+i*.8,3.22,z),({cream,brass,Color3.fromRGB(102,140,137)})[(i+2)%3+1])end
  elseif id=="OT02"then
   for i=-1,1 do
    p("Parcel",Vector3.new(1.3,.8,1),Vector3.new(x+i*1.7,3.14,z),Color3.fromRGB(178,131,79),Enum.Material.Cardboard)
    p("PackingTape",Vector3.new(.17,.015,1.02),Vector3.new(x+i*1.7,3.55,z),cream)
   end
  elseif id=="CQ03"then
   for i=-1,1 do
    local q=p("VinylDisc",Vector3.new(.08,1.3,1.3),Vector3.new(x+i*1.5,3.45,z),ink,Enum.Material.SmoothPlastic,CFrame.Angles(0,math.pi/2,0))q.Shape=Enum.PartType.Cylinder
    local c=p("RecordLabel",Vector3.new(.1,.36,.36),Vector3.new(x+i*1.5,3.45,z-.06),brass,Enum.Material.SmoothPlastic,CFrame.Angles(0,math.pi/2,0))c.Shape=Enum.PartType.Cylinder
   end
  elseif id=="CV02"then
   for i=-1,1 do
    p("ArtFrame",Vector3.new(1.5,1.9,.15),Vector3.new(x+i*1.6,3.7,z),ink)
    p("Canvas",Vector3.new(1.3,1.7,.08),Vector3.new(x+i*1.6,3.7,z-.12),cream)
    p("Artwork",Vector3.new(.7,.85,.06),Vector3.new(x+i*1.6+.2,3.6,z-.2),i<0 and brass or Color3.fromRGB(90,130,127))
   end
  else
   for i=-1,1 do cylinder("TeaCup",.65,.45,Vector3.new(x+i*1.3,3.08,z),cream)
    cylinder("TeaLid",.06,.5,Vector3.new(x+i*1.3,3.44,z),brass)
   end
   cylinder("TeaCanister",1.25,.65,Vector3.new(x,3.4,z+.15),Color3.fromRGB(72,112,93))
  end
  if h>8 then
   for y=12,h-1,7 do for _,dx in {-w*.27,w*.27}do
    p("RearWindowFrame",Vector3.new(2.8,3.5,.15),Vector3.new(dx,y,d/2+.1),cream)
    p("RearWindow",Vector3.new(2.4,3.1,.1),Vector3.new(dx,y,d/2+.22),glass)
   end end
  end
  finish(m,owner)
  local ref=Instance.new("ObjectValue")ref.Name=id ref.Value=m ref.Parent=f
 end
 return #f:GetChildren()
end
return A
