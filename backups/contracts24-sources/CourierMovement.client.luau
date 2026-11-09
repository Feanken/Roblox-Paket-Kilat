local Players=game:GetService("Players") local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService") local RunService=game:GetService("RunService")
local p=Players.LocalPlayer local shared=game.ReplicatedStorage:WaitForChild("PaketKilat")
local Theme=require(shared.Shared.UITheme12)
local intent=shared.Remotes:WaitForChild("MovementIntent") local ui=p:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI").Root
local state={} local wants=false local connections={}
local function bind(event,fn)local c=event:Connect(fn)table.insert(connections,c)end
local function send(value)wants=value intent:FireServer(value)end
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
 local celebration=ui:FindFirstChild("DeliveryCelebration")
 local notice=ui:FindFirstChild("PackageNotice")
 local mobile=Theme.IsMobile(ui)
 local mobilePanel=mobile and(ui:GetAttribute("MobileMenuOpen18")or ui:GetAttribute("MobileTargetOpen18")or ui.Guide.Visible)
 local blocked=mobilePanel or not m or not m.available or not alive or ui.Shop.Visible or ui:GetAttribute('JobBoardOpen17')==true or (celebration and celebration.Visible)
 if (blocked or m and m.exhausted) and wants then send(false)end
 b.Visible=not blocked
 if mobile then
  local carrying=state.status=="Carrying"
  b.Parent=ui b.Size=UDim2.fromOffset(100,44)b.Position=UDim2.new(1,-270,1,-56)
  hud.AnchorPoint=Vector2.new(0,0)hud.Size=UDim2.fromOffset(carrying and 238 or 118,32)
  hud.Position=UDim2.fromOffset(12,ui.StorageStatus:GetAttribute("Alert18")and 124 or 100)
  stamina.Position=UDim2.fromOffset(8,2)grip.Position=UDim2.fromOffset(126,2)
  staminaTrack.Position=UDim2.fromOffset(8,23)gripTrack.Position=UDim2.fromOffset(126,23)
  for _,element in ipairs({stamina,grip})do element.Size=UDim2.fromOffset(104,16)element.TextSize=10 end
  for _,element in ipairs({staminaTrack,gripTrack})do element.Size=UDim2.fromOffset(104,3)end
  grip.Visible=carrying gripTrack.Visible=carrying
  hud.Visible=not blocked and(not notice or not notice.Visible)and(carrying or wants or m and m.stamina<99)
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
 b.Text=m.exhausted and "Istirahat" or wants and "Sprint: ON" or UIS.TouchEnabled and "Sprint" or "Sprint [Shift]"
 b.TextSize=UIS.TouchEnabled and 12 or 10
 stamina.Text=string.format("STAMINA %d%s",m.stamina,m.exhausted and " · pulihkan dulu"or "")
 grip.Text=state.status=="Carrying"and string.format("GENGGAMAN %d · %s",m.grip,state.packageType=="Rapuh"and "RAPUH"or "paket biasa")or "GENGGAMAN · pulih"
 if mobile then stamina.Text="Lari "..m.stamina grip.Text="Pegang "..m.grip end
 staminaFill.Size=UDim2.fromScale(m.stamina/100,1)gripFill.Size=UDim2.fromScale(m.grip/100,1)
 gripFill.BackgroundColor3=m.grip<=25 and Color3.fromRGB(255,130,81)or Color3.fromRGB(255,207,91)
end
bind(shared.Remotes.StateChanged.OnClientEvent,function(snapshot,code)
 state=snapshot
 if wants and (code=="GripLost" or code=="Respawned" or code=="Cancelled")then send(false)end
 render()
end)
local elapsed=0 local refresh=0
bind(RunService.Heartbeat,function(dt)
 elapsed+=dt refresh+=dt
 if elapsed>=.1 then elapsed=0 render()end
 if refresh>=.4 then refresh=0 if wants then intent:FireServer(true)end end
end)
bind(script.Destroying,function()intent:FireServer(false)for _,c in ipairs(connections)do c:Disconnect()end CAS:UnbindAction("PKSprint")b:Destroy()hud:Destroy()end)
task.delay(.9,function()if script.Parent then shared.Remotes.ActionRequest:FireServer("Sync")end end)

