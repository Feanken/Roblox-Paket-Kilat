-- Client-only music, soundscape and session preferences. No financial/gameplay remotes.
local Players=game:GetService("Players")local SoundService=game:GetService("SoundService")
local RunService=game:GetService("RunService")local TweenService=game:GetService("TweenService")
local ContentProvider=game:GetService("ContentProvider")local UIS=game:GetService("UserInputService")
local CAS=game:GetService("ContextActionService")
local player=Players.LocalPlayer local shared=game.ReplicatedStorage:WaitForChild("PaketKilat")
local P=require(shared.Shared:WaitForChild("AudioProfile33"))
local Theme=require(shared.Shared.UITheme12)
local root=player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI"):WaitForChild("Root")
local connections={}local running=true local tweens={}local elapsed=0 local duckUntil=0
local function bind(signal,fn)local c=signal:Connect(fn)table.insert(connections,c)return c end
local old=SoundService:FindFirstChild("PaketKilatAudio33")if old then old:Destroy()end
local mix=Instance.new("SoundGroup")mix.Name="PaketKilatAudio33"mix.Volume=1 mix.Parent=SoundService
local world=Instance.new("Folder")world.Name="PaketKilatLocalAudio33"world.Parent=workspace
local groups={}local levels={}local remembered={}
for name,default in P.Defaults do
 local value=player:GetAttribute("Audio"..name.."33")
 levels[name]=type(value)=="number"and value==value and math.clamp(value,0,1)or default
 remembered[name]=levels[name]>0 and levels[name]or default
 root:SetAttribute("Audio"..name.."33",levels[name])
 local g=Instance.new("SoundGroup")g.Name=name g.Volume=levels[name]g.Parent=mix groups[name]=g
end
local eq=Instance.new("EqualizerSoundEffect")eq.Name="GentleMusicEQ"eq.HighGain=-3 eq.MidGain=-1 eq.LowGain=-2 eq.Parent=groups.Music
local sounds={}local cues={}local cueClocks={}
local function sound(parent,name,id,volume,group)
 local s=Instance.new("Sound")s.Name=name s.SoundId=id s.Volume=volume
 s.SoundGroup=group s:SetAttribute("PlayCount",0)s:SetAttribute("EndedCount",0)
 bind(s.Ended,function()if running and s.Parent then s:SetAttribute("EndedCount",s:GetAttribute("EndedCount")+1)end end)
 s.Parent=parent table.insert(sounds,s)return s
end
for name,spec in P.Cues do
 local s=sound(mix,name,spec.Id,spec.Volume,groups.Effects)s.PlaybackSpeed=spec.Speed
 cues[name]=s
 if spec.Fallback then task.delay(P.LoadTimeout,function()
  if running and s.Parent and not s.IsLoaded then s:Stop()s.SoundId=spec.Fallback s:SetAttribute("FallbackUsed33",true)end
 end)end
end
local function cue(name)
 local s=cues[name]local spec=P.Cues[name]local clock=os.clock()
 if not running or not s or clock-(cueClocks[name]or -math.huge)<spec.Cooldown then return end
 cueClocks[name]=clock
 if spec.Important then
  for _,key in {"Stamp","Impact","Success","Delivered","Excellent","Career"}do if key~=name and cues[key]then cues[key]:Stop()end end
  duckUntil=clock+(spec.DuckSeconds or 1.6)
 elseif name=="Impact"then duckUntil=clock+.8 end
 if s.IsLoaded and levels.Effects>0 then
  s:Stop()s:Play()s:SetAttribute("PlayCount",s:GetAttribute("PlayCount")+1)
  mix:SetAttribute("LastCue33",name)
 end
end
local music={}local active local transition=false local transitionCount=0
for i,spec in P.Tracks do music[i]=sound(mix,"Music"..i,spec.Id,0,groups.Music)end
local zones={}
local function setupZones()
 if #zones>0 then return end
 local gameWorld=workspace:FindFirstChild("PaketKilat")local map=gameWorld and gameWorld:FindFirstChild("Map")
 local basis=map and map:FindFirstChild("DepotPad")if not basis then return end
 for _,spec in P.Zones do
  local p=Instance.new("Part")p.Name=spec.Name p.Size=Vector3.new(.2,.2,.2)
  p.CFrame=basis.CFrame*CFrame.new(spec.Offset)p.Transparency=1 p.Anchored=true
  p.CanCollide=false p.CanTouch=false p.CanQuery=false p.CastShadow=false p.Parent=world
  local a=Instance.new("Attachment")a.Name="AudioOrigin"a.Parent=p
  local s=sound(a,spec.Name,spec.Id,0,groups.Ambience)s.Looped=true
  s.RollOffMinDistance=spec.Min s.RollOffMaxDistance=spec.Max s.RollOffMode=Enum.RollOffMode.InverseTapered
  table.insert(zones,{sound=s,part=p,spec=spec})
 end
end
setupZones()
local function preload(list)
 task.spawn(function()
  local ok=pcall(function()ContentProvider:PreloadAsync(list,function(id,status)
   if not running then return end
   for _,s in list do if s.Parent and s.SoundId==id then s:SetAttribute("FetchStatus33",status.Name)end end
  end)end)
  if running and mix.Parent then mix:SetAttribute("PreloadCallOk33",ok)end
 end)
end
preload(table.clone(sounds))
local function playTrack(index,fade)
 local s=music[index]if not s.IsLoaded or s.TimeLength<=0 then return false end
 s.Volume=0 s.TimePosition=0 s:Play()s:SetAttribute("PlayCount",s:GetAttribute("PlayCount")+1)
 local t=TweenService:Create(s,TweenInfo.new(fade),{Volume=P.Tracks[index].Volume})if tweens[s]then tweens[s]:Cancel()end tweens[s]=t t:Play()
 active=index mix:SetAttribute("Track33",P.Tracks[index].Name)return true
end
local function crossfade()
 if transition or not active then return end
 local previous=active local nextIndex=active%#music+1
 if not music[nextIndex].IsLoaded then return end
 transition=true
 playTrack(nextIndex,P.CrossfadeSeconds)
 local previousSound=music[previous]
 local t=TweenService:Create(previousSound,TweenInfo.new(P.CrossfadeSeconds),{Volume=0})
 if tweens[previousSound]then tweens[previousSound]:Cancel()end tweens[previousSound]=t t:Play()
 transitionCount+=1 mix:SetAttribute("Crossfades33",transitionCount)
 task.delay(P.CrossfadeSeconds+.05,function()
  if running then music[previous]:Stop()transition=false end
 end)
end
-- A small modal panel; its launcher joins the existing mobile menu instead of a new HUD card.
local toggle=Instance.new("TextButton")toggle.Name="AudioToggle33"toggle.Text="Suara"toggle.ZIndex=4 toggle.Parent=root Theme.ToolbarButton(toggle)
local shade=Instance.new("TextButton")shade.Name="AudioBackdrop33"shade.Text=""shade.AutoButtonColor=false
shade.BackgroundColor3=Theme.Ink shade.BackgroundTransparency=.4 shade.BorderSizePixel=0 shade.ZIndex=60 shade.Visible=false shade.Modal=true shade.Parent=root
local panel=Instance.new("Frame")panel.Name="AudioPanel33"panel.AnchorPoint=Vector2.new(.5,.5)
panel.Position=UDim2.fromScale(.5,.5)panel.Size=UDim2.fromOffset(360,252)panel.BackgroundColor3=Theme.Cream panel.BorderSizePixel=0 panel.ZIndex=61 panel.Visible=false panel.Parent=root
local corner=Instance.new("UICorner")corner.CornerRadius=UDim.new(0,16)corner.Parent=panel
local function text(name,value,x,y,w,h,size)
 local l=Instance.new("TextLabel")l.Name=name l.Text=value l.Position=UDim2.fromOffset(x,y)l.Size=UDim2.fromOffset(w,h)
 l.BackgroundTransparency=1 l.Font=Enum.Font.GothamMedium l.TextColor3=Theme.Ink l.TextSize=size or 12 l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=62 l.Parent=panel return l
end
text("Title","Suara kampung",16,10,245,25,19).Font=Enum.Font.GothamBold
local trackLabel=text("Track","Menyiapkan musik...",16,39,325,18,10)trackLabel.TextColor3=Theme.Muted
local close=Instance.new("TextButton")close.Name="Close"close.Text="×"close.Size=UDim2.fromOffset(44,44)close.Position=UDim2.new(1,-48,0,4)close.ZIndex=63 close.Parent=panel Theme.ToolbarButton(close)close.TextSize=22
local rows={}
for i,name in {"Music","Ambience","Effects"}do
 local row=Instance.new("Frame")row.Name=name row.Position=UDim2.fromOffset(12,64+(i-1)*52)
 row.Size=UDim2.new(1,-24,0,46)row.BackgroundColor3=Theme.Soft row.BorderSizePixel=0 row.ZIndex=62 row.Parent=panel
 local r=Instance.new("UICorner")r.CornerRadius=UDim.new(0,10)r.Parent=row
 local l=Instance.new("TextLabel")l.Name="Label"l.Text=({Music="Musik",Ambience="Suasana",Effects="Efek"})[name]
 l.Size=UDim2.new(1,-183,1,0)l.Position=UDim2.fromOffset(10,0)l.BackgroundTransparency=1 l.TextColor3=Theme.Ink l.Font=Enum.Font.GothamBold l.TextSize=13 l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=63 l.Parent=row
 local buttons={}
 for j,key in {"Down","Value","Up"}do
  local b=Instance.new("TextButton")b.Name=key b.Text=key=="Down"and "−"or key=="Up"and "+"or ""
  b.Size=UDim2.fromOffset(key=="Value"and 62 or 44,44)
  b.Position=UDim2.new(1,key=="Down"and -164 or key=="Value"and -116 or -50,0,1)
  b.ZIndex=63 b.Parent=row Theme.ToolbarButton(b)buttons[key]=b
 end
 rows[name]=buttons
end
text("Hint","Pengaturan sesi ini · M: musik",16,226,326,16,10).TextColor3=Theme.Muted
local function setLevel(name,value)
 if type(value)~="number"or value~=value then value=P.Defaults[name]end
 value=math.clamp(value,0,1)levels[name]=value
 if value>0 then remembered[name]=value end
 player:SetAttribute("Audio"..name.."33",value)
 if root:GetAttribute("Audio"..name.."33")~=value then root:SetAttribute("Audio"..name.."33",value)end
 if name~="Music"or value==0 then groups[name].Volume=value end
 rows[name].Value.Text=value==0 and "Mati"or string.format("%d%%",math.floor(value*100+.5))
end
local function mute(name)setLevel(name,levels[name]>0 and 0 or remembered[name])end
for name,buttons in rows do
 bind(buttons.Down.Activated,function()setLevel(name,levels[name]-.25)cue("Click")end)
 bind(buttons.Up.Activated,function()setLevel(name,levels[name]+.25)cue("Click")end)
 bind(buttons.Value.Activated,function()mute(name)cue("Click")end)
 bind(root:GetAttributeChangedSignal("Audio"..name.."33"),function()setLevel(name,root:GetAttribute("Audio"..name.."33"))end)
 setLevel(name,levels[name])
end
local function open(value)
 root:SetAttribute("AudioOpen33",value)
 panel.Visible=value shade.Visible=value
 if value then root:SetAttribute("MobileMenuOpen18",false)root:SetAttribute("MobileTargetOpen18",false)end
end
bind(toggle.Activated,function()open(not panel.Visible)cue("Click")end)
bind(close.Activated,function()open(false)cue("Click")end)
bind(shade.Activated,function()open(false)end)
CAS:BindAction("PKMusic33",function(_,state)
 if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
 if state==Enum.UserInputState.Begin then mute("Music")end
 return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.M)
local delivered={}local deliveredOrder={}
local gripWarned, gripOrder = false, nil
local codes={Start="Pickup",Pickup="Pickup",Drop="Drop",Impact="Impact",HardLanding="Impact",Slip="Impact",Barrier="Impact",GripLost="Impact",Recover="Recover",CityStamp="Stamp",Delivered="Delivered",Purchased="Success",GripUpgraded="Success",Equipped="Click"}
bind(shared.Remotes.StateChanged.OnClientEvent,function(snapshot,code)
 local movement = snapshot.movement
 if gripOrder ~= snapshot.orderId then gripOrder, gripWarned = snapshot.orderId, false end
 if movement and movement.grip >= 50 then gripWarned = false end
 if movement and movement.dropInSeconds and movement.dropInSeconds <= 1.5 and not gripWarned then
  gripWarned = true
  cue("GripWarning")
 end
 local name=codes[code]if not name then return end
 if code=="Delivered"then
  if panel.Visible then open(false)end
  local id=snapshot.lastResult and snapshot.lastResult.orderId
  if not id or delivered[id]then return end delivered[id]=true table.insert(deliveredOrder,id)
  local result=snapshot.lastResult
  if result.storyFinished or result.promotion or (result.weeklyBonus or 0) > 0 then name="Career"
  elseif result.rating and result.rating.stars==3 or result.isBatch and result.batchIndex==result.batchTotal then name="Excellent"end
  if #deliveredOrder>20 then delivered[table.remove(deliveredOrder,1)]=nil end
 end
 cue(name)
end)
-- UI buttons use one shared, throttled click voice; no per-hover noise.
local boundButtons=setmetatable({},{__mode="k"})
local function watch(v)
 if not v:IsA("GuiButton")or v==shade or boundButtons[v]then return end
 if v==toggle or v==close or v:IsDescendantOf(panel)then return end
 boundButtons[v]=true bind(v.Activated,function()cue("Click")end)
end
for _,v in root:GetDescendants()do watch(v)end bind(root.DescendantAdded,watch)
-- Own-character built-in steps/jumps share the Effects bus, without changing other players.
local characterConnections={}local priorGroups=setmetatable({},{__mode="k"})
local groupRefs=Instance.new("Folder")groupRefs.Name="CharacterGroups33"groupRefs.Parent=mix
local function character(char)
 for _,c in characterConnections do c:Disconnect()end table.clear(characterConnections)
 for _,ref in groupRefs:GetChildren()do
  local v=ref.Value if v and not v:IsDescendantOf(char)and v.SoundGroup==groups.Effects then v.SoundGroup=ref.PreviousGroup.Value end
  if not v or not v:IsDescendantOf(char)then ref:Destroy()end
 end
 local function groupSound(v)
  if v:IsA("Sound")then
   priorGroups[v]={group=v.SoundGroup}
   local ref=Instance.new("ObjectValue")ref.Name="CharacterSound"ref.Value=v
   local previous=Instance.new("ObjectValue")previous.Name="PreviousGroup"previous.Value=v.SoundGroup previous.Parent=ref ref.Parent=groupRefs
   v.SoundGroup=groups.Effects
  end
 end
 for _,v in char:GetDescendants()do groupSound(v)end
 table.insert(characterConnections,char.DescendantAdded:Connect(groupSound))
end
if player.Character then character(player.Character)end bind(player.CharacterAdded,character)
bind(RunService.Heartbeat,function(dt)
 if not running then return end elapsed+=dt if elapsed<P.UpdateInterval then return end local delta=elapsed elapsed=0
 if #zones==0 then setupZones()if #zones>0 then local list={}for _,z in zones do table.insert(list,z.sound)end preload(list)end end
 local result=root:FindFirstChild("DeliveryCelebration")
 local busy=root.Shop.Visible or root:GetAttribute("JobBoardOpen17")==true or result and result.Visible
 if busy and panel.Visible then open(false)end
 toggle.Visible=not busy and(not Theme.IsMobile(root)or root:GetAttribute("MobileMenuOpen18")==true)
 Theme.ToolbarLayout(root)
 local width=math.min(360,math.max(280,root.AbsoluteSize.X-24))
 panel.Size=UDim2.fromOffset(width,252)
 panel.Hint.Text=Theme.IsMobile(root)and "Ketuk % untuk mute · berlaku sesi ini"or "Pengaturan sesi ini · M: musik"
 local cam=workspace.CurrentCamera
 if cam then shade.Position=UDim2.fromOffset(-root.AbsolutePosition.X,-root.AbsolutePosition.Y)shade.Size=UDim2.fromOffset(cam.ViewportSize.X,cam.ViewportSize.Y)end
 local duck=os.clock()<duckUntil and .32 or (busy or panel.Visible)and .55 or 1
 local target=levels.Music*duck
 groups.Music.Volume=target==0 and 0 or groups.Music.Volume+(target-groups.Music.Volume)*(1-math.exp(-delta*5))
 mix:SetAttribute("MusicDuck33",duck)
 if not active then for i,s in music do if s.IsLoaded and playTrack(i,1.5)then break end end
 elseif not transition then
  local s=music[active]
  if not s.IsPlaying then playTrack(active,1)
  elseif s.TimeLength-s.TimePosition<=P.CrossfadeSeconds then crossfade()end
 end
 trackLabel.Text=levels.Music==0 and "Musik dimatikan"or(active and "Diputar: "..P.Tracks[active].Name or "Musik belum tersedia")
 local listener=cam and cam.CFrame.Position
 for _,z in zones do
  local distance=listener and(listener-z.part.Position).Magnitude or math.huge
  local near=distance<z.spec.Max+3 and levels.Ambience>0
  local v=near and z.spec.Volume or 0
  z.sound.Volume+=(v-z.sound.Volume)*(1-math.exp(-delta*5))
  if near and z.sound.IsLoaded and not z.sound.IsPlaying then
   z.sound.TimePosition=(os.clock()+z.spec.Phase)%math.max(z.sound.TimeLength,.1)z.sound:Play()
   z.sound:SetAttribute("PlayCount",z.sound:GetAttribute("PlayCount")+1)
  elseif not near and z.sound.Volume<.002 and z.sound.IsPlaying then z.sound:Stop()end
 end
end)
local function cleanup()
 if not running then return end running=false
 for _,c in connections do c:Disconnect()end for _,c in characterConnections do c:Disconnect()end
 for _,t in tweens do t:Cancel()end
 for s,record in priorGroups do if s.Parent and s.SoundGroup==groups.Effects then s.SoundGroup=record.group end end
 CAS:UnbindAction("PKMusic33")
 for _,s in sounds do s:Stop()end
 root:SetAttribute("AudioOpen33",false)
 toggle:Destroy()panel:Destroy()shade:Destroy()world:Destroy()mix:Destroy()
end
bind(script.Destroying,cleanup)
