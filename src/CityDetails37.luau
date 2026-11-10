-- City37 Edit-only art; the client creates its own decorative citizens.
local B={}
local SS=game:GetService("ServerStorage")
local cream=Color3.fromRGB(231,221,199)local ink=Color3.fromRGB(47,67,69)
local glass=Color3.fromRGB(108,153,163)
local function part(m,n,size,cf,color,mat,shadow)
 local p=Instance.new("Part")p.Name=n p.Size=size p.CFrame=cf p.Color=color or cream p.Material=mat or Enum.Material.SmoothPlastic
 p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=shadow==true p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=m return p
end
local function ctx()assert(not game.RunService:IsRunning(),"Edit only")local m=workspace.PaketKilat.Map return m,m.City37,m.DepotPad.CFrame end
function B.Setup()
 local m=workspace.PaketKilat.Map assert(not m:FindFirstChild("City37"),"City37 already exists")
 local backup=Instance.new("Folder")backup.Name="PaketKilat_PreCity37"backup.Parent=SS
 local snapshot={anchors={},models={},attributes=workspace.PaketKilat:GetAttributes()}
 for _,p in m:GetDescendants()do if p:IsA("BasePart")and(p.Name=="PickupPoint"or p.Name=="DestinationPoint"or p.Name=="RecoveryPoint"or p.Name=="PrototypeSpawn"or p:IsDescendantOf(m.RestStops27)or p:IsDescendantOf(m.City13.Stations))then table.insert(snapshot.anchors,{path=p:GetFullName(),cf={p.CFrame:GetComponents()},size={p.Size.X,p.Size.Y,p.Size.Z}})end end
 for _,f in {m.Districts35.BrickQuay,m.Districts35.CivicCentre,m.City36.Infill}do for _,v in f:GetChildren()do local body=v:FindFirstChild("BrickBody")or v:FindFirstChild("OfficeBody")or v:FindFirstChild("Body")
  if body then table.insert(snapshot.models,{path=body:GetFullName(),cf={body.CFrame:GetComponents()},size={body.Size.X,body.Size.Y,body.Size.Z}})end
 end end
 local s=Instance.new("StringValue")s.Name="Snapshot"s.Value=game.HttpService:JSONEncode(snapshot)s.Parent=backup
 local hud=game.StarterGui:FindFirstChild("PaketKilatUI")
 if hud then local previous=Instance.new("BoolValue")previous.Name="OriginalHudEnabled37"previous.Value=hud.Enabled previous.Parent=backup hud.Enabled=true end
 local old=game.StarterPlayer.StarterPlayerScripts:FindFirstChild("PaketKilatCityLife15")
 if old then old:SetAttribute("OriginalParent37",old.Parent:GetFullName())old.Parent=backup end
 local r=Instance.new("Folder")r.Name="City37"r.Parent=m
 local refs=Instance.new("Folder")refs.Name="ArtReferences"refs.Parent=r
 r:SetAttribute("Revision","LivingStreets37")
 return {anchors=#snapshot.anchors,models=#snapshot.models,retiredOldResidents=old~=nil}
end
local function attach(m,parent,refs)
 m:SetAttribute("City37",true)m.Parent=parent
 local ref=Instance.new("ObjectValue")ref.Name=parent.Name.."_"..m.Name ref.Value=m ref.Parent=refs task.wait()
end
function B.Facades()
 local m,r,b=ctx()local refs=r.ArtReferences local count=0
 local sides={BQ01=-1,BQ06=1,BQ07=-1,BQ08=1,BQ09=-1,BQ10=1,BQ11=-1,BQ16=1}
 for _,owner in m.Districts35.BrickQuay:GetChildren()do
  local id=owner:GetAttribute("AddressId35")local side=sides[id]
  local rear=tonumber(string.sub(id or"",3))and tonumber(string.sub(id,3))>=11
  if not side and not rear then continue end
  assert(not owner:FindFirstChild("Facade37"),"Facade already authored")
  local g=Instance.new("Model")g.Name="Facade37"
  local body=owner.BrickBody local base=body.CFrame*CFrame.new(0,-1-body.Size.Y/2,0)
  local w,h,d=body.Size.X,body.Size.Y,body.Size.Z
  if side then for y=12,h-2,7 do for _,z in {-6,0,6}do
   local cf=base*CFrame.new(side*(w/2+.14),y,z)*CFrame.Angles(0,-side*math.pi/2,0)
   part(g,"SideStoneFrame",Vector3.new(3.6,4.2,.18),cf,cream)
   part(g,"SideWindowPane",Vector3.new(3.05,3.65,.12),cf*CFrame.new(0,0,-.15),glass)
   part(g,"SideMullion",Vector3.new(.12,3.65,.08),cf*CFrame.new(0,0,-.25),cream)
   part(g,"StoneSill",Vector3.new(3.8,.22,.6),cf*CFrame.new(0,-2.1,-.08),cream,Enum.Material.Concrete)
  end end end
  if rear then for _,p in owner:GetChildren()do if p.Name=="RearWindow"then
   part(g,"RearStoneFrame",Vector3.new(3.55,4.35,.1),p.CFrame*CFrame.new(0,0,-.09),cream)
   part(g,"RearMullion",Vector3.new(.12,3.8,.08),p.CFrame*CFrame.new(0,0,.12),cream)
   part(g,"RearSill",Vector3.new(3.6,.22,.5),p.CFrame*CFrame.new(0,-2.05,.03),cream,Enum.Material.Concrete)
  end end end
  count+=#g:GetChildren()attach(g,owner,refs)
 end
 return count
end
function B.Parasols()
 local m,r,b=ctx()local count=0
 for _,tableGroup in m.City36.PublicRealm.StreetFurniture36:GetChildren()do
  if tableGroup.Name~="CafeBistro"then continue end
  assert(not tableGroup:FindFirstChild("Parasol37"),"Parasol already authored")
  local position=b:PointToObjectSpace(tableGroup.RoundTable.Position)
  local cf=b*CFrame.new(position.X,0,position.Z)
  local g=Instance.new("Model")g.Name="Parasol37"
  part(g,"Pole",Vector3.new(.12,4.35,.12),cf*CFrame.new(0,5.4,0),ink,Enum.Material.Metal)
  local color=({Color3.fromRGB(51,107,104),Color3.fromRGB(205,161,87),Color3.fromRGB(165,96,74)})[count+1]
  local canopy=part(g,"FabricCanopy",Vector3.new(7,.8,7),cf*CFrame.new(0,7.65,0),color,Enum.Material.Fabric,true)
  local mesh=Instance.new("SpecialMesh")mesh.MeshType=Enum.MeshType.Sphere mesh.Parent=canopy
  local cap=part(g,"TopFinial",Vector3.new(.28,.28,.28),cf*CFrame.new(0,8.08,0),ink)
  local ball=Instance.new("SpecialMesh")ball.MeshType=Enum.MeshType.Sphere ball.Parent=cap
  for i=0,7 do
   local angle=i*math.pi/4 local a=(cf*CFrame.new(0,7.62,0)).Position
   local c=(cf*CFrame.new(math.cos(angle)*3.3,7.45,math.sin(angle)*3.3)).Position
   part(g,"CanopyRib",Vector3.new(.035,.035,(c-a).Magnitude),CFrame.lookAt((a+c)/2,c),cream,Enum.Material.Metal)
  end
  attach(g,tableGroup,r.ArtReferences)count+=1
 end
 return count
end
return B
