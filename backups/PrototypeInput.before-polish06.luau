local Players = game:GetService("Players")
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
