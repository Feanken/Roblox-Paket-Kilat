-- Client-only decorative residents: one bounded controller, no Humanoids or gameplay remotes.
local M={}
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local active
local skin={Color3.fromRGB(207,160,123),Color3.fromRGB(170,118,85),Color3.fromRGB(228,185,147)}
local shirts={Color3.fromRGB(58,120,116),Color3.fromRGB(205,156,78),Color3.fromRGB(109,106,151),Color3.fromRGB(171,108,83),Color3.fromRGB(99,131,104),Color3.fromRGB(76,108,137)}
local ink=Color3.fromRGB(44,53,57)local cream=Color3.fromRGB(234,224,204)
function M.Sample(spec,time)
 if spec.Mode~="Walk"then
  local angle=math.rad(spec.Yaw or 0)
  return spec.A,Vector2.new(-math.sin(angle),-math.cos(angle)),false
 end
 local delta=spec.B-spec.A local length=delta.Magnitude
 if length<.01 then return spec.A,Vector2.new(0,-1),false end
 local direction=delta.Unit local travel=length/spec.Speed local wait=spec.Dwell
 local phase=(time+spec.Phase)%(2*travel+2*wait)
 if phase<wait then return spec.A,direction,false end
 phase-=wait
 if phase<travel then return spec.A+direction*(phase*spec.Speed),direction,true end
 phase-=travel
 if phase<wait then return spec.B,-direction,false end
 phase-=wait
 return spec.B-direction*(phase*spec.Speed),-direction,true
end
local function create(spec,parent)
 local model=Instance.new("Model")model.Name=spec.Id model.Archivable=false
 model:SetAttribute("CosmeticOnly",true)model:SetAttribute("ResidentId37",spec.Id)model:SetAttribute("District",spec.District)
 local parts={}
 local function p(name,size,color,sphere)
  local v=Instance.new("Part")v.Name=name v.Size=size v.Color=color v.Material=Enum.Material.SmoothPlastic
  v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=false v.CastShadow=false
  if sphere then local mesh=Instance.new("SpecialMesh")mesh.MeshType=Enum.MeshType.Sphere mesh.Parent=v end
  v.Parent=model parts[name]=v return v
 end
 local style=spec.Style local tone=skin[(style-1)%#skin+1]
 p("Torso",Vector3.new(1.5,1.65,.8),shirts[(style-1)%#shirts+1])
 p("Head",Vector3.new(1.08,1.1,1.08),tone,true)
 p("Hair",Vector3.new(1.13,.26,1.05),style%3==0 and Color3.fromRGB(100,70,43)or ink)
 if style%3==0 then p("BackHair",Vector3.new(1.08,.8,.27),Color3.fromRGB(100,70,43))end
 for _,side in {"Left","Right"}do
  p(side.."Arm",Vector3.new(.45,1.5,.54),tone)
  p(side.."Leg",Vector3.new(.55,spec.Mode=="Sit"and 1.4 or 1.65,.64),Color3.fromRGB(50,68,77))
  if spec.Mode=="Sit"then p(side.."Thigh",Vector3.new(.56,.5,1.15),Color3.fromRGB(50,68,77))end
  p(side.."Shoe",Vector3.new(.61,.24,.85),ink)
  p(side.."Eye",Vector3.new(.09,.1,.06),ink)
 end
 p("Smile",Vector3.new(.22,.045,.05),ink)
 if spec.Prop=="Cup"then local q=p("Cup",Vector3.new(.56,.42,.42),cream)q.Shape=Enum.PartType.Cylinder p("CupLid",Vector3.new(.06,.46,.46),Color3.fromRGB(190,149,78)).Shape=Enum.PartType.Cylinder
 elseif spec.Prop=="Book"then p("Book",Vector3.new(1.3,.9,.16),Color3.fromRGB(87,127,121))p("BookPages",Vector3.new(1.13,.72,.07),cream)
 elseif spec.Prop=="Bag"then p("ShoppingBag",Vector3.new(.82,1.1,.45),Color3.fromRGB(182,145,95))p("BagHandle",Vector3.new(.48,.35,.09),cream)end
 model.Parent=parent
 return {model=model,p=parts,spec=spec}
end
local function pose(actor,cf,time,moving)
 local p,s=actor.p,actor.spec local sway=moving and math.sin(time*7+s.Phase)*.38 or 0
 local bob=moving and math.abs(math.sin(time*7+s.Phase))*.045 or 0
 local seated=s.Mode=="Sit"
 local torsoY=seated and 2.18 or 2.63 local headY=seated and 3.65 or 4.1
 cf=cf*CFrame.new(0,bob,0)
 p.Torso.CFrame=cf*CFrame.new(0,torsoY,0)
 p.Head.CFrame=cf*CFrame.new(0,headY,0)
 p.Hair.CFrame=cf*CFrame.new(0,headY+.45,0)
 if p.BackHair then p.BackHair.CFrame=cf*CFrame.new(0,headY,.43)end
 p.LeftEye.CFrame=cf*CFrame.new(-.2,headY+.06,-.52)
 p.RightEye.CFrame=cf*CFrame.new(.2,headY+.06,-.52)
 p.Smile.CFrame=cf*CFrame.new(0,headY-.13,-.54)
 for _,side in {-1,1}do
  local name=side<0 and"Left"or"Right"
  if seated then
   p[name.."Leg"].CFrame=cf*CFrame.new(side*.38,.72,-.86)
   p[name.."Thigh"].CFrame=cf*CFrame.new(side*.38,1.42,-.45)
   p[name.."Shoe"].CFrame=cf*CFrame.new(side*.38,.12,-.95)
  else
   local hip=cf*CFrame.new(side*.38,1.8,0)*CFrame.Angles(side*sway,0,0)
   p[name.."Leg"].CFrame=hip*CFrame.new(0,-.8,0)
   p[name.."Shoe"].CFrame=hip*CFrame.new(0,-1.67,-.08)
  end
  local angle=-side*sway local inward=0
  if s.Prop=="Book"then angle=.9 inward=-side*.25
  elseif s.Prop=="Cup"and side>0 then angle=1.1+.55*(.5+.5*math.sin(time*.8+s.Phase))
  elseif s.Prop=="Bag"and side>0 then angle=0 end
  local shoulder=cf*CFrame.new(side*1.0,seated and 2.85 or 3.3,0)*CFrame.Angles(angle,0,inward)
  p[name.."Arm"].CFrame=shoulder*CFrame.new(0,-.7,0)
  if side>0 then
   local hand=shoulder*CFrame.new(0,-1.4,0)
   if p.Cup then p.Cup.CFrame=hand*CFrame.new(0,-.05,-.15)*CFrame.Angles(0,0,math.pi/2)p.CupLid.CFrame=p.Cup.CFrame*CFrame.new(.3,0,0)end
   if p.ShoppingBag then p.ShoppingBag.CFrame=hand*CFrame.new(0,-.65,0)p.BagHandle.CFrame=hand*CFrame.new(0,-.08,0)end
  end
 end
 if p.Book then p.Book.CFrame=cf*CFrame.new(0,seated and 2.3 or 2.5,-1.02)*CFrame.Angles(-.1,0,0)p.BookPages.CFrame=p.Book.CFrame*CFrame.new(0,0,-.11)end
 actor.model:SetAttribute("Walking37",moving)
end
local function destroyActors(state)
 for id,a in state.actors do a.model:Destroy()state.actors[id]=nil end
end
function M.Stop(owner)
 local state=active
 if not state or owner and state.owner~=owner then return end
 active=nil state.running=false
 for _,c in state.connections do c:Disconnect()end
 destroyActors(state)
 if state.folder.Parent then state.folder:Destroy()end
end
function M.Start(player,map,P,owner)
 M.Stop()
 local old=workspace:FindFirstChild("PaketKilatLocalResidents37")if old then old:Destroy()end
 local folder=Instance.new("Folder")folder.Name="PaketKilatLocalResidents37"folder.Archivable=false folder.Parent=workspace
 local state={player=player,map=map,P=P,owner=owner,folder=folder,actors={},connections={},running=true,poseElapsed=0,selectElapsed=math.huge}
 active=state
 local basis=map.DepotPad.CFrame
 local Theme=require(game.ReplicatedStorage.PaketKilat.Shared.UITheme12)
 local function mobile()
  local gui=player:FindFirstChild("PlayerGui")local screen=gui and gui:FindFirstChild("PaketKilatUI")local root=screen and screen:FindFirstChild("Root")
  return root and Theme.IsMobile(root)or false
 end
 local floorRay=RaycastParams.new()floorRay.FilterType=Enum.RaycastFilterType.Exclude floorRay.RespectCanCollide=true
 local overlap=OverlapParams.new()overlap.FilterType=Enum.RaycastFilterType.Exclude overlap.RespectCanCollide=true
 local function floorAndClear(v)
  local point=basis:PointToWorldSpace(Vector3.new(v.X,1,v.Y))
  floorRay.FilterDescendantsInstances={folder,player.Character}
  local h=workspace:Raycast(point+Vector3.new(0,6,0),Vector3.new(0,-8,0),floorRay)
  if not h or math.abs(h.Position.Y-(basis.Position.Y+1))>.08 then return end
  point=Vector3.new(point.X,h.Position.Y,point.Z)
  overlap.FilterDescendantsInstances={folder,player.Character}
  for _,p in workspace:GetPartBoundsInBox(CFrame.new(point+Vector3.new(0,2.45,0)),Vector3.new(1.25,4.5,1.25),overlap)do
   if p.CanCollide and p.Transparency<.99 then return end
  end
  return point
 end
 local function selectResidents(root,time,isMobile)
  local limit=isMobile and P.MobileSlots or P.DesktopSlots
  local nearby={}
  for _,spec in P.Residents do
   local pos=M.Sample(spec,time)local world=basis:PointToWorldSpace(Vector3.new(pos.X,1,pos.Y))
   local distance=(world-root.Position).Magnitude
   if distance<P.Radius then table.insert(nearby,{spec=spec,distance=distance-(state.actors[spec.Id]and 7 or 0)})end
  end
  table.sort(nearby,function(a,b)return a.distance<b.distance end)
  local chosen={}local count=0
  for _,row in nearby do
   if count>=limit then break end
   local pos,direction,moving=M.Sample(row.spec,time)local at=floorAndClear(pos)
   if at then
    count+=1 chosen[row.spec.Id]=true
    if not state.actors[row.spec.Id]then
     local actor=create(row.spec,folder)actor.cf=CFrame.lookAt(at,at+basis:VectorToWorldSpace(Vector3.new(direction.X,0,direction.Y)))
     state.actors[row.spec.Id]=actor pose(actor,actor.cf,time,moving)
    end
   end
  end
  for id,a in state.actors do if not chosen[id]then a.model:Destroy()state.actors[id]=nil end end
  folder:SetAttribute("ActiveCount37",count)folder:SetAttribute("Budget37",limit)folder:SetAttribute("Mobile37",isMobile)
 end
 local function step(dt)
  if not state.running then return end
  if not owner.Parent or not owner.Enabled or not map.Parent then M.Stop(owner)return end
  local char=player.Character local root=char and char:FindFirstChild("HumanoidRootPart")local hum=char and char:FindFirstChildOfClass("Humanoid")
  if not root or not hum or hum.Health<=0 then destroyActors(state)folder:SetAttribute("ActiveCount37",0)return end
  local isMobile=mobile()local interval=isMobile and P.MobileStep or P.DesktopStep
  state.poseElapsed+=dt state.selectElapsed+=dt
  if state.poseElapsed<interval then return end
  local elapsed=state.poseElapsed state.poseElapsed=0 local time=workspace:GetServerTimeNow()
  if state.selectElapsed>=P.SelectionInterval then state.selectElapsed=0 selectResidents(root,time,isMobile)end
  for _,actor in state.actors do
   local pos,dir,moving=M.Sample(actor.spec,time)
   local at=basis:PointToWorldSpace(Vector3.new(pos.X,1,pos.Y))
   local target=CFrame.lookAt(at,at+basis:VectorToWorldSpace(Vector3.new(dir.X,0,dir.Y)))
   actor.cf=actor.cf:Lerp(target,math.min(1,elapsed*10))
   pose(actor,actor.cf,time,moving)
  end
 end
 table.insert(state.connections,RunService.Heartbeat:Connect(step))
 table.insert(state.connections,owner.Destroying:Connect(function()M.Stop(owner)end))
 table.insert(state.connections,owner.AncestryChanged:Connect(function()if not owner:IsDescendantOf(player.PlayerScripts)then M.Stop(owner)end end))
 folder:SetAttribute("Profiles37",#P.Residents)folder:SetAttribute("ActiveCount37",0)
 return state
end
return M
