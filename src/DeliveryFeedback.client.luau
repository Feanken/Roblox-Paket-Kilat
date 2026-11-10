-- Presentation only. All rewards/statuses originate from existing server snapshots.
local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local player=Players.LocalPlayer
local remote=game.ReplicatedStorage:WaitForChild("PaketKilat").Remotes
local ui=player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI").Root
local Theme=require(game.ReplicatedStorage.PaketKilat.Shared.UITheme12)
local Config=require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local state,shownOrder={},nil
local connections={}
local function connect(signal,fn) local c=signal:Connect(fn) table.insert(connections,c) return c end
local function text(parent,name,size,pos,value,fontSize)
 local t=Instance.new("TextLabel") t.Name=name t.Size=size t.Position=pos t.BackgroundTransparency=1
 t.Text=value t.TextColor3=Color3.fromRGB(247,239,217) t.Font=Enum.Font.GothamBold t.TextSize=fontSize t.Parent=parent return t
end
local toast=Instance.new("Frame") toast.Name="DeliveryCelebration" toast.AnchorPoint=Vector2.new(.5,.5)
toast.Position=UDim2.fromScale(.5,.48) toast.Size=UDim2.fromOffset(330,212)
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
nextStep.Position=UDim2.fromOffset(12,174)nextStep.Size=UDim2.new(1,-24,0,26)
stars.TextColor3=Theme.Ink streak.TextColor3=Theme.Muted ratingHint.TextColor3=Theme.Muted
local close=Instance.new('TextButton')close.Name='Close22'close.Text='×'close.Size=UDim2.fromOffset(44,44)close.Position=UDim2.new(1,-48,0,4)close.ZIndex=22 close.Parent=toast Theme.ToolbarButton(close)close.TextSize=22
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
local expires,noticeExpires=0,0
local countFrom,countTotal=0,0
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
 toast.Size=UDim2.fromOffset(math.min(330,math.max(260,width-40)),212)
 if countTotal>0 then reward.Text=string.format('+%d KOIN',math.floor(countTotal*math.clamp((os.clock()-countFrom)/.65,0,1)))end
 -- Keep transient notices below the upper HUD on short landscape screens.
 impact.Position=UDim2.new(.5,0,0,math.min(216,height*.59))
 impact.Size=UDim2.fromOffset(math.min(310,width-32),36)
 local boardOpen=ui:GetAttribute('JobBoardOpen17')==true
 local shopOpen=ui.Shop.Visible or boardOpen
 toast.Visible=os.clock()<expires and not shopOpen
 ui.TopCard.Visible=not toast.Visible and not shopOpen
 ui.StorageStatus.Visible=not toast.Visible and not shopOpen and(not Theme.IsMobile(ui)or ui.StorageStatus:GetAttribute("Alert18")==true)
 ui.Actions.Visible=not shopOpen and not toast.Visible and(not Theme.IsMobile(ui)or not ui:GetAttribute("MobileTargetOpen18"))
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
   shownOrder=key expires=os.clock()+5 noticeExpires=0
   title.Text=result.newRecord and "REKOR BARU!" or "PAKET SAMPAI!"
   countFrom=os.clock()countTotal=result.total reward.Text='+0 KOIN'
   local rating=result.rating
   stars.Text=rating and (string.rep('★',rating.stars)..string.rep('☆',3-rating.stars)..' · '..rating.name)or 'PAKET TERKIRIM'
   ratingHint.Text=rating and rating.stars==3 and 'Paket utuh dan tiba tepat waktu.'or rating and rating.stars==2 and(not rating.onTime and 'Paket aman. Coba tiba lebih cepat.'or 'Paket aman. Jaga kondisinya lebih tinggi.')or result.recoveryCount>0 and 'Coba antar tanpa memulihkan paket.'or 'Paket terkirim. Kurangi benturan.'
   if result.contractKind then ratingHint.Text=result.contractSucceeded and ('Kontrak berhasil · bonus +'..result.contractBonus)or ('Kontrak: '..(result.contractStatus and result.contractStatus.reason or 'syarat belum terpenuhi'))end
   streak.Text=string.format('Rapi beruntun %d · terbaik sesi %d',result.cleanStreak or 0,result.bestCleanStreak or 0)
   detail.Text=string.format('Dasar %d · Kondisi %d · Waktu %d\nPos %d · Kerja %d · Target %d · Kontrak %d',result.baseReward,result.conditionBonus,result.timeBonus,result.routeBonus or 0,result.jobBonus or 0,result.challengeBonus or 0,result.contractBonus or 0)
   if (result.challengeBonus or 0)>0 then
    title.Text="TARGET TERCAPAI!"
   end
   detail.TextWrapped=true
   detail.TextSize=11
   nextStep.Text=snapshot.relayOffer and 'Ada titipan di sini · lanjut antar atau kembali ke depot' or "Kembali ke depot · pilih pesanan berikutnya"
   if tween then tween:Cancel() end
   scale.Scale=.88 tween=TweenService:Create(scale,TweenInfo.new(.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}) tween:Play()
  end
 elseif code=="Impact" or code=="Slip" or code=="Barrier" or code=="GripLost" then
  impact.Text=string.format("PAKET TERLEPAS  /  kondisi %d",snapshot.condition or 0)
  noticeExpires=os.clock()+2
 elseif code=="Recover" then
  impact.Text="Paket kembali ke petak pemulihan" noticeExpires=os.clock()+2
 elseif code=="Start" or code=="Respawned" or code=="Cancelled" then
  expires=0 noticeExpires=0
 end
 refresh()
end)
connect(close.Activated,function()toast:SetAttribute('DismissedOrder22',shownOrder)expires=0 refresh()end)
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

