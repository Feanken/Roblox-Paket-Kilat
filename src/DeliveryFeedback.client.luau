-- Presentation only. All rewards/statuses originate from existing server snapshots.
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Debris=game:GetService("Debris")
local player=Players.LocalPlayer
local remote=game.ReplicatedStorage:WaitForChild("PaketKilat").Remotes
local ui=player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI").Root
local Theme=require(game.ReplicatedStorage.PaketKilat.Shared.UITheme12)
local Config=require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local Story = require(game.ReplicatedStorage.PaketKilat.Shared:WaitForChild("CourierStory"))
local state,shownOrder={},nil
local connections={}
local function connect(signal,fn) local c=signal:Connect(fn) table.insert(connections,c) return c end
local function text(parent,name,size,pos,value,fontSize)
 local t=Instance.new("TextLabel") t.Name=name t.Size=size t.Position=pos t.BackgroundTransparency=1
 t.Text=value t.TextColor3=Color3.fromRGB(247,239,217) t.Font=Enum.Font.GothamBold t.TextSize=fontSize t.Parent=parent return t
end
local function spawnDeliveryConfetti()
 local char = player.Character
 local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
 if not hrp then return end
 local att = Instance.new("Attachment")
 att.Position = Vector3.new(0, 1.5, 0)
 att.Parent = hrp
 local emitter = Instance.new("ParticleEmitter")
 emitter.Name = "CelebrationConfetti"
 emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
 emitter.Color = ColorSequence.new({
  ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 225, 90)),
  ColorSequenceKeypoint.new(0.5, Color3.fromRGB(70, 220, 180)),
  ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
 })
 emitter.Size = NumberSequence.new({
  NumberSequenceKeypoint.new(0, 0.4),
  NumberSequenceKeypoint.new(0.5, 0.8),
  NumberSequenceKeypoint.new(1, 0)
 })
 emitter.Transparency = NumberSequence.new({
  NumberSequenceKeypoint.new(0, 0),
  NumberSequenceKeypoint.new(0.8, 0.1),
  NumberSequenceKeypoint.new(1, 1)
 })
 emitter.Speed = NumberRange.new(10, 18)
 emitter.SpreadAngle = Vector2.new(65, 65)
 emitter.Lifetime = NumberRange.new(1.0, 1.6)
 emitter.Rate = 0
 emitter.Acceleration = Vector3.new(0, -12, 0)
 emitter.Parent = att
 emitter:Emit(32)
 Debris:AddItem(att, 2.5)
end
local function spawnImpactPuff()
 local char = player.Character
 local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
 if not hrp then return end
 local att = Instance.new("Attachment")
 att.Position = Vector3.new(0, -1.8, 0)
 att.Parent = hrp
 local emitter = Instance.new("ParticleEmitter")
 emitter.Name = "ImpactPuff"
 emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
 emitter.Color = ColorSequence.new(Color3.fromRGB(225, 210, 190))
 emitter.Size = NumberSequence.new({
  NumberSequenceKeypoint.new(0, 0.4),
  NumberSequenceKeypoint.new(0.5, 1.2),
  NumberSequenceKeypoint.new(1, 1.8)
 })
 emitter.Transparency = NumberSequence.new({
  NumberSequenceKeypoint.new(0, 0.3),
  NumberSequenceKeypoint.new(0.6, 0.6),
  NumberSequenceKeypoint.new(1, 1)
 })
 emitter.Speed = NumberRange.new(5, 10)
 emitter.SpreadAngle = Vector2.new(180, 20)
 emitter.Lifetime = NumberRange.new(0.4, 0.7)
 emitter.Rate = 0
 emitter.Acceleration = Vector3.new(0, 2, 0)
 emitter.Parent = att
 emitter:Emit(14)
 Debris:AddItem(att, 1.0)
end
local toast=Instance.new("Frame") toast.Name="DeliveryCelebration" toast.AnchorPoint=Vector2.new(.5,.5)
toast.Position=UDim2.fromScale(.5,.5) toast.Size=UDim2.fromOffset(330,212)
toast.BackgroundColor3=Color3.fromRGB(25,76,73) toast.BorderSizePixel=0 toast.Visible=false toast.ZIndex=20 toast.Active=false toast.Parent=ui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,16) corner.Parent=toast
local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(241,198,99) stroke.Thickness=2 stroke.Parent=toast
local scale=Instance.new("UIScale") scale.Parent=toast
local title=text(toast,"Title",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,12),"PAKET SAMPAI!",18)
local reward=text(toast,"Reward",UDim2.new(1,-24,0,44),UDim2.fromOffset(12,38),"",32)
local detail=text(toast,"Detail",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,82),"",13)
local nextStep=text(toast,"Next",UDim2.new(1,-24,0,26),UDim2.fromOffset(12,111),"",12)
local stars=text(toast,'Rating22',UDim2.new(1,-24,0,20),UDim2.fromOffset(12,32),'',18)
local ratingHint=text(toast,'RatingHint22',UDim2.new(1,-24,0,14),UDim2.fromOffset(12,54),'',10)
local streak=text(toast,'Streak22',UDim2.new(1,-24,0,20),UDim2.fromOffset(12,145),'',11)
for _,t in ipairs({title,reward,detail,nextStep,stars,streak,ratingHint}) do t.ZIndex=21 t.TextWrapped=true end
Theme.Result(toast)
title.Size=UDim2.new(1,-76,0,20)
reward.Position=UDim2.fromOffset(12,72)reward.Size=UDim2.new(1,-24,0,34)reward.TextSize=32
detail.Position=UDim2.fromOffset(12,110)detail.Size=UDim2.new(1,-24,0,30)detail.TextSize=11
reward.BackgroundTransparency=0
reward.BackgroundColor3=Theme.Soft
Instance.new("UICorner", reward).CornerRadius=UDim.new(0, 9)
nextStep.Position=UDim2.fromOffset(12,168)nextStep.Size=UDim2.new(1,-24,0,24)
stars.TextColor3=Theme.Ink streak.TextColor3=Theme.Muted ratingHint.TextColor3=Theme.Muted
local close=Instance.new('TextButton')close.Name='Close22'close.Text='×'close.Size=UDim2.fromOffset(44,44)close.Position=UDim2.new(1,-48,0,4)close.ZIndex=22 close.Parent=toast Theme.ToolbarButton(close)close.TextSize=22
local function resultButton(name, caption)
 local button = Instance.new("TextButton")
 button.Name = name
 button.Text = caption
 button.ZIndex = 22
 button.Parent = toast
 Theme.ToolbarButton(button)
 button.TextSize = 11
 return button
end

local careerButton = resultButton("OpenCareer", "Karier")
local depotButton = resultButton("ReturnToDepot", "Ke depot")
local relayButton = resultButton("ContinueRelay", "Ambil titipan")
local impact=Instance.new("TextLabel") impact.Name="PackageNotice" impact.AnchorPoint=Vector2.new(.5,0)
impact.Position=UDim2.fromScale(.5,.06) impact.Size=UDim2.fromOffset(310,36) impact.Visible=false
impact.BackgroundColor3=Color3.fromRGB(106,52,42) impact.TextColor3=Color3.fromRGB(255,234,201)
impact.Font=Enum.Font.GothamBold impact.TextSize=14 impact.BorderSizePixel=0 impact.ZIndex=22 impact.Active=false impact.Parent=ui
local ic=corner:Clone() ic.Parent=impact
impact.BackgroundColor3=Color3.fromRGB(164,72,47)
local highlight=Instance.new("Highlight") highlight.Name="PaketKilatLocalFocus"
highlight.DepthMode=Enum.HighlightDepthMode.Occluded highlight.FillTransparency=.85
highlight.OutlineTransparency=.1 highlight.FillColor=Color3.fromRGB(255,208,96)
highlight.OutlineColor=Color3.fromRGB(255,208,96) highlight.Parent=workspace
local handoff = Instance.new("Frame")
handoff.Name = "BatchHandoff"
handoff.AnchorPoint = Vector2.new(.5, 1)
handoff.BackgroundColor3 = Theme.Cream
handoff.BorderSizePixel = 0
handoff.ZIndex = 20
handoff.Visible = false
handoff.Parent = ui
corner:Clone().Parent = handoff
local handoffStroke = stroke:Clone()
handoffStroke.Thickness = 1
handoffStroke.Parent = handoff

local handoffReward = text(handoff, "Reward", UDim2.new(1, -102, 0, 16), UDim2.fromOffset(12, 7), "", 10)
local handoffNext = text(handoff, "Next", UDim2.new(1, -102, 0, 22), UDim2.fromOffset(12, 23), "", 12)
for _, label in ipairs({handoffReward, handoffNext}) do
 label.TextXAlignment = Enum.TextXAlignment.Left
 label.TextTruncate = Enum.TextTruncate.AtEnd
 label.ZIndex = 21
end
handoffReward.TextColor3 = Theme.Muted
handoffNext.TextColor3 = Theme.Ink

local stopBatch = Instance.new("TextButton")
stopBatch.Name = "StopBatch31"
stopBatch.Text = "Akhiri…"
stopBatch.Position = UDim2.new(1, -80, 0, 4)
stopBatch.Size = UDim2.fromOffset(76, 44)
stopBatch.ZIndex = 22
stopBatch.Parent = handoff
Theme.ToolbarButton(stopBatch)
local expires, noticeExpires, handoffExpires = 0, 0, 0
local handoffOrder
local handoffPausedAt
local countFrom,countTotal=0,0
local tween
local function ownPackage()
 local world=workspace:FindFirstChild("PaketKilat")
 local active=world and world:FindFirstChild("ActivePackages")
 if active then for _,p in ipairs(active:GetChildren()) do
  if p:GetAttribute("ownerUserId")==player.UserId and p:GetAttribute("orderId")==state.orderId then return p end
 end end
end
local function currentRelay()
 local offer = state.status == "Idle" and state.relayOffer
 return offer and workspace:GetServerTimeNow() < offer.expiresAt and offer or nil
end

local function nearRelay(offer)
 local character = player.Character
 local rootPart = character and character:FindFirstChild("HumanoidRootPart")
 return rootPart and (rootPart.Position - offer.pickupPosition).Magnitude <= Config.ActionDistance
end

local function refresh()
 local width,height=ui.AbsoluteSize.X,ui.AbsoluteSize.Y
 local mobile = Theme.IsMobile(ui)
 local resultWidth = math.min(342, math.max(220, width - 20))
 local offer = currentRelay()
 local result = state.lastResult
 local interrupted = result and result.batchInterrupted
 local chapter = result and result.storyChapter and Story.Chapter(result.storyChapter)
 local contact = chapter and Story.Contact(result.destinationId)
 local receipt = chapter and string.format("%s — %s", contact and contact.name or result.destinationName, chapter.receipt)
 local hasNote = receipt or offer or interrupted
 local compact = height < 280
 local buttonY = compact and (receipt and 161 or hasNote and 154 or 134)
  or (receipt and 207 or hasNote and 198 or 174)
 toast.Size = UDim2.fromOffset(resultWidth, buttonY + 52)
 title.Position = UDim2.fromOffset(12, compact and 6 or 12)
 stars.Position = UDim2.fromOffset(12, compact and 25 or 32)
 stars.TextSize = compact and 14 or 18
 ratingHint.Position = UDim2.fromOffset(12, compact and 44 or 54)
 reward.Position = UDim2.fromOffset(12, compact and 59 or 72)
 reward.Size = UDim2.new(1,-24,0,compact and 28 or 34)
 reward.TextSize = compact and 23 or 32
 detail.Position = UDim2.fromOffset(12, compact and 89 or 110)
 detail.Size = UDim2.new(1,-24,0,compact and 26 or 30)
 streak.Position = UDim2.fromOffset(12, compact and 115 or 145)
 streak.Size = UDim2.new(1,-24,0,compact and 18 or 20)
 local noteY = compact and 133 or 168
 nextStep.Position = UDim2.fromOffset(12,noteY)
 nextStep.Size = UDim2.new(1,-24,0,buttonY-noteY-1)
 nextStep.TextSize = receipt and (compact and 10 or 12) or 11
 nextStep.Visible = hasNote and true or false
 local buttonWidth = (resultWidth - (offer and 40 or 32)) / (offer and 3 or 2)
 for index, button in ipairs({careerButton, depotButton, relayButton}) do
  button.Position = UDim2.fromOffset(12 + (index - 1) * (buttonWidth + 8), buttonY)
  button.Size = UDim2.fromOffset(buttonWidth, 44)
 end
 careerButton.Text = state.lastResult and state.lastResult.storyChapter and "Cerita" or "Karier"
 relayButton.Visible = offer ~= nil
 relayButton.Text = offer and nearRelay(offer) and "Ambil titipan" or "Ke titipan"
 nextStep.Text = receipt or offer and ("Titipan ke " .. offer.destinationName)
  or interrupted and "Alamat berikutnya belum tersedia." or ""
 handoff.Size = UDim2.fromOffset(math.min(294, width - 24), 52)
 handoff.Position = UDim2.new(.5, 0, 1, mobile and -76 or -142)
 if countTotal>0 then reward.Text=string.format('+%d KOIN',math.floor(countTotal*math.clamp((os.clock()-countFrom)/.65,0,1)))end
 -- Keep transient notices below the upper HUD on short landscape screens.
 impact.Position=UDim2.new(.5,0,0,math.min(216,height*.59))
 impact.Size=UDim2.fromOffset(math.min(310,width-32),36)
 local boardOpen=ui:GetAttribute('JobBoardOpen17')==true
 local gallery=ui:FindFirstChild("GalleryReader")
 local shopOpen=ui:GetAttribute("LiveRouteMapOpen") or ui.Shop.Visible or boardOpen or ui:GetAttribute('AudioOpen33')==true or (gallery and gallery.Visible)
 toast.Visible=os.clock()<expires and not shopOpen and state.status=="Idle"
 local noticeActive = os.clock() < noticeExpires
 local mobileOverlay = mobile and (ui.Guide.Visible or ui:GetAttribute("MobileMenuOpen18") or ui:GetAttribute("MobileTargetOpen18"))
 local batch=state.batch
 local now=os.clock()
 local sameHandoff=batch~=nil and state.orderId==handoffOrder and state.status=="Carrying"
 local orderDialogOpen=ui:GetAttribute("OrderOptionsOpen")==true
 if not sameHandoff or handoffExpires==0 then
  handoffPausedAt=nil
 elseif orderDialogOpen then
  if not handoffPausedAt and now<handoffExpires then handoffPausedAt=now end
 elseif handoffPausedAt then
  handoffExpires+=now-handoffPausedAt
  handoffPausedAt=nil
 end
 handoff.Visible = now<handoffExpires and sameHandoff
  and not toast.Visible and not shopOpen and not noticeActive and not mobileOverlay and not orderDialogOpen
 if handoff.Visible then
  local bonus=batch.bonusEligible and string.format("bonus maks. +%d",batch.potentialBonus) or "bonus gugur"
  handoffReward.Text=string.format("+%d koin · %s",state.lastResult.total,bonus)
  handoffNext.Text=string.format("%d/%d · %s",batch.index,batch.total,state.destinationName)
 end
 stopBatch.Active = handoff.Visible
 stopBatch.AutoButtonColor = handoff.Visible
 ui.TopCard.Visible=not toast.Visible and not shopOpen
 ui.StorageStatus.Visible=not toast.Visible and not shopOpen and(not Theme.IsMobile(ui)or ui.StorageStatus:GetAttribute("Alert18")==true)
 ui.Actions.Visible=not ui:GetAttribute("OrderOptionsOpen") and not shopOpen and not toast.Visible and(not mobile or not (ui:GetAttribute("MobileTargetOpen18") or ui:GetAttribute("MobileMenuOpen18")))
 local backdrop=ui:FindFirstChild("ShopBackdrop")if backdrop then backdrop.Visible=ui.Shop.Visible end
 impact.Visible=os.clock()<noticeExpires and not shopOpen
 local p=ownPackage()
 if p then
  local label=p:FindFirstChild("Label")
  if label then
   label.Enabled=state.status=="Dropped"
   label.TextLabel.Text=string.format("PAKETMU · %d/100\nAmbil ulang atau pulihkan",state.condition or 0)
  end
  for _,face in ipairs({"ShippingFront","ShippingBack"}) do
   local gui=p:FindFirstChild(face)
   local handling=gui and gui:FindFirstChild("Handling",true)
   local brand = gui and gui:FindFirstChild("Brand", true)
   local chapter = state.storyChapter and Story.Chapter(state.storyChapter)
   if brand then brand.Text = chapter and string.upper(chapter.cargo) or "PAKET KILAT!" end
   if handling then handling.Text=state.packageType=="Rapuh" and "RAPUH  /  JAGA BENTURAN" or "KIRIM DENGAN HATI" end
  end
 end
 local world=workspace:FindFirstChild("PaketKilat")
 local map=world and world:FindFirstChild("Map")
 local target=state.status=="Dropped" and p or nil
 if map and not target then
  if state.status=="Idle" then
   local offer=state.relayOffer
   local depot=map:FindFirstChild('Depot')local pickup=depot and depot:FindFirstChild('PickupPoint')
   local char=player.Character local r=char and char:FindFirstChild('HumanoidRootPart')
   local atDepot=r and pickup and(r.Position-pickup.Position).Magnitude<=Config.ActionDistance
   if offer and workspace:GetServerTimeNow()<offer.expiresAt and not atDepot then
    local source=map:FindFirstChild(offer.sourceId)target=source and source:FindFirstChild('DestinationPoint')
   else target=pickup end
  elseif state.status=="Carrying" then
   local route=workspace:FindFirstChild('PaketKilatLocalSafeRoute')
   local id=state.stampNavigation and route and route:GetAttribute('GuidedStampId26')
   if id and state.routeBonus.visited[id]then id=nil end
   local stations=map.City13:FindFirstChild('Stations')
   if id and stations then target=stations:FindFirstChild(id)end
   if not target then local house=map:FindFirstChild(state.destinationId or "") target=house and house:FindFirstChild("DestinationPoint")end
  end
 end
 highlight.Adornee=target
 highlight.Enabled=state.profileReady==true and target~=nil and not state.outOfBounds and not shopOpen
end
connect(remote.StateChanged.OnClientEvent,function(snapshot,code)
 state=snapshot
 if code=="Delivered" and snapshot.lastResult then
  local result=snapshot.lastResult
  -- Delivered uses the server order ID/result. Replay failures never trigger this branch.
  local key=result.orderId or snapshot.orderId or (tostring(result.destinationName)..":"..tostring(result.duration)..":"..tostring(snapshot.deliveryCount))
  if key~=shownOrder then
   shownOrder = key
   noticeExpires, handoffExpires = 0, 0
   handoffPausedAt=nil
   if result.isBatch and snapshot.batch and snapshot.status == "Carrying" and snapshot.orderId
    and result.batchIndex < result.batchTotal then
    expires = 0
    handoffOrder = snapshot.orderId
    handoffExpires = os.clock() + 7
    refresh()
    spawnDeliveryConfetti()
    return
   end
   expires = os.clock() + (result.storyChapter and 8 or 5)
   title.Text=result.newRecord and "REKOR BARU!"or result.rating and result.rating.stars==3 and "KIRIMAN SEMPURNA!"or "PENGANTARAN BERHASIL"
   countFrom=os.clock()countTotal=result.total reward.Text='+0 KOIN'
   local rating=result.rating
   stars.Text=rating and (string.rep('★',rating.stars)..string.rep('☆',3-rating.stars)..' · '..rating.name)or 'PAKET TERKIRIM'
   ratingHint.Text=rating and rating.stars==3 and 'Paket utuh dan tiba tepat waktu.'or rating and rating.stars==2 and(not rating.onTime and 'Paket aman. Coba tiba lebih cepat.'or 'Paket aman. Jaga kondisinya lebih tinggi.')or result.recoveryCount>0 and 'Coba antar tanpa memulihkan paket.'or 'Paket terkirim. Kurangi benturan.'
   if result.contractKind then ratingHint.Text=result.contractSucceeded and ('Kontrak berhasil · bonus +'..result.contractBonus)or ('Kontrak: '..(result.contractStatus and result.contractStatus.reason or 'syarat belum terpenuhi'))end
   streak.Text=string.format('Rapi beruntun %d · terbaik sesi %d',result.cleanStreak or 0,result.bestCleanStreak or 0)
   local extras={}
   for _,item in ipairs({{'Cap',result.routeBonus},{'Kerja',result.jobBonus},{'Target',result.challengeBonus},{'Kontrak',result.contractBonus},{'Borongan',result.batchBonus},{'Pangkat',result.rankBonus},{'Mingguan',result.weeklyBonus},{'Cerita',result.storyBonus},{'Jaga paket',result.storyCareBonus}})do if(item[2]or 0)>0 then table.insert(extras,item[1]..' +'..item[2])end end
   detail.Text=string.format('Dasar %d · Kondisi %d · Waktu %d\n%s',result.baseReward,result.conditionBonus,result.timeBonus,#extras>0 and table.concat(extras,' · ')or result.isBatch and result.batchIndex<result.batchTotal and 'Bonus finish dinilai setelah 3 kiriman.'or 'Tanpa bonus tambahan')
   if result.isBatch then
    title.Text = result.batchInterrupted and "BORONGAN TERHENTI" or "BORONGAN SELESAI!"
    ratingHint.Text = result.batchInterrupted and "Kiriman ini tetap dibayar."
     or result.batchBonusEligible and ("Bonus akhir +" .. result.batchBonus) or "Bonus akhir gugur: paket dipulihkan."
    streak.Text=string.format('Borongan +%d terkumpul · %.1f dtk',result.batchEarned,result.batchDuration)
   end
   if not result.isBatch and (result.challengeBonus or 0)>0 then
    title.Text="TARGET TERCAPAI!"
   end
   if result.storyChapter then
    local chapter = Story.Chapter(result.storyChapter)
    title.Text = result.storyFinished and "PAMERAN DIBUKA!" or "BAB CERITA SELESAI!"
    ratingHint.Text = string.format("Bab %d · %s", result.storyChapter, chapter.title)
    local nextOffer = snapshot.story and snapshot.story.offer
    streak.Text = nextOffer and ("Berikutnya di depot · " .. nextOffer.name) or "Lihat panel foto di depan galeri."
    if result.storyCareTarget then
     stars.Text = result.storyCareBonus > 0 and ("★ Jaga paket +" .. result.storyCareBonus)
      or result.recoveryCount > 0 and "Bonus gugur · paket dipulihkan"
      or string.format("Kondisi %d/100 · target %d", result.condition, result.storyCareTarget)
    end
   elseif result.promotion then
    title.Text = "NAIK PANGKAT!"
    ratingHint.Text = result.promotion
   elseif (result.weeklyBonus or 0) > 0 then
    title.Text = "RUTE MINGGUAN SELESAI!"
   elseif result.isExpress and result.contractSucceeded then
    title.Text = "EKSPRES BERHASIL!"
   end
   if result.weeklyProgress and not result.storyChapter then
    streak.Text = string.format("Target mingguan · %d/3 selesai", result.weeklyProgress)
   elseif result.contractStatus and result.contractStatus.timeLimit then
    streak.Text = string.format("Waktu %.1f dtk · target ≤%d dtk",result.duration,result.contractStatus.timeLimit)
   end
   detail.TextWrapped=true
   detail.TextSize=11

   if tween then tween:Cancel() end
   scale.Scale=.88 tween=TweenService:Create(scale,TweenInfo.new(.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}) tween:Play()
   spawnDeliveryConfetti()
  end
 elseif code == "HardLanding" then
  impact.Text = string.format("MENDARAT KERAS · kondisi %d/100", snapshot.condition or 0)
  noticeExpires = os.clock() + 1.8
   spawnImpactPuff()
 elseif code=="Impact" or code=="Slip" or code=="Barrier" or code=="GripLost" then
  impact.Text=string.format("PAKET TERLEPAS  /  kondisi %d",snapshot.condition or 0)
  noticeExpires=os.clock()+2
   spawnImpactPuff()
 elseif code=="Recover" then
  impact.Text="Paket kembali ke petak pemulihan" noticeExpires=os.clock()+2
 elseif code=="Start" or code=="RelaySkipped" or code=="Respawned" or code=="Cancelled" or code=="BatchCancelled" then
  expires, noticeExpires, handoffExpires = 0, 0, 0
 end
 refresh()
end)
connect(stopBatch.Activated, function()
 if handoff.Visible and state.batch and state.orderId == handoffOrder then
  ui:SetAttribute("OpenOrderOptionsRequest",handoffOrder)
 end
end)
local function dismissResult()
 toast:SetAttribute("DismissedOrder22", shownOrder)
 expires = 0
 refresh()
end
connect(careerButton.Activated, function()
 if not toast.Visible then return end
 dismissResult()
 local storyResult = state.lastResult and state.lastResult.storyChapter
 ui:SetAttribute(storyResult and "OpenStoryFromResult" or "OpenCareerFromResult", true)
 ui:SetAttribute("JobBoardOpen17", true)
end)
connect(depotButton.Activated, function()
 if not toast.Visible then return end
 local offer = currentRelay()
 if offer then remote.ActionRequest:FireServer("SkipRelay", offer.id) else dismissResult() end
end)
connect(relayButton.Activated, function()
 local offer = currentRelay()
 if not toast.Visible or not offer then return end
 if nearRelay(offer) then remote.ActionRequest:FireServer("AcceptRelay", offer.id) else dismissResult() end
end)
connect(close.Activated, dismissResult)
local elapsed=0
local pulseTime = 0
connect(RunService.Heartbeat,function(dt)
 pulseTime += dt
 if highlight and highlight.Enabled then
  highlight.FillTransparency = 0.72 + 0.16 * math.sin(pulseTime * 3.5)
  highlight.OutlineTransparency = 0.05 + 0.15 * math.sin(pulseTime * 3.5)
 end
 elapsed+=dt
 if elapsed>=.1 then elapsed=0 refresh() end
end)
connect(player.CharacterAdded,function() expires, noticeExpires, handoffExpires = 0, 0, 0 highlight.Enabled=false end)
connect(script.Destroying,function()
 for _,c in ipairs(connections) do c:Disconnect() end
 if tween then tween:Cancel() end
 highlight:Destroy() toast:Destroy() impact:Destroy() handoff:Destroy()
end)
-- Request the current authoritative state if initial events preceded this script.
task.delay(.6,function() if script.Parent then remote.ActionRequest:FireServer("Sync") end end)

