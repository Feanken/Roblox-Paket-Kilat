-- City32 finishing: mounted details, denser planting, physical stall signs.
assert(not game:GetService("RunService"):IsRunning(),"Edit only")
local map=workspace.PaketKilat.Map local root=map.City32 local basis=map.DepotPad.CFrame
assert(not root:FindFirstChild("HouseEntries"),"Finishing already installed")
local cream=Color3.fromRGB(236,224,199)local teal=Color3.fromRGB(44,101,102)
local wood=Color3.fromRGB(128,86,59)local green=Color3.fromRGB(91,139,93)
local coral=Color3.fromRGB(205,116,86)local gold=Color3.fromRGB(224,182,76)
local function part(m,name,size,v,color)
 local p=Instance.new("Part")p.Name=name p.Size=size p.CFrame=basis*CFrame.new(v)p.Color=color or cream
 p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.Material=Enum.Material.SmoothPlastic p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=m return p
end
local function sign(p,s,face)
 local g=Instance.new("SurfaceGui")g.Face=face or Enum.NormalId.Back g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud g.PixelsPerStud=40 g.MaxDistance=95 g.LightInfluence=.35 g.ZOffset=.1 g.Parent=p
 local l=Instance.new("TextLabel")l.BackgroundTransparency=1 l.Position=UDim2.fromScale(.03,.08)l.Size=UDim2.fromScale(.94,.84)l.Font=Enum.Font.GothamBold l.TextColor3=cream l.TextScaled=true l.Text=s l.Parent=g
end
for _,name in {"TOKO ROTI","RUMAH SUSUN","BENGKEL","TOKO BUKU","KANTOR KAMPUNG"}do
 local body=map.City13[name].Body local c=basis:PointToObjectSpace(body.Position)local front=c.Z-body.Size.Z/2-.22
 local m=root[name.."_Details"]
 for _,p in m:GetChildren()do
  if p.Name=="WindowBoxBracket"then local v=basis:PointToObjectSpace(p.Position)p.Size=Vector3.new(.13,.65,.9)p.CFrame=basis*CFrame.new(v.X,v.Y,front-.1)
  elseif p.Name=="PipeClip"then local v=basis:PointToObjectSpace(p.Position)p.Size=Vector3.new(.38,.12,.75)p.CFrame=basis*CFrame.new(v.X,v.Y,front+.02)
  elseif p.Name=="RoofVentBase"or p.Name=="RoofVent"or p.Name=="VentRainCap"then p.CFrame+=Vector3.new(0,-.475,0)end
 end
end
local workshop=root.BengkelWorkshop
for _,y in {3,5.6}do part(workshop,"ToolBoardMount",Vector3.new(.5,.18,4.3),Vector3.new(88.2,y,65),teal)end
local flowerAudit={}
for _,name in {"KebunWarga","TamanTimur","KebunPiknik"}do
 local garden=root:FindFirstChild(name)
 if garden then
  local bed=garden.TerracottaBed local c=basis:PointToObjectSpace(bed.Position)
  local longX=bed.Size.X>bed.Size.Z local soilY=c.Y+.355
  -- Complete both faces of the bed so the flowers are visible from the sidewalk.
  for j=-1,1 do for k=-1,1 do
   local fx=c.X+(longX and j*bed.Size.X/3+k*.7 or -1.3)
   local fz=c.Z+(longX and -1.25 or j*bed.Size.Z/3+k*.7)
   part(garden,"FlowerStem",Vector3.new(.09,.6,.09),Vector3.new(fx,soilY+.3,fz),green)
   local p=part(garden,"Flower",Vector3.new(.4,.23,.4),Vector3.new(fx,soilY+.65,fz),k==0 and gold or cream)p.Shape=Enum.PartType.Ball
  end end
  for _,j in {-1,1}do
   local shrub=garden:FindFirstChild("GardenShrub0"):Clone()shrub.Name="InfillShrub"..j
   local offset=Vector3.new(longX and j*bed.Size.X/6 or 0,0,longX and 0 or j*bed.Size.Z/6)
   shrub:PivotTo(shrub:GetPivot()+basis:VectorToWorldSpace(offset))shrub.Parent=garden
   table.insert(flowerAudit,shrub.Name..":"..name)
  end
 end
 task.wait()
end
local oldSign=root:FindFirstChild("StreetName_PASAR PAGI")
if oldSign then for _,p in oldSign:GetChildren()do if p:IsA("BasePart")then p.CFrame+=basis:VectorToWorldSpace(Vector3.new(18,0,0))end end end
-- Lower hanging signs replace the three floating market labels, preserving their states for rollback.
local backup=Instance.new("Folder")backup.Name="PaketKilat_PreCity32Signs"backup.Parent=game.ServerStorage
local signs=Instance.new("Model")signs.Name="MarketHangingSigns"signs.Parent=root
for _,roof in map.City13:GetChildren()do if roof.Name=="MarketAwning"then
 local c=basis:PointToObjectSpace(roof.Position)
 for _,g in roof:GetChildren()do if g:IsA("BillboardGui")then
  local ref=Instance.new("ObjectValue")ref.Name="OriginalMarketBillboard";ref.Value=g;ref:SetAttribute("WasEnabled",g.Enabled);ref.Parent=backup;g.Enabled=false
 end end
 local title=c.X<30 and "ROTI HANGAT"or c.X<60 and "SAYUR SEGAR"or "BUAH SEGAR"
 for _,dx in {-5.5,5.5}do part(signs,"SignHanger",Vector3.new(.12,.65,.12),Vector3.new(c.X+dx,8.45,c.Z+5.8),teal)end
 local p=part(signs,"StallNameBoard",Vector3.new(13.6,1.25,.22),Vector3.new(c.X,7.55,c.Z+5.8),teal)sign(p,title)
end end
-- Lift festoon above canopy and ensure pennants hang down from the wire.
for _,p in root.MarketFestoon:GetChildren()do
 if p.Name=="FestoonPost"then p.Size+=Vector3.new(0,2.5,0)p.CFrame+=Vector3.new(0,1.25,0)
 elseif p.Name~="FestoonFoot"then p.CFrame+=Vector3.new(0,2.5,0)end
end
-- Bespoke house entries attach directly to walls; delivery/NPC floor zones remain empty.
local entries=Instance.new("Folder")entries.Name="HouseEntries"entries.Parent=root
for index,name in {"Rumah01","Rumah02","Rumah03","Rumah04","Rumah05"}do
 local m=Instance.new("Model")m.Name=name.."_Entry"local body=map[name].Body local c=basis:PointToObjectSpace(body.Position)local z=c.Z+body.Size.Z/2
 for _,dx in {-1.7,1.7}do part(m,"DoorJamb",Vector3.new(.2,6,.5),Vector3.new(c.X+dx,4,z+.2),cream)end
 part(m,"DoorLintel",Vector3.new(3.6,.24,.5),Vector3.new(c.X,7.12,z+.2),cream)
 local plaque=part(m,"HouseNumber",Vector3.new(1,.55,.2),Vector3.new(c.X+2.4,3.6,z+.12),teal)sign(plaque,string.format("%02d",index))
 part(m,"PorchLightMount",Vector3.new(.45,.65,.2),Vector3.new(c.X-2.25,3.8,z+.1),teal)
 part(m,"PorchLightGlass",Vector3.new(.3,.4,.25),Vector3.new(c.X-2.25,3.8,z+.3),gold)
 part(m,"PorchLightCap",Vector3.new(.65,.12,.5),Vector3.new(c.X-2.25,4.18,z+.22),teal)
 m.Parent=entries task.wait()
end
for _,g in root:GetDescendants()do if g:IsA("SurfaceGui")then g.ZOffset=.1 end end
local count=0 for _,p in root:GetDescendants()do if p:IsA("BasePart")then count+=1 end end
root:SetAttribute("Finishing32",true)
return {parts=count,signBackups=#backup:GetChildren(),infillShrubs=#flowerAudit}
