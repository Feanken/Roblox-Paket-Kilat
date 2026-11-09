-- Edit-only recovery installer. Do not rerun on Polish02. No publish/save API calls.
assert(workspace.PaketKilat:GetAttribute("VisualRevision")=="Polish01","Apply Polish01 first")
assert(not game.StarterPlayer.StarterPlayerScripts:FindFirstChild("PaketKilatFeedback"),"Polish02 exists; inspect before changing")
local backup=Instance.new("Folder") backup.Name="PaketKilat_PrePolish02"
assert(not game.ServerStorage:FindFirstChild(backup.Name),"Inspect existing backup first")
game.ServerStorage.PaketKilat.PackageTemplate:Clone().Parent=backup
game.StarterPlayer.StarterPlayerScripts.PaketKilatInput:Clone().Parent=backup
game.StarterGui.PaketKilatUI:Clone().Parent=backup backup.Parent=game.ServerStorage
(function()
-- Edit-only, additive SurfaceGui decoration; no new physics bodies or scripts.
local p=game.ServerStorage.PaketKilat.PackageTemplate
assert(not p:FindFirstChild("ShippingFront"),"P02 template already installed")
local function frame(parent,size,pos,color)
 local f=Instance.new("Frame") f.BorderSizePixel=0 f.Size=size f.Position=pos f.BackgroundColor3=color f.Parent=parent return f
end
local cream=Color3.fromRGB(245,232,202)
local ink=Color3.fromRGB(33,76,76)
for _,face in ipairs({Enum.NormalId.Top,Enum.NormalId.Front,Enum.NormalId.Back}) do
 local g=Instance.new("SurfaceGui") g.Name="Shipping"..face.Name g.Face=face
 g.CanvasSize=Vector2.new(480,360) g.LightInfluence=.7 g.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize g.Parent=p
 frame(g,UDim2.fromScale(.14,1),UDim2.fromScale(.43,0),cream)
 if face==Enum.NormalId.Top then
  frame(g,UDim2.fromScale(1,.08),UDim2.fromScale(0,.46),cream)
 else
  local label=frame(g,UDim2.fromScale(.72,.66),UDim2.fromScale(.14,.17),cream)
  local t=Instance.new("TextLabel") t.Name="Brand" t.Size=UDim2.fromScale(.9,.28) t.Position=UDim2.fromScale(.05,.05)
  t.BackgroundTransparency=1 t.TextColor3=ink t.Text="PAKET KILAT!" t.Font=Enum.Font.GothamBlack t.TextScaled=true t.Parent=label
  local sub=t:Clone() sub.Name="Handling" sub.Position=UDim2.fromScale(.05,.38) sub.Size=UDim2.fromScale(.9,.18)
  sub.Font=Enum.Font.GothamMedium sub.Text="KIRIM DENGAN HATI" sub.Parent=label
  for i=1,20 do frame(label,UDim2.new(0,i%3==0 and 6 or 3,.2,0),UDim2.new(.1,i*11,.7,0),ink) end
 end
end
p.Material=Enum.Material.SmoothPlastic
p.Label.MaxDistance=30 p.Label.Size=UDim2.fromOffset(160,38)
p.Label.TextLabel.TextSize=12
p.Label.TextLabel.BackgroundColor3=ink
return "Shipping label and packing tape added; original collider retained"

end)()
game.StarterPlayer.StarterPlayerScripts.PaketKilatInput.Source=[====[local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage"):WaitForChild("PaketKilat")
local C = require(RS.Shared.Config)
local ui = player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI").Root
local card, actions = ui.TopCard, ui.Actions
local state, synced = {status = "Idle", profileReady=false}, false
local shop=ui:WaitForChild("Shop")
local shopOpen=false
local guide=ui:WaitForChild("Guide")
local guideDismissed,guideManual=false,false
local feedback, feedbackUntil = "", 0
local messages = {
	TooFar = "Dekati titik tujuan atau paket terlebih dahulu.",
	WrongDestination = "Rumah ini bukan tujuan pesananmu.",
	NotOwnerOrStale = "Paket ini bukan pesanan aktifmu.",
	OrderActive = "Selesaikan pesanan yang sedang aktif.",
	InvalidState = "Aksi belum tersedia untuk paket ini.",
	RecoveryCooldown = "Pemulihan masih menunggu jeda.",
	NotAlive = "Menunggu muncul kembali di depot...",
	Respawned = "Siap! Ambil pesanan di depot.",
	Cancelled = "Pesanan dibatalkan. Saldo tetap.",
	Impact = "Paket terbentur! Dekati paket atau pulihkan.",
	OutOfBounds = "Paket jatuh. Pulihkan untuk kembali ke depot.",
	Recover = "Pulih (-20). Ambil ulang; perjalanan tanpa rekor.",
	Drop = "Paket dilepas. Dekati untuk mengambil ulang.",
	Pickup = "Paket dibawa kembali. Ayo ke rumah tujuan!",
	Start = "Pesanan diambil. Ikuti penanda tujuan.",
	Slip = "Licin! Paket terlepas. Ambil ulang atau pulihkan.",
	Barrier = "Terkena penghalang! Ambil ulang atau pulihkan.",
	UnavailableDestination = "Titik tujuan belum siap.",
	InvalidArguments = "Permintaan tidak valid.",
	PlayerInactive = "Menunggu sesi siap...",
 ProfileUnavailable="Profil belum siap. Ekonomi dikunci; data lama dilindungi.",
 AlreadyOwned="Tas sudah dimiliki. Koin tidak dipotong.",
 InsufficientCoins="Koin belum cukup.",
 NotOwned="Tas ini belum dimiliki.",
 UnknownCosmetic="Tas tidak dikenal.",
 Purchased="Tas dibeli. Tekan Pakai untuk mengenakannya.",
 Equipped="Tas dipakai.",
	CompletionLocked = "Pesanan sedang diselesaikan.",
}
local marker = Instance.new("Part")
marker.Name, marker.Anchored, marker.Transparency = "PaketKilat_LocalDestination", true, 1
marker.CanCollide, marker.CanTouch, marker.CanQuery, marker.Archivable = false, false, false, false
marker.Parent = workspace
local label = Instance.new("BillboardGui")
label.Name, label.Size, label.StudsOffset = "DestinationMarker", UDim2.fromOffset(180,48), Vector3.new(0,5,0)
label.AlwaysOnTop, label.MaxDistance, label.Enabled, label.Parent = true, 500, false, marker
local markerText = Instance.new("TextLabel")
markerText.Size, markerText.BackgroundColor3 = UDim2.fromScale(1,1), Color3.fromRGB(27,42,58)
markerText.BackgroundTransparency, markerText.TextColor3 = 0.15, Color3.fromRGB(255,211,97)
markerText.Font, markerText.TextSize, markerText.TextWrapped = Enum.Font.GothamBold, 15, true
markerText.Parent = label
local sfx=Instance.new("Folder")
sfx.Name="PaketKilatSFX"
sfx.Parent=game:GetService("SoundService")
local cues={}
for name,settings in pairs(C.Audio) do
	local sound=Instance.new("Sound")
	sound.Name,sound.SoundId,sound.Volume,sound.PlaybackSpeed=name,settings.Id,settings.Volume,settings.Speed
	sound:SetAttribute("PlayCount",0)
	sound:SetAttribute("EndedCount",0)
	sound.Ended:Connect(function() sound:SetAttribute("EndedCount",(sound:GetAttribute("EndedCount") or 0)+1) end)
	sound.Parent=sfx
	cues[name]=sound
end
task.spawn(function()
	local list={}
	for _,sound in pairs(cues) do table.insert(list,sound) end
	local ok,err=pcall(function() ContentProvider:PreloadAsync(list) end)
	sfx:SetAttribute("PreloadSucceeded",ok)
	if not ok then warn("[PaketKilat] Audio preload:",err) end
end)
local function cue(name)
	local sound=cues[name]
	sound:Stop()
	sound:Play()
	sound:SetAttribute("PlayCount",(sound:GetAttribute("PlayCount") or 0)+1)
	local stroke=card:FindFirstChildWhichIsA("UIStroke")
	if stroke then
		stroke.Color=name=="Impact" and Color3.fromRGB(255,128,91) or Color3.fromRGB(109,236,175)
		TweenService:Create(stroke,TweenInfo.new(0.6),{Color=Color3.fromRGB(75,109,132)}):Play()
	end
end
local function aliveRoot()
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart") or nil
end
local function near(point)
	local r = aliveRoot()
	return r ~= nil and typeof(point) == "Vector3" and (r.Position-point).Magnitude <= C.ActionDistance
end
local function ownPackage()
	local world = workspace:FindFirstChild("PaketKilat")
	local folder = world and world:FindFirstChild("ActivePackages")
	if folder then
		for _,p in ipairs(folder:GetChildren()) do
			if p:GetAttribute("orderId") == state.orderId and p:GetAttribute("ownerUserId") == player.UserId then return p end
		end
	end
end
local function button(b, action, text, enabled, key)
	b:SetAttribute("Action",action)
	b:SetAttribute("ActionEnabled",enabled)
	b.Active, b.AutoButtonColor = enabled, enabled
	b.Text = text .. ((not UIS.TouchEnabled and key) and (" ["..key.."]") or "")
	b.BackgroundColor3 = enabled and Color3.fromRGB(255,202,77) or Color3.fromRGB(54,73,91)
	b.TextColor3 = enabled and Color3.fromRGB(27,42,58) or Color3.fromRGB(181,197,208)
end
local function bestText(value)
	return value and string.format("%.1f dtk",value) or "—"
end
local function render()
	local w=ui.AbsoluteSize.X
 local onboarding=state.onboarding or {stage="FindDepot"}
 local perfShowing=ui:GetAttribute("PerfShowing")==true
 guide.FPS.Visible=guideManual or perfShowing
 guide.Hint.Size=UDim2.new(1,(guideManual or perfShowing) and -124 or -70,1,-12)
 guide.Size=UDim2.fromOffset(math.min(C.Onboarding.Width,math.max(260,w-290)),C.Onboarding.Height)
 guide.Visible=not shopOpen and synced and state.profileReady==true and (perfShowing or guideManual or not guideDismissed and onboarding.stage~="Complete")
 local guideStage=state.status=="Dropped" and "Dropped" or onboarding.stage
 guide.Hint.Text=perfShowing and (ui:GetAttribute("PerfText") or "Mengukur FPS...") or (C.Onboarding[guideStage] or C.Onboarding.FindDepot)
	card.Size=UDim2.fromOffset(math.clamp(w*0.42,270,360),156)
	card.Coins.Text=state.profileReady and string.format("%d koin",state.coins) or "— koin"
 ui.StorageStatus.Size=UDim2.fromOffset(card.AbsoluteSize.X,38)
 if not state.profileReady then
  ui.StorageStatus.Text=state.profileStatus=="Loading" and "Memuat profil. Mohon tunggu..." or "Profil tidak tersedia. Ekonomi dikunci. Coba masuk ulang."
 elseif state.storageMode=="StudioMemory" then ui.StorageStatus.Text="UJI LOKAL · progres hilang saat Stop"
 else
  ui.StorageStatus.Text=state.saveStatus=="Acknowledged" and "DataStore UJI · tersimpan"
    or state.saveStatus=="Saving" and "DataStore UJI · menyimpan..."
    or state.saveStatus=="RetryPending" and "Simpan gagal · menunggu percobaan ulang"
    or "DataStore UJI · perubahan menunggu simpan"
 end
 shop.Visible=shopOpen
 shop.Size=UDim2.fromOffset(math.min(430,w-28),300)
 ui.ShopToggle.Text=UIS.TouchEnabled and "Toko tas" or "Toko [B]"
 shop.Info.Text=os.clock()<feedbackUntil and feedback or "Beli/pakai dekat depot. Tas tidak menambah kecepatan."
 for _,id in ipairs(C.CosmeticOrder) do
  local b=shop[id].Action
  local owned=state.ownedCosmetics and state.ownedCosmetics[id]
  local equipped=state.equippedCosmetic==id
  b.Text=equipped and "Dipakai" or owned and "Pakai" or ("Beli "..C.Cosmetics[id].Price)
  b.Active=state.profileReady==true and not equipped
  b.AutoButtonColor=b.Active
 end
	local last,nextOrder=state.lastResult,state.nextOrder
	local condition=state.condition or (last and last.condition) or 0
	card.ConditionTrack.Fill.Size=UDim2.fromScale(math.clamp(condition/100,0,1),1)
	card.ConditionTrack.Fill.BackgroundColor3=condition>40 and Color3.fromRGB(98,222,175) or Color3.fromRGB(255,170,91)
	if state.status=="Idle" then
		card.Destination.Text=last and ("Selesai · "..last.destinationName) or ("Berikut · "..(nextOrder and nextOrder.destinationName or C.DestinationName))
		card.ConditionText.Text=last and string.format("%s · %d/100 · %.1f dtk",last.packageType,last.condition,last.duration)
			or string.format("%s · Rekor %s",nextOrder and nextOrder.packageType or C.PackageType,bestText(nextOrder and nextOrder.bestTime))
	else
		card.Destination.Text="Tujuan · "..(state.destinationName or C.DestinationName)
		card.ConditionText.Text=string.format("%s · %d/100 · Rekor %s",state.packageType,condition,bestText(state.currentBestTime))
	end
	if os.clock()<feedbackUntil then card.Hint.Text=feedback
	elseif state.status=="Idle" and last then
		local record=not last.recordEligible and "Tanpa rekor: paket dipulihkan"
			or (last.newRecord and ("REKOR BARU: "..bestText(last.bestTime)) or ("Terbaik: "..bestText(last.bestTime)))
		card.Hint.Text=string.format("+%d: dasar %d · kondisi %d · waktu %d\n%s",last.total,last.baseReward,last.conditionBonus,last.timeBonus,record)
	elseif state.status=="Carrying" then
		card.Hint.Text=state.packageType=="Rapuh" and "RAPUH: benturan lebih merusak. Jaga paket!" or "Pilih jalan aman atau pintasan. Antar di petak rumah."
	elseif state.status=="Dropped" then card.Hint.Text="Ambil ulang, atau pulihkan (-20; tanpa rekor)."
	else card.Hint.Text="Lima rumah, dua jenis paket. Ambil di depot." end
	actions.Secondary.Visible=state.status~="Idle" and synced and state.profileReady and not shopOpen
	if not synced or not state.profileReady or shopOpen then button(actions.Primary,"",shopOpen and "Toko dibuka" or "Memuat profil...",false)
	elseif state.status=="Idle" then button(actions.Primary,"Start",near(state.depotPosition) and C.Labels.Start or "Ke depot",near(state.depotPosition),"E")
	elseif state.status=="Carrying" then
		button(actions.Primary,"Deliver",near(state.destinationPosition) and C.Labels.Deliver or "Ke rumah",near(state.destinationPosition),"E")
		button(actions.Secondary,"Drop",C.Labels.Drop,aliveRoot()~=nil,"Q")
	elseif state.status=="Dropped" then
		local p=ownPackage()
		local canPickup=p~=nil and not state.outOfBounds and near(p.Position)
		button(actions.Primary,"Pickup",canPickup and C.Labels.Pickup or "Ke paket",canPickup,"E")
		local remaining=math.max(0,C.RecoveryCooldown-(workspace:GetServerTimeNow()-(state.lastRecoveryAt or -100)))
		button(actions.Secondary,"Recover",remaining>0 and string.format("Pulihkan (%d)",math.ceil(remaining)) or C.Labels.Recover,remaining<=0 and aliveRoot()~=nil,"R")
	end
	local dropped=state.status=="Dropped" and ownPackage() or nil
	local markerTarget=state.status=="Idle" and state.depotPosition
		or (dropped and not state.outOfBounds and dropped.Position or state.destinationPosition)
	label.Enabled=synced and state.profileReady==true and markerTarget~=nil
		and not shopOpen and not state.outOfBounds
		and (state.status~="Idle" or not near(state.depotPosition))
	if label.Enabled then
		marker.CFrame=CFrame.new(markerTarget)
		local root=aliveRoot()
		local distance=root and math.floor((root.Position-markerTarget).Magnitude+.5) or 0
		local title=state.status=="Idle" and "DEPOT" or state.status=="Dropped" and "PAKETMU" or state.destinationName
		markerText.Text=string.format("%s\n%d stud · %s",title,distance,state.status=="Dropped" and "Ambil ulang" or state.status=="Idle" and "Ambil pesanan" or "Antar ke sini")
	end
end
local function activate(b)
	if not shopOpen and state.profileReady and b:GetAttribute("ActionEnabled") then
		local action=b:GetAttribute("Action")
		RS.Remotes.ActionRequest:FireServer(action,state.orderId,action=="Deliver" and state.destinationId or nil)
	end
end
ui.HelpToggle.Activated:Connect(function()
 guideManual=true guideDismissed=false
 render()
end)
guide.Close.Activated:Connect(function()
 guideDismissed=true guideManual=false ui:SetAttribute("PerfShowing",false) render()
end)
ui.ShopToggle.Activated:Connect(function() shopOpen=not shopOpen render() end)
shop.Close.Activated:Connect(function() shopOpen=false render() end)
CAS:BindAction("PKShop",function(_,input)
 if input==Enum.UserInputState.Begin then shopOpen=not shopOpen render() end
 return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.B)
for _,id in ipairs(C.CosmeticOrder) do
 shop[id].Action.Activated:Connect(function()
  if not state.profileReady or state.equippedCosmetic==id then return end
  local owned=state.ownedCosmetics and state.ownedCosmetics[id]
  RS.Remotes.ActionRequest:FireServer(owned and "EquipCosmetic" or "BuyCosmetic",id)
 end)
end
actions.Primary.Activated:Connect(function() activate(actions.Primary) end)
actions.Secondary.Activated:Connect(function() activate(actions.Secondary) end)
CAS:BindAction("PKInteract",function(_,s)
	if s == Enum.UserInputState.Begin then activate(actions.Primary) end
	return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.E)
CAS:BindAction("PKDrop",function(_,s)
	if s == Enum.UserInputState.Begin and state.status == "Carrying" then activate(actions.Secondary) end
	return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.Q)
CAS:BindAction("PKRecover",function(_,s)
	if s == Enum.UserInputState.Begin and state.status == "Dropped" then activate(actions.Secondary) end
	return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.R)
RS.Remotes.StateChanged.OnClientEvent:Connect(function(snapshot,code)
	state,synced = snapshot,true
	ui:SetAttribute("Status",state.status)
 ui:SetAttribute("ProfileReady",state.profileReady)
 ui:SetAttribute("ProfileStatus",state.profileStatus)
 ui:SetAttribute("EquippedCosmetic",state.equippedCosmetic)
 ui:SetAttribute("SaveStatus",state.saveStatus)
	ui:SetAttribute("LastCode",code)
	ui:SetAttribute("Coins",state.coins)
	ui:SetAttribute("OrderId",state.orderId)
	if code=="Start" or code=="Pickup" then cue("Pickup")
	elseif code=="Impact" or code=="Slip" or code=="Barrier" then cue("Impact")
	elseif code=="Delivered" then cue("Delivered") end
	if messages[code] then feedback,feedbackUntil = messages[code],os.clock()+3
	elseif code == "Delivered" then feedbackUntil=0 end
	render()
end)
player.CharacterAdded:Connect(function()
	task.delay(0.5,function() RS.Remotes.ActionRequest:FireServer("Sync") end)
end)
local elapsed=0
RunService.Heartbeat:Connect(function(dt)
	elapsed+=dt
	if elapsed>=C.UIUpdateInterval then elapsed=0; render() end
end)
render()
RS.Remotes.ActionRequest:FireServer("Sync")
task.spawn(function()
	while task.wait(1) do
		if not synced or state.profileStatus=="Loading" then RS.Remotes.ActionRequest:FireServer("Sync") end
	end
end)
]====]
local feedback=Instance.new("LocalScript") feedback.Name="PaketKilatFeedback"
feedback.Source=[====[-- Presentation only. All rewards/statuses originate from existing server snapshots.
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local remote=game.ReplicatedStorage:WaitForChild("PaketKilat").Remotes
local ui=player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI").Root
local state,shownOrder={},nil
local connections={}
local function connect(signal,fn) local c=signal:Connect(fn) table.insert(connections,c) return c end
local function text(parent,name,size,pos,value,fontSize)
 local t=Instance.new("TextLabel") t.Name=name t.Size=size t.Position=pos t.BackgroundTransparency=1
 t.Text=value t.TextColor3=Color3.fromRGB(247,239,217) t.Font=Enum.Font.GothamBold t.TextSize=fontSize t.Parent=parent return t
end
local toast=Instance.new("Frame") toast.Name="DeliveryCelebration" toast.AnchorPoint=Vector2.new(.5,.5)
toast.Position=UDim2.fromScale(.5,.48) toast.Size=UDim2.fromOffset(330,148)
toast.BackgroundColor3=Color3.fromRGB(25,76,73) toast.BorderSizePixel=0 toast.Visible=false toast.ZIndex=20 toast.Active=false toast.Parent=ui
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,16) corner.Parent=toast
local stroke=Instance.new("UIStroke") stroke.Color=Color3.fromRGB(241,198,99) stroke.Thickness=2 stroke.Parent=toast
local scale=Instance.new("UIScale") scale.Parent=toast
local title=text(toast,"Title",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,12),"PAKET SAMPAI!",18)
local reward=text(toast,"Reward",UDim2.new(1,-24,0,44),UDim2.fromOffset(12,38),"",32)
local detail=text(toast,"Detail",UDim2.new(1,-24,0,24),UDim2.fromOffset(12,82),"",13)
local nextStep=text(toast,"Next",UDim2.new(1,-24,0,26),UDim2.fromOffset(12,111),"",12)
for _,t in ipairs({title,reward,detail,nextStep}) do t.ZIndex=21 end
reward.TextColor3=Color3.fromRGB(255,209,100)
local impact=Instance.new("TextLabel") impact.Name="PackageNotice" impact.AnchorPoint=Vector2.new(.5,0)
impact.Position=UDim2.fromScale(.5,.06) impact.Size=UDim2.fromOffset(310,36) impact.Visible=false
impact.BackgroundColor3=Color3.fromRGB(106,52,42) impact.TextColor3=Color3.fromRGB(255,234,201)
impact.Font=Enum.Font.GothamBold impact.TextSize=14 impact.BorderSizePixel=0 impact.ZIndex=22 impact.Active=false impact.Parent=ui
local ic=corner:Clone() ic.Parent=impact
local highlight=Instance.new("Highlight") highlight.Name="PaketKilatLocalFocus"
highlight.DepthMode=Enum.HighlightDepthMode.Occluded highlight.FillTransparency=.85
highlight.OutlineTransparency=.1 highlight.FillColor=Color3.fromRGB(255,208,96)
highlight.OutlineColor=Color3.fromRGB(255,208,96) highlight.Parent=workspace
local expires,noticeExpires=0,0
local tween
local function ownPackage()
 local world=workspace:FindFirstChild("PaketKilat")
 local active=world and world:FindFirstChild("ActivePackages")
 if active then for _,p in ipairs(active:GetChildren()) do
  if p:GetAttribute("ownerUserId")==player.UserId and p:GetAttribute("orderId")==state.orderId then return p end
 end end
end
local function refresh()
 local width,height=ui.AbsoluteSize.X,ui.AbsoluteSize.Y
 toast.Size=UDim2.fromOffset(math.min(330,math.max(260,width-40)),148)
 -- Keep transient notices below the upper HUD on short landscape screens.
 impact.Position=UDim2.new(.5,0,0,math.min(216,height*.59))
 impact.Size=UDim2.fromOffset(math.min(310,width-32),36)
 local shopOpen=ui.Shop.Visible
 toast.Visible=os.clock()<expires and not shopOpen
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
   if handling then handling.Text=state.packageType=="Rapuh" and "RAPUH  /  JAGA BENTURAN" or "KIRIM DENGAN HATI" end
  end
 end
 local world=workspace:FindFirstChild("PaketKilat")
 local map=world and world:FindFirstChild("Map")
 local target=state.status=="Dropped" and p or nil
 if map and not target then
  if state.status=="Idle" then target=map.Depot.PickupPoint
  elseif state.status=="Carrying" then
   local house=map:FindFirstChild(state.destinationId or "") target=house and house:FindFirstChild("DestinationPoint")
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
   shownOrder=key expires=os.clock()+4.5 noticeExpires=0
   title.Text=result.newRecord and "REKOR BARU!" or "PAKET SAMPAI!"
   reward.Text=string.format("+%d KOIN",result.total)
   detail.Text=string.format("Dasar %d  +  Kondisi %d  +  Waktu %d",result.baseReward,result.conditionBonus,result.timeBonus)
   nextStep.Text="Kembali ke depot untuk pesanan berikutnya"
   if tween then tween:Cancel() end
   scale.Scale=.88 tween=TweenService:Create(scale,TweenInfo.new(.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}) tween:Play()
  end
 elseif code=="Impact" or code=="Slip" or code=="Barrier" then
  impact.Text=string.format("PAKET TERLEPAS  /  kondisi %d",snapshot.condition or 0)
  noticeExpires=os.clock()+2
 elseif code=="Recover" then
  impact.Text="Paket kembali ke petak pemulihan" noticeExpires=os.clock()+2
 elseif code=="Start" or code=="Respawned" or code=="Cancelled" then
  expires=0 noticeExpires=0
 end
 refresh()
end)
local elapsed=0
connect(RunService.Heartbeat,function(dt) elapsed+=dt if elapsed>=.1 then elapsed=0 refresh() end end)
connect(player.CharacterAdded,function() expires=0 noticeExpires=0 highlight.Enabled=false end)
connect(script.Destroying,function()
 for _,c in ipairs(connections) do c:Disconnect() end
 if tween then tween:Cancel() end
 highlight:Destroy() toast:Destroy() impact:Destroy()
end)
-- Request the current authoritative state if initial events preceded this script.
task.delay(.6,function() if script.Parent then remote.ActionRequest:FireServer("Sync") end end)
]====] feedback.Parent=game.StarterPlayer.StarterPlayerScripts
workspace.PaketKilat:SetAttribute("ExperienceRevision","Polish02")
return "Polish02 restored; save local place through Studio"
