-- Reuses the card header; cosmetic navigation never sends movement/reward requests.
local player=game.Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild('PaketKilat')
local config=require(shared.Shared.Config)local theme=require(shared.Shared.UITheme12)
local ui=player:WaitForChild('PlayerGui'):WaitForChild('PaketKilatUI'):WaitForChild('Root')
local card=ui.TopCard local state={}local connections={}
ui:SetAttribute('NavigationHeader19',true)
local arrow=Instance.new('TextLabel')arrow.Name='NavigationArrow19'arrow.Size=UDim2.fromOffset(20,20)arrow.BackgroundTransparency=1 arrow.Text='▲'arrow.Font=Enum.Font.GothamBold arrow.TextSize=18 arrow.TextColor3=theme.Gold arrow.Visible=false arrow.Parent=card
local function flat(v)return Vector3.new(v.X,0,v.Z)end
local function ownPackage()
 local w=workspace:FindFirstChild('PaketKilat')local f=w and w:FindFirstChild('ActivePackages')
 if f then for _,p in ipairs(f:GetChildren())do if p:GetAttribute('orderId')==state.orderId and p:GetAttribute('ownerUserId')==player.UserId then return p end end end
end
local function render()
 local mobile=theme.IsMobile(ui)arrow.Position=UDim2.fromOffset(mobile and 10 or 14,mobile and 7 or 11)
 local char=player.Character local root=char and char:FindFirstChild('HumanoidRootPart')local hum=char and char:FindFirstChildOfClass('Humanoid')
 arrow.Visible=false
 if not state.profileReady then ui:SetAttribute('NavigationMode19','hidden')card.Title.Text='PAKET KILAT'return end
 if not root or not hum or hum.Health<=0 then ui:SetAttribute('NavigationMode19','hidden')card.Title.Text='Muncul ulang...'return end
 local route=workspace:FindFirstChild('PaketKilatLocalSafeRoute')
 local target,kind
 if state.status=='Idle'then
  local offer=state.relayOffer
  if offer and workspace:GetServerTimeNow()<offer.expiresAt and(root.Position-state.depotPosition).Magnitude>config.ActionDistance then target,kind=offer.pickupPosition,'titipan'
  else target,kind=state.depotPosition,'depot'end
 elseif state.status=='Carrying'then
  target,kind=state.destinationPosition,'tujuan'
  local stamp=route and route:GetAttribute('GuidedStampId26')
  if state.stampNavigation and stamp and not(state.routeBonus and state.routeBonus.visited[stamp])then target,kind=route:GetAttribute('GuidedStampPosition26'),'cap'end
 elseif state.status=='Dropped'and not state.outOfBounds then local p=ownPackage()target,kind=p and p.Position or state.packagePosition,'paket'end
 if not target then ui:SetAttribute('NavigationMode19',state.status=='Dropped'and 'recover'or 'hidden')ui:SetAttribute('NavigationDistance19',nil)card.Title.Text=state.status=='Dropped'and 'Pulihkan paket'or 'PAKET KILAT'return end
 local distance=(root.Position-target).Magnitude local ready=distance<=(kind=='cap'and state.routeBonus.radius or config.ActionDistance)
 local directionTarget=target local remaining=flat(target-root.Position).Magnitude local mode='direct'
 if not ready and state.status~='Dropped'and kind~='titipan'and route and(route:GetAttribute('VisibleDots')or 0)>0 then
  local selected,index=nil,0
  for _,p in ipairs(route:GetChildren())do local step=p:GetAttribute('RouteStep19')or 0 if p.Transparency<1 and step<=3 and step>index then selected,index=p,step end end
  if selected then directionTarget=selected.Position mode='route'remaining=route:GetAttribute('RemainingDistance19')or remaining end
 end
 if ready then
  arrow.Text='✓'arrow.Rotation=0 arrow.TextColor3=Color3.fromRGB(57,151,127)
  card.Title.Text=kind=='cap'and 'Lewati pos'or kind=='depot'and 'Pilih pesanan'or kind=='titipan'and 'Ambil titipan'or kind=='paket'and 'Ambil ulang'or 'Siap diantar'
 else
  local camera=workspace.CurrentCamera local forward=flat(camera and camera.CFrame.LookVector or root.CFrame.LookVector)
  if forward.Magnitude<.001 then forward=flat(root.CFrame.LookVector)end
  if forward.Magnitude<.001 then forward=Vector3.new(0,0,-1)end
  forward=forward.Unit local right=Vector3.new(-forward.Z,0,forward.X)local delta=flat(directionTarget-root.Position)
  local angle=math.deg(math.atan2(delta:Dot(right),delta:Dot(forward)))
  arrow.Text='▲'arrow.Rotation=angle arrow.TextColor3=theme.Gold
  card.Title.Text=string.format(kind=='cap'and 'Cap · %d stud'or '%d stud',math.ceil(remaining))
  ui:SetAttribute('NavigationBearing19',angle)
 end
 arrow.Visible=true ui:SetAttribute('NavigationMode19',ready and 'ready'or mode)ui:SetAttribute('NavigationTarget19',kind)ui:SetAttribute('NavigationDistance19',remaining)
end
table.insert(connections,shared.Remotes.StateChanged.OnClientEvent:Connect(function(s)state=s render()end))
local elapsed=0 table.insert(connections,game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed+=dt if elapsed>=.05 then elapsed=0 render()end end))
script.Destroying:Connect(function()for _,c in ipairs(connections)do c:Disconnect()end ui:SetAttribute('NavigationHeader19',false)arrow:Destroy()card.Title.Text='PAKET KILAT'end)
task.delay(.7,function()if script.Parent then shared.Remotes.ActionRequest:FireServer('Sync')end end)
