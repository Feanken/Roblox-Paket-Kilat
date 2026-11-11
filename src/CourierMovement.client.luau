local Players=game:GetService("Players") local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService") local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService") local Debris=game:GetService("Debris")
local p=Players.LocalPlayer local shared=game.ReplicatedStorage:WaitForChild("PaketKilat")
local Theme=require(shared.Shared.UITheme12)
local intent=shared.Remotes:WaitForChild("MovementIntent") local ui=p:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI").Root
local lowWarned=false local warnOrder local wasResting=false
local state={} local wants=false local connections={}
local function bind(event,fn)local c=event:Connect(fn)table.insert(connections,c)end
local function send(value)wants=value intent:FireServer(value)end
local lastStaminaTarget = -1
local staminaTween = nil
local lastGripTarget = -1
local lastGripColor = nil
local gripTween = nil

local function spawnSprintDust()
 local char = p.Character
 local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
 if not hrp then return end
 local att = Instance.new("Attachment")
 att.Position = Vector3.new(0, -2.4, 0)
 att.Parent = hrp
 local emitter = Instance.new("ParticleEmitter")
 emitter.Name = "SprintDust"
 emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
 emitter.Color = ColorSequence.new(Color3.fromRGB(230, 220, 205))
 emitter.Size = NumberSequence.new({
  NumberSequenceKeypoint.new(0, 0.25),
  NumberSequenceKeypoint.new(0.5, 0.55),
  NumberSequenceKeypoint.new(1, 0.8)
 })
 emitter.Transparency = NumberSequence.new({
  NumberSequenceKeypoint.new(0, 0.4),
  NumberSequenceKeypoint.new(0.6, 0.7),
  NumberSequenceKeypoint.new(1, 1)
 })
 emitter.Speed = NumberRange.new(2, 5)
 emitter.SpreadAngle = Vector2.new(45, 45)
 emitter.Lifetime = NumberRange.new(0.3, 0.5)
 emitter.Rate = 0
 emitter.Acceleration = Vector3.new(0, 2, 0)
 emitter.Parent = att
 emitter:Emit(3)
 Debris:AddItem(att, 0.6)
end

local b=Instance.new("TextButton") b.Name="SprintToggle" b.Size=UDim2.fromOffset(84,44) b.Position=UDim2.new(1,-98,0,64)
b.BackgroundColor3=Color3.fromRGB(33,91,91) b.TextColor3=Color3.fromRGB(255,234,191) b.Font=Enum.Font.GothamBold b.TextSize=12 b.BorderSizePixel=0 b.Parent=ui
local corner=Instance.new("UICorner")corner.CornerRadius=UDim.new(0,9)corner.Parent=b
local hud=Instance.new("Frame")hud.Name="CourierMeters"hud.AnchorPoint=Vector2.new(.5,1)hud.Size=UDim2.fromOffset(352,48)hud.Position=UDim2.new(.5,0,1,-76)
hud.BackgroundColor3=Color3.fromRGB(25,65,66)hud.BorderSizePixel=0 hud.Parent=ui corner:Clone().Parent=hud
b.Parent=hud b.Position=UDim2.new(1,-92,0,6)
local function meter(name,y,color)
 local t=Instance.new("TextLabel")t.Name=name.."Text"t.Size=UDim2.fromOffset(242,16)t.Position=UDim2.fromOffset(9,y)t.BackgroundTransparency=1 t.TextColor3=Color3.fromRGB(247,239,217)t.Font=Enum.Font.GothamMedium t.TextSize=11 t.TextXAlignment=Enum.TextXAlignment.Left t.Parent=hud
 local track=Instance.new("Frame")track.Name=name.."Track"track.Size=UDim2.fromOffset(242,4)track.Position=UDim2.fromOffset(9,y+15)track.BackgroundColor3=Color3.fromRGB(51,88,87)track.BorderSizePixel=0 track.Parent=hud
 local fill=track:Clone()fill.Name="Fill"fill.Position=UDim2.new()fill.Size=UDim2.fromScale(1,1)fill.BackgroundColor3=color fill.Parent=track
 return t,track,fill
end
local stamina,staminaTrack,staminaFill=meter("Stamina",3,Color3.fromRGB(102,211,184))
local grip,gripTrack,gripFill=meter("Grip",29,Color3.fromRGB(255,207,91))
Theme.Movement(hud,b)
bind(b.Activated,function()send(not wants)end)
CAS:BindAction("PKSprint",function(_,input)
 if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
 if input==Enum.UserInputState.Begin then send(true)elseif input==Enum.UserInputState.End or input==Enum.UserInputState.Cancel then send(false)end
 return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.LeftShift)
bind(UIS.WindowFocusReleased,function()send(false)end)
bind(UIS.TextBoxFocused,function()send(false)end)
bind(p.CharacterRemoving,function()send(false)end)
local function render()
 local m=state.movement local alive=p.Character and p.Character:FindFirstChildOfClass("Humanoid")and p.Character.Humanoid.Health>0
 local hum=p.Character and p.Character:FindFirstChildOfClass('Humanoid')
 local seated=hum and hum.Sit
 local celebration=ui:FindFirstChild("DeliveryCelebration")
 local notice=ui:FindFirstChild("PackageNotice")
 local mobile=Theme.IsMobile(ui)
 local mobilePanel=mobile and(ui:GetAttribute("MobileMenuOpen18")or ui:GetAttribute("MobileTargetOpen18")or ui.Guide.Visible)
 local gallery=ui:FindFirstChild("GalleryReader")
 local blocked=ui:GetAttribute("OrderOptionsOpen") or (gallery and gallery.Visible) or ui:GetAttribute("AudioOpen33")==true or mobilePanel or not m or not m.available or not alive or ui.Shop.Visible or ui:GetAttribute('JobBoardOpen17')==true or (celebration and celebration.Visible)
 if (blocked or seated or m and m.exhausted) and wants then send(false)end
 b.Visible=not blocked and not seated
 if mobile then
  local carrying=state.status=="Carrying"
  b.Parent=ui b.Size=UDim2.fromOffset(100,44)b.Position=UDim2.new(1,-270,1,-56)
  local hudWidth = carrying and math.max(118, math.min(Theme.MobileCardWidth(ui), ui.AbsoluteSize.X - 138)) or 118
  local meterWidth = carrying and math.floor((hudWidth - 24) / 2) or 102
  hud.AnchorPoint=Vector2.new(0,0)hud.Size=UDim2.fromOffset(hudWidth,32)
  hud.Position=UDim2.fromOffset(12,ui.StorageStatus:GetAttribute("Alert18")and 116 or 90)
  stamina.Position=UDim2.fromOffset(8,2)grip.Position=UDim2.fromOffset(16+meterWidth,2)
  staminaTrack.Position=UDim2.fromOffset(8,23)gripTrack.Position=UDim2.fromOffset(16+meterWidth,23)
  for _,element in ipairs({stamina,grip})do
   element.Size=UDim2.fromOffset(meterWidth,16)
   element.TextSize=10
   element.TextTruncate=Enum.TextTruncate.AtEnd
  end
  for _,element in ipairs({staminaTrack,gripTrack})do element.Size=UDim2.fromOffset(meterWidth,3)end
  grip.Visible=carrying gripTrack.Visible=carrying
  hud.Visible=not blocked and(not notice or not notice.Visible)and(carrying or wants or m and(m.stamina<99 or m.resting))
 else
  b.Parent=hud b.Size=UDim2.fromOffset(84,44)b.Position=UDim2.new(1,-92,0,6)
  local width=math.min(352,math.max(300,ui.AbsoluteSize.X-300))
  hud.AnchorPoint=Vector2.new(.5,1)hud.Position=UDim2.new(.5,0,1,-76)hud.Size=UDim2.fromOffset(width,56)
  stamina.Position=UDim2.fromOffset(9,3)grip.Position=UDim2.fromOffset(9,29)
  staminaTrack.Position=UDim2.fromOffset(9,18)gripTrack.Position=UDim2.fromOffset(9,44)
  for _,element in ipairs({stamina,grip,staminaTrack,gripTrack})do element.Size=UDim2.fromOffset(width-110,element:IsA('TextLabel')and 16 or 4)end
  stamina.TextSize=11 grip.TextSize=11 grip.Visible=true gripTrack.Visible=true
  hud.Visible=not blocked and(not notice or not notice.Visible)
 end
 if not m then return end
 hud:SetAttribute('Resting27',m.resting==true)
 if m.resting and not wasResting then
  ui:SetAttribute('MobileNoticeText18','Pulih lebih cepat; waktu tetap jalan. Lompat untuk berdiri.')
  ui:SetAttribute('MobileNoticeUntil18',os.clock()+3)
 end
 wasResting=m.resting==true
 if warnOrder~=state.orderId then warnOrder=state.orderId lowWarned=false end
 if m.grip>=50 then lowWarned=false end
 if state.status=='Carrying'and not m.resting and m.grip<=25 and not lowWarned then
  lowWarned=true
  ui:SetAttribute('MobileNoticeText18','Genggaman menipis. Lepas sprint agar pulih.')
  ui:SetAttribute('MobileNoticeUntil18',os.clock()+3)
 end
 b.Text=m.exhausted and "Istirahat" or wants and "Sprint: ON" or UIS.TouchEnabled and "Sprint" or "Sprint [Shift]"
 b.TextSize=UIS.TouchEnabled and 12 or 10
 stamina.Text=string.format("STAMINA %d%s",m.stamina,m.exhausted and " · pulihkan dulu"or "")
 grip.Text=state.status=="Carrying"and string.format("GENGGAMAN %d · %s",m.grip,state.packageType=="Rapuh"and "RAPUH"or "paket biasa")or "GENGGAMAN · pulih"
 if state.status=='Carrying'and m.grip<=25 then grip.Text='PELANKAN · genggaman '..m.grip end
 if mobile then stamina.Text="Lari "..m.stamina grip.Text="Pegang "..m.grip end
 if m.dropInSeconds and m.dropInSeconds <= 2 then
  grip.Text = mobile and string.format("Lepas sprint %.1fs", m.dropInSeconds)
   or string.format("LEPAS SPRINT · paket terlepas %.1f dtk", m.dropInSeconds)
 end
 if m.resting then
  stamina.Text=mobile and('Istirahat '..m.stamina)or('ISTIRAHAT · stamina '..m.stamina)
  grip.Text=mobile and('Pegang '..m.grip)or('GENGGAMAN '..m.grip..' · lompat untuk berdiri')
 end
   local targetStaminaScale = math.clamp(m.stamina/100, 0, 1)
  if math.abs(lastStaminaTarget - targetStaminaScale) > 0.005 then
   lastStaminaTarget = targetStaminaScale
   if staminaTween then staminaTween:Cancel() end
   staminaTween = TweenService:Create(staminaFill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.fromScale(targetStaminaScale, 1)
   })
   staminaTween:Play()
  end
  local targetGripScale = math.clamp(m.grip/100, 0, 1)
  local targetGripColor = (m.grip<=25 or m.dropInSeconds and m.dropInSeconds<=2) and Color3.fromRGB(255,130,81) or Color3.fromRGB(255,207,91)
  if math.abs(lastGripTarget - targetGripScale) > 0.005 or lastGripColor ~= targetGripColor then
   lastGripTarget = targetGripScale
   lastGripColor = targetGripColor
   if gripTween then gripTween:Cancel() end
   gripTween = TweenService:Create(gripFill, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
    Size = UDim2.fromScale(targetGripScale, 1),
    BackgroundColor3 = targetGripColor
   })
   gripTween:Play()
  end
end
bind(shared.Remotes.StateChanged.OnClientEvent,function(snapshot,code)
 state=snapshot
 if wants and (code=="GripLost" or code=="Respawned" or code=="Cancelled")then send(false)end
 render()
end)
local elapsed=0 local refresh=0 local dustTimer=0
bind(RunService.Heartbeat,function(dt)
 elapsed+=dt refresh+=dt
 if elapsed>=.1 then elapsed=0 render()end
 if refresh>=.4 then refresh=0 if wants then intent:FireServer(true)end end
 if wants then
  local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  if hum and hum.MoveDirection.Magnitude > 0.1 and hum.FloorMaterial ~= Enum.Material.Air then
   dustTimer += dt
   if dustTimer >= 0.16 then
    dustTimer = 0
    spawnSprintDust()
   end
  else
   dustTimer = 0
  end
 else
  dustTimer = 0
 end
end)
bind(script.Destroying,function()intent:FireServer(false)for _,c in ipairs(connections)do c:Disconnect()end CAS:UnbindAction("PKSprint")b:Destroy()hud:Destroy()end)
task.delay(.9,function()if script.Parent then shared.Remotes.ActionRequest:FireServer("Sync")end end)

