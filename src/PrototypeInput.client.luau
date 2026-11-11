local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage"):WaitForChild("PaketKilat")
local C = require(RS.Shared.Config)
local Story = require(RS.Shared:WaitForChild("CourierStory"))
local Theme = require(RS.Shared.UITheme12)
local ContractStatus=require(RS.Shared.ContractStatus25)
local Coach=require(RS.Shared:WaitForChild('JourneyCoach29'))
local ui = player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI").Root
local card, actions = ui.TopCard, ui.Actions
local state, synced = {status = "Idle", profileReady=false}, false
local shop=ui:WaitForChild("Shop")
local shopOpen=false
local guide=ui:WaitForChild("Guide")
local guideDismissed,guideManual=false,false
local hintOrder local seenHints={}
local hazards=workspace:WaitForChild('PaketKilat'):WaitForChild('Map'):WaitForChild('Expansion'):WaitForChild('Hazards')
Theme.Static(ui)
local feedback, feedbackUntil = "", 0
local messages = {
	TooFar = "Dekati titik tujuan atau paket terlebih dahulu.",
	WrongDestination = "Ini bukan tujuan pesananmu.",
	NotOwnerOrStale = "Paket ini bukan pesanan aktifmu.",
	OrderActive = "Selesaikan pesanan yang sedang aktif.",
	InvalidState = "Aksi belum tersedia untuk paket ini.",
	RecoveryCooldown = "Pemulihan masih menunggu jeda.",
 OfferExpired = "Daftar pesanan diperbarui. Pilih ulang di depot.",
 StoryChanged = "Bab cerita sudah berubah. Lihat kiriman berikutnya di depot.",
	NotAlive = "Menunggu muncul kembali di depot...",
	Respawned = "Siap! Ambil pesanan di depot.",
	Cancelled = "Pesanan dibatalkan. Saldo tetap.",
 BatchCancelled="Borongan dihentikan. Kiriman selesai tetap dibayar.",
	Impact = "Paket terbentur! Dekati paket atau pulihkan.",
	HardLanding = "Pendaratan keras. Kondisi paket berkurang.",
 GripLost = "Genggaman habis! Ambil paket, lalu kurangi sprint.",
 CityStamp = "Cap bonus didapat! Koin dibayar saat paket sampai.",
	OutOfBounds = "Paket jatuh. Pulihkan untuk kembali ke depot.",
	Recover = "Pulih (-20). Ambil ulang; perjalanan tanpa rekor.",
	Drop = "Paket dilepas. Dekati untuk mengambil ulang.",
	Pickup = "Paket dibawa kembali. Lanjut ke tujuan!",
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
 GripUpgraded="Sarung tangan ditingkatkan! Efek pada pesanan berikutnya.",
 UpgradeChanged="Level berubah. Periksa peningkatan berikutnya.",
 UpgradeMaxed="Sarung tangan sudah maksimal.",
 RelayExpired="Titipan sudah berakhir. Pilih pesanan di depot.",
 RelaySkipped="Titipan dilewati. Kembali ke depot saat siap.",
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
markerText.Size, markerText.BackgroundColor3 = UDim2.fromScale(1,1), Theme.Ink
markerText.BackgroundTransparency, markerText.TextColor3 = 0.08, Theme.Gold
markerText.Font, markerText.TextSize, markerText.TextWrapped = Enum.Font.GothamBold, 15, true
markerText.Parent = label
-- Audio33 owns sounds; keep this visual response so cues are never played twice.
local function cue(name)
 local stroke=card:FindFirstChildWhichIsA("UIStroke")
 if stroke then
  stroke.Color=name=="Impact" and Color3.fromRGB(255,128,91)or Color3.fromRGB(109,236,175)
  TweenService:Create(stroke,TweenInfo.new(.6),{Color=Theme.Line}):Play()
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
local function currentRelay()
 local offer=state.status=='Idle'and state.relayOffer
 return offer and workspace:GetServerTimeNow()<offer.expiresAt and offer or nil
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
	Theme.Action(b,enabled,b.Name=="Secondary")
end
local function bestText(value)
	return value and string.format("%.1f dtk",value) or "—"
end
local function render()
	local w=ui.AbsoluteSize.X
 local relay=currentRelay()
 ui:SetAttribute('RelayAvailable21',relay~=nil)
 local onboarding=state.onboarding or {stage="FindDepot"}
 local perfShowing=ui:GetAttribute("PerfShowing")==true
 guide.FPS.Visible=guideManual or perfShowing
 guide.Hint.Size=UDim2.new(1,(guideManual or perfShowing) and -124 or -70,1,-12)
 guide.Size=UDim2.fromOffset(math.min(C.Onboarding.Width,math.max(260,w-290)),C.Onboarding.Height)
 guide.Visible=not ui:GetAttribute("AudioOpen33")and not(Theme.IsMobile(ui)and(ui:GetAttribute("MobileMenuOpen18")or ui:GetAttribute("MobileTargetOpen18")))and not ui:GetAttribute("JobBoardOpen17")and not shopOpen and synced and state.profileReady==true and (perfShowing or guideManual or not Theme.IsMobile(ui)and not guideDismissed and onboarding.stage~="Complete")
 local guideStage=state.status=="Dropped" and "Dropped" or onboarding.stage
 guide.Hint.Text=perfShowing and (ui:GetAttribute("PerfText") or "Mengukur FPS...") or (C.Onboarding[guideStage] or C.Onboarding.FindDepot)
 if relay and not perfShowing then guide.Hint.Text='Ada titipan di rumah ini. Ambil untuk lanjut, atau Lewati untuk kembali ke depot.' end
	Theme.Layout(ui,guideManual or perfShowing)
	card.Coins.Text=state.profileReady and string.format("%d koin",state.coins) or "— koin"
 if Theme.IsMobile(ui)then card.Coins.TextSize=#card.Coins.Text>11 and 10 or 12 end
 ui.StorageStatus.Size=UDim2.fromOffset(card.Size.X.Offset,20)
 if not state.profileReady then
  ui.StorageStatus.Text=state.profileStatus=="Loading" and "Memuat profil. Mohon tunggu..." or "Profil gagal dimuat · coba masuk ulang."
 elseif state.storageMode=="StudioMemory" then ui.StorageStatus.Text="UJI LOKAL · progres hilang saat Stop"
 else
  ui.StorageStatus.Text=state.saveStatus=="Acknowledged" and "DataStore UJI · tersimpan"
    or state.saveStatus=="Saving" and "DataStore UJI · menyimpan..."
    or state.saveStatus=="RetryPending" and "Simpan gagal · menunggu percobaan ulang"
    or "DataStore UJI · perubahan menunggu simpan"
 end
 Theme.Storage(ui.StorageStatus,state)
 shop.Visible=shopOpen
 shop.Size=UDim2.fromOffset(math.min(620,w-24),272)
 ui.ShopToggle.Text=UIS.TouchEnabled and "Toko" or "Toko [B]"
 shop.Info.Text=os.clock()<feedbackUntil and feedback or(ui:GetAttribute("ShopTab20")=="gear"and "Upgrade dengan koin. Beli saat tidak membawa paket."or "Beli/pakai tas dekat depot. Pilih model tasmu.")
 for _,id in ipairs(C.CosmeticOrder) do
  local b=shop[id].Action
  local owned=state.ownedCosmetics and state.ownedCosmetics[id]
  local equipped=state.equippedCosmetic==id
  b.Text=equipped and "Dipakai" or owned and "Pakai" or ("Beli "..C.Cosmetics[id].Price)
  b.Active=state.profileReady==true and not equipped
  b.AutoButtonColor=b.Active
  Theme.Action(b,b.Active,false)
 end
	local last,nextOrder=state.lastResult,state.nextOrder
 local nextChapter = state.story and state.story.offer
 local firstDelivery = state.deliveryCount == 0
 local nearDepot = near(state.depotPosition)
	local condition=state.condition or (last and last.condition) or 0
	card.ConditionTrack.Fill.Size=UDim2.fromScale(math.clamp(condition/100,0,1),1)
	card.ConditionTrack.Fill.BackgroundColor3=condition>40 and Color3.fromRGB(57,151,127) or Color3.fromRGB(213,126,54)
 if relay then
  card.ConditionTrack.Fill.Size=UDim2.fromScale(math.clamp((relay.expiresAt-workspace:GetServerTimeNow())/math.max(1,relay.expiresAt-(relay.offeredAt or relay.expiresAt-60)),0,1),1)
  card.ConditionTrack.Fill.BackgroundColor3=Theme.Gold
 end
	if state.status=="Idle" then
		card.Destination.Text=relay and ('Titipan → '..relay.destinationName) or last and ("Selesai · "..last.destinationName) or "Pilih pesanan di depot"
		card.ConditionText.Text=relay and string.format('%s · %d dtk',near(relay.pickupPosition)and 'Ambil di sini' or 'Titipan tersedia',math.max(0,math.ceil(relay.expiresAt-workspace:GetServerTimeNow()))) or last and string.format("%s · %d/100 · %.1f dtk",last.packageType,last.condition,last.duration)
			or "3 pilihan · pilih risiko dan tujuan"
  if not relay and nextChapter then
   card.Destination.Text = firstDelivery and "Kiriman pertama" or string.format("Lanjut cerita · Bab %d", nextChapter.storyChapter)
   card.ConditionText.Text = nearDepot and nextChapter.destinationName or "Ikuti penanda ke depot"
  end
	else
		card.Destination.Text=state.destinationName or C.DestinationName
		card.ConditionText.Text=state.isRelay and string.format('Titipan · %d/100',condition) or string.format("%s · %d/100 · Rekor %s",state.packageType,condition,bestText(state.currentBestTime))
	end
	if state.batch and state.status~='Idle'then card.Destination.Text=string.format('%d/%d · %s',state.batch.index,state.batch.total,state.destinationName)end
 if Theme.IsMobile(ui)and state.status~="Idle"then
  local b=state.routeBonus
  card.ConditionText.Text=string.format("%s · %d/100%s",state.isRelay and 'Titipan' or state.packageType or "Paket",condition,b and string.format(" · cap %d/%d",b.count,b.limit)or "")
 end
 card.ConditionText.TextColor3=Theme.Muted
 local contractStatus
 if state.status=='Carrying'and state.contract then
  contractStatus=ContractStatus.Get(state.contract,{condition=condition,duration=math.max(0,workspace:GetServerTimeNow()-(state.startedAt or 0)),recoveryCount=state.recoveryCount or 0,stamps=state.routeBonus and state.routeBonus.count or 0})
  if Theme.IsMobile(ui)and contractStatus then
   card.ConditionText.Text=string.format('%d/100 · %s',condition,contractStatus.short)card.ConditionText.TextSize=9
   card.ConditionText.TextColor3=contractStatus.irreversible and Color3.fromRGB(177,85,48)or Theme.Ink
  end
 end
 if Theme.IsMobile(ui)and state.batch and state.status~='Idle'then card.ConditionText.Text=string.format('%s · %d/100 · sisa %d',state.packageType,condition,state.batch.remaining)end
 local storyChapter = state.storyChapter and Story.Chapter(state.storyChapter)
 if storyChapter and state.status == "Carrying" then
  card.ConditionText.Text = string.format("%s · %d/100 · Bab %d", state.packageType, condition, state.storyChapter)
  if storyChapter.careBonus then
   card.ConditionText.Text = state.recoveryCount and state.recoveryCount > 0
    and string.format("%d/100 · bonus gugur", condition)
    or string.format("%d/100 · ≥%d untuk +%d", condition, storyChapter.careCondition, storyChapter.careBonus)
  end
 end
 if os.clock()<feedbackUntil then card.Hint.Text=feedback
 elseif state.batch then
  local b=state.batch local next=b.stops[b.index+1]
  card.Hint.Text=string.format('BORONGAN %d/%d · finish %s\n%s',b.index,b.total,b.bonusEligible and('maks. +'..b.potentialBonus)or 'gugur: dipulihkan',next and('Berikut: '..next.name)or 'Kiriman terakhir · selesaikan rute')
 elseif contractStatus then
  card.Hint.Text=contractStatus.irreversible and ('KONTRAK GUGUR · '..contractStatus.reason..'\nPengantaran tetap dibayar. Lanjutkan ke tujuan.')
   or string.format('KONTRAK · bonus +%d saat diantar\n%s',state.contract.reward,contractStatus.short)

	elseif relay then card.Hint.Text='Pelanggan punya titipan ke rumah lain. Opsional: satu perjalanan lagi, tanpa kembali ke depot.'
 elseif state.status == "Carrying" and storyChapter then
  card.Hint.Text = firstDelivery and "Ikuti penanda tujuan. Berjalan menjaga genggaman." or storyChapter.brief
  if firstDelivery and not storyChapter.careBonus and Theme.IsMobile(ui) then
   card.ConditionText.Text = near(state.destinationPosition) and "Tekan Antar paket" or string.format("%d/100 · Ikuti penanda", condition)
  end
 elseif state.status == "Idle" and nextChapter then
  card.Hint.Text = nearDepot and nextChapter.description or "Ambil kiriman cerita berikutnya di depot."
	elseif state.status=="Idle" and last then
		local record=last.recordReason=='BatchRoute'and 'Borongan · rekor depot tetap'or last.recordReason=='RelayRoute' and 'Titipan selesai · rekor depot tetap' or not last.recordEligible and "Tanpa rekor: paket dipulihkan"
			or (last.newRecord and ("REKOR BARU: "..bestText(last.bestTime)) or ("Terbaik: "..bestText(last.bestTime)))
		card.Hint.Text=string.format("+%d koin · %s",last.total,record)
	elseif state.status=="Carrying" and state.routeBonus then
  local b=state.routeBonus
  card.Hint.Text=string.format("Pos bonus %d/%d · +%d koin\n%s",b.count,b.limit,b.total,b.count>=b.limit and "Cap lengkap! Antar paketmu."or "Opsional: lewati penanda emas di jalan.")
 elseif state.status=="Carrying" then
		card.Hint.Text=state.packageType=="Rapuh" and "RAPUH: benturan lebih merusak. Jaga paket!" or "Sprint lebih cepat; jaga meter genggaman paket."
	elseif state.status=="Dropped" then card.Hint.Text="Ambil ulang, atau pulihkan (-20; tanpa rekor)."
	else card.Hint.Text="Buka tab Cerita di depot untuk kiriman pameran." end
	actions.Secondary.Visible=(state.status~="Idle" or relay~=nil) and synced and state.profileReady and not shopOpen
	if not synced or not state.profileReady or shopOpen then button(actions.Primary,"",shopOpen and "Toko dibuka" or "Memuat profil...",false)
	elseif state.status=="Idle" then
  if relay and not near(state.depotPosition) then button(actions.Primary,'AcceptRelay',near(relay.pickupPosition)and 'Ambil titipan' or 'Ke titipan',near(relay.pickupPosition),'E')
  else
   local depotLabel = firstDelivery and nextChapter and "Kiriman pertama" or "Pilih pesanan"
   button(actions.Primary,"Start",nearDepot and depotLabel or "Ke depot",nearDepot,"E")
  end
  if relay then button(actions.Secondary,'SkipRelay','Lewati titipan',aliveRoot()~=nil,'Q') end
	elseif state.status=="Carrying" then
		button(actions.Primary,"Deliver",near(state.destinationPosition) and "Antar paket" or "Ke tujuan",near(state.destinationPosition),"E")
		button(actions.Secondary,"Drop",C.Labels.Drop,aliveRoot()~=nil,"Q")
	elseif state.status=="Dropped" then
		local p=ownPackage()
		local canPickup=p~=nil and not state.outOfBounds and near(p.Position)
		button(actions.Primary,"Pickup",canPickup and C.Labels.Pickup or "Ke paket",canPickup,"E")
		local remaining=math.max(0,C.RecoveryCooldown-(workspace:GetServerTimeNow()-(state.lastRecoveryAt or -100)))
		button(actions.Secondary,"Recover",remaining>0 and string.format("Pulihkan (%d)",math.ceil(remaining)) or C.Labels.Recover,remaining<=0 and aliveRoot()~=nil,"R")
	end
	actions.Primary.Visible=not Theme.IsMobile(ui)or actions.Primary:GetAttribute("ActionEnabled")==true
 if Theme.IsMobile(ui)then actions.Secondary.Position=UDim2.fromOffset(0,actions.Primary.Visible and 52 or 0)end
 local dropped=state.status=="Dropped" and ownPackage() or nil
	local idleTarget=relay and not near(state.depotPosition) and relay.pickupPosition or state.depotPosition
 local routeFolder=workspace:FindFirstChild('PaketKilatLocalSafeRoute')
 local guidedStamp=state.status=='Carrying'and state.stampNavigation and routeFolder and routeFolder:GetAttribute('GuidedStampId26')
 if guidedStamp and state.routeBonus.visited[guidedStamp]then guidedStamp=nil end
 local stampPosition=guidedStamp and routeFolder:GetAttribute('GuidedStampPosition26')
	local markerTarget=state.status=="Idle" and idleTarget
		or (state.status=="Dropped"and not state.outOfBounds and(dropped and dropped.Position or state.packagePosition))
  or (state.status=="Carrying"and(stampPosition or state.destinationPosition))
	label.Enabled=synced and state.profileReady==true and markerTarget~=nil
		and not shopOpen and not state.outOfBounds
		and not ui:GetAttribute("JobBoardOpen17") and not ui:GetAttribute("AudioOpen33")
		and (state.status~="Idle" or not near(idleTarget))
	if label.Enabled then
		marker.CFrame=CFrame.new(markerTarget)
		local root=aliveRoot()
		local distance=root and math.floor((root.Position-markerTarget).Magnitude+.5) or 0
		local title=stampPosition and "POS CAP"or state.status=="Idle" and (relay and not near(state.depotPosition)and 'TITIPAN' or "DEPOT") or state.status=="Dropped" and "PAKETMU" or state.destinationName
		markerText.Text=string.format("%s\n%d stud · %s",title,distance,state.status=="Dropped" and "Ambil ulang" or state.status=="Idle" and "Ambil pesanan" or stampPosition and "Lewati untuk cap"or "Antar ke sini")
	end
 local r=aliveRoot()local hazardKind,nearest
 if r and state.status=='Carrying'and not(state.movement and state.movement.resting)then
  local hum=r.Parent:FindFirstChildOfClass('Humanoid')
  local leg=hum.RigType==Enum.HumanoidRigType.R6 and r.Parent:FindFirstChild('Left Leg')
  local feet=r.Position-Vector3.new(0,hum.HipHeight+r.Size.Y/2+(leg and leg.Size.Y or 0),0)
  for _,spec in ipairs({{'Puddle','puddle'},{'MovingBarrier','barrier'}})do
   local part=hazards:FindFirstChild(spec[1])
   if part then
    local d=Coach.HazardDistance(feet,r.AssemblyLinearVelocity,part.CFrame,part.Size,C.ActionDistance*2)
    if d and(not nearest or d<nearest)then nearest,hazardKind=d,spec[2]end
   end
  end
 end
 local coach=Coach.Get(state,{alive=r~=nil,canPickup=dropped and not state.outOfBounds and near(dropped.Position),nearDestination=near(state.destinationPosition),guidedStamp=guidedStamp,routeEnabled=ui:FindFirstChild('RouteToggle')and ui.RouteToggle:GetAttribute('RouteEnabled'),contractStatus=contractStatus,hazard=hazardKind})
 ui:SetAttribute('JourneyHintKind29',coach and coach.kind)
 if hintOrder~=state.orderId then hintOrder=state.orderId seenHints={}end
 local celebration=ui:FindFirstChild('DeliveryCelebration')
 local notice=ui:FindFirstChild('PackageNotice')
 local blocked=shopOpen or ui:GetAttribute('JobBoardOpen17')or(celebration and celebration.Visible)
 if coach and not perfShowing and not blocked then
  guide.Hint.Text=coach.text
  if coach.alert and not Theme.IsMobile(ui)and not guideDismissed then guide.Visible=true end
  if Theme.IsMobile(ui)and coach.announce and not seenHints[coach.kind]and not guide.Visible
   and not ui:GetAttribute('MobileMenuOpen18')and not ui:GetAttribute('MobileTargetOpen18')
   and not(notice and notice.Visible)and os.clock()>=(ui:GetAttribute('MobileNoticeUntil18')or 0)then
   ui:SetAttribute('MobileNoticeText18',coach.text)ui:SetAttribute('MobileNoticeUntil18',os.clock()+3)seenHints[coach.kind]=true
  end
 end
end
local function activate(b)
	if not shopOpen and not ui:GetAttribute("AudioOpen33") and state.profileReady and b:GetAttribute("ActionEnabled") then
		local action=b:GetAttribute("Action")
  if action=="Start"then ui:SetAttribute("JobBoardOpen17",not ui:GetAttribute("JobBoardOpen17"))return end
  if action=='AcceptRelay'or action=='SkipRelay'then local offer=currentRelay()if offer then RS.Remotes.ActionRequest:FireServer(action,offer.id)end return end
		RS.Remotes.ActionRequest:FireServer(action,state.orderId,action=="Deliver" and state.destinationId or nil)
	end
end
ui.HelpToggle.Activated:Connect(function()
 ui:SetAttribute("MobileMenuOpen18",false)ui:SetAttribute("MobileTargetOpen18",false)
 guideManual=true guideDismissed=false
 render()
end)
guide.Close.Activated:Connect(function()
 guideDismissed=true guideManual=false ui:SetAttribute("PerfShowing",false) render()
end)
ui.ShopToggle.Activated:Connect(function()ui:SetAttribute("MobileMenuOpen18",false)shopOpen=not shopOpen render() end)
shop.Close.Activated:Connect(function() shopOpen=false render() end)
CAS:BindAction("PKShop",function(_,input)
 if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
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
 if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
	if s == Enum.UserInputState.Begin then activate(actions.Primary) end
	return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.E)
CAS:BindAction("PKDrop",function(_,s)
 if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
	if s == Enum.UserInputState.Begin and (state.status == "Carrying" or currentRelay()) then activate(actions.Secondary) end
	return Enum.ContextActionResult.Sink
end,false,Enum.KeyCode.Q)
CAS:BindAction("PKRecover",function(_,s)
 if UIS:GetFocusedTextBox()then return Enum.ContextActionResult.Pass end
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
	elseif code=="Impact" or code=="Slip" or code=="Barrier" or code=="GripLost" then cue("Impact")
	elseif code=="Delivered" then cue("Delivered") end
	local mobileErrors={TooFar=true,WrongDestination=true,NotOwnerOrStale=true,OrderActive=true,InvalidState=true,NotAlive=true,ProfileUnavailable=true,InsufficientCoins=true,NotOwned=true,OfferExpired=true,InvalidArguments=true,UpgradeChanged=true,UpgradeMaxed=true,RelayExpired=true}
 if mobileErrors[code]then ui:SetAttribute("MobileNoticeText18",messages[code]or "Aksi belum tersedia.")ui:SetAttribute("MobileNoticeUntil18",os.clock()+3)end
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
