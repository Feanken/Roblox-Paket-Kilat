-- Optional visual guidance only. No new server commands and no movement control.
local Players=game:GetService("Players") local RunService=game:GetService("RunService")
local CAS=game:GetService("ContextActionService") local UIS=game:GetService("UserInputService")
local p=Players.LocalPlayer local shared=game.ReplicatedStorage:WaitForChild("PaketKilat")
local routes=require(shared.Shared:WaitForChild("SafeRoutes08"))
local Paths=require(shared.Shared:WaitForChild('CourierPaths21'))
local Theme=require(shared.Shared.UITheme12)
local ui=p:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI").Root
local state={} local enabled=true local connections={}
local function bind(signal,fn) local c=signal:Connect(fn) table.insert(connections,c) end
local folder=Instance.new("Folder") folder.Name="PaketKilatLocalSafeRoute" folder.Parent=workspace
local dots={}
for i=1,16 do
 local d=Instance.new("Part") d.Name="RouteDot" d.Shape=Enum.PartType.Cylinder d.Size=Vector3.new(.08,.85,.85)
 d.Anchored=true d.CanCollide=false d.CanQuery=false d.CanTouch=false d.CastShadow=false
 d:SetAttribute("RouteStep19",i)
 d.Material=Enum.Material.Neon d.Color=Color3.fromRGB(255,205,88) d.Transparency=1 d.Archivable=false d.Parent=folder dots[i]=d
end
local button=Instance.new("TextButton") button.Name="RouteToggle" button.Size=UDim2.fromOffset(84,44)
button.Position=UDim2.new(1,-282,0,12) button.BorderSizePixel=0 button.Font=Enum.Font.GothamBold button.TextSize=12
button.TextColor3=Color3.fromRGB(246,237,211) button.BackgroundColor3=Color3.fromRGB(33,91,91) button.Parent=ui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,9) corner.Parent=button
Theme.ToolbarButton(button)
local function toggle() enabled=not enabled end
bind(button.Activated,function()toggle()ui:SetAttribute("MobileMenuOpen18",false)end)
CAS:BindAction("PKSafeRoute",function(_,action)
 if UIS:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end
 if action==Enum.UserInputState.Begin then toggle() end
 return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.G)
local function hide() for _,dot in ipairs(dots) do dot.Transparency=1 end folder:SetAttribute("VisibleDots",0)folder:SetAttribute("RemainingDistance19",nil) end
local function flat(v) return Vector3.new(v.X,0,v.Z) end
local function refresh()
 Theme.ToolbarLayout(ui)
 button.Text=UIS.TouchEnabled and (enabled and "Rute: ON" or "Rute: OFF") or (enabled and "Rute [G]" or "Rute OFF [G]")
 button.Visible=state.profileReady==true and not ui.Shop.Visible and not ui:GetAttribute('JobBoardOpen17')and(not Theme.IsMobile(ui)or ui:GetAttribute("MobileMenuOpen18")==true)
 button:SetAttribute("RouteEnabled",enabled)
 local char=p.Character local root=char and char:FindFirstChild("HumanoidRootPart") local hum=char and char:FindFirstChildOfClass("Humanoid")
 local returning=state.status=="Idle" and state.lastResult~=nil
 local offer=state.status=='Idle'and state.relayOffer
 if offer and workspace:GetServerTimeNow()<offer.expiresAt then hide()return end
 local id=state.status=="Carrying" and state.destinationId or returning and state.lastResult.destinationId
 local offsets=id and Paths.Between(routes,state.status=='Carrying'and state.sourceId or nil,id)
 hide()
 if not enabled or not state.profileReady or ui.Shop.Visible or ui:GetAttribute('JobBoardOpen17')or state.outOfBounds or not root or not hum or hum.Health<=0 or not offsets or not state.depotPosition then return end
 local basis=state.routeBasis or CFrame.identity
 local points={}
 if returning then for i=#offsets,1,-1 do table.insert(points,state.depotPosition+basis:VectorToWorldSpace(offsets[i])) end
 else for _,point in ipairs(offsets) do table.insert(points,state.depotPosition+basis:VectorToWorldSpace(point)) end end
 local best,bestSegment,bestT=math.huge,nil,0
 for i=1,#points-1 do
  local a,b=flat(points[i]),flat(points[i+1]) local delta=b-a
  if delta.Magnitude>.01 then
   local t=math.clamp((flat(root.Position)-a):Dot(delta)/delta:Dot(delta),0,1)
   local distance=(flat(root.Position)-(a+delta*t)).Magnitude
   if distance<best then best,bestSegment,bestT=distance,i,t end
  end
 end
 if not bestSegment or best>30 then return end
 local cursor=points[bestSegment]:Lerp(points[bestSegment+1],bestT)
 local remaining=best+(points[bestSegment+1]-cursor).Magnitude
 for i=bestSegment+1,#points-1 do remaining+=(points[i+1]-points[i]).Magnitude end
 folder:SetAttribute('RemainingDistance19',remaining)
 local segment=bestSegment local count=0
 for _,dot in ipairs(dots) do
  local step=5
  while segment<#points do
   local delta=points[segment+1]-cursor local length=delta.Magnitude
   if length>step then cursor+=delta.Unit*step break end
   step-=length cursor=points[segment+1] segment+=1
  end
  if segment>=#points then break end
  dot.CFrame=CFrame.new(cursor+Vector3.new(0,.1,0))*CFrame.Angles(0,0,math.pi/2)
  dot.Transparency=.12 count+=1
 end
 folder:SetAttribute("VisibleDots",count) folder:SetAttribute("Returning",returning)
end
bind(shared.Remotes.StateChanged.OnClientEvent,function(snapshot) state=snapshot refresh() end)
local elapsed=0
bind(RunService.Heartbeat,function(dt) elapsed+=dt if elapsed>=.1 then elapsed=0 refresh() end end)
bind(p.CharacterRemoving,function() hide() end)
bind(script.Destroying,function()
 for _,c in ipairs(connections) do c:Disconnect() end
 CAS:UnbindAction("PKSafeRoute") folder:Destroy() button:Destroy()
end)
task.delay(.8,function() if script.Parent then shared.Remotes.ActionRequest:FireServer("Sync") end end)

