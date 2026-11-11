-- Preview/select locally; the server still validates the current opaque offer id.
local player=game.Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild('PaketKilat')local theme=require(shared.Shared.UITheme12)
local config=require(shared.Shared.Config)local routes=require(shared.Shared.SafeRoutes08)
local preview=require(shared.Shared:WaitForChild('JobPreview28'))
local root=player:WaitForChild('PlayerGui'):WaitForChild('PaketKilatUI'):WaitForChild('Root')
local state,pendingUntil,noticeUntil,notice={},0,0,''
local connections={}local function bind(signal,fn)local c=signal:Connect(fn)table.insert(connections,c)end
local function rounded(v,r)local c=Instance.new('UICorner')c.CornerRadius=UDim.new(0,r)c.Parent=v end
local backdrop=Instance.new('Frame')backdrop.Name='JobBoardBackdrop17'backdrop.BackgroundColor3=theme.Ink backdrop.BackgroundTransparency=.35 backdrop.BorderSizePixel=0 backdrop.Active=true backdrop.ZIndex=8 backdrop.Visible=false backdrop.Parent=root
local board=Instance.new('Frame')board.Name='JobBoard17'board.AnchorPoint=Vector2.new(.5,.5)board.Position=UDim2.fromScale(.5,.5)board.BackgroundColor3=theme.Cream board.BorderSizePixel=0 board.ZIndex=10 board.Visible=false board.Parent=root rounded(board,16)
local function text(parent,name,x,y,w,h,size)
 local l=Instance.new('TextLabel')l.Name=name l.Position=UDim2.fromOffset(x,y)l.Size=UDim2.fromOffset(w,h)l.BackgroundTransparency=1 l.TextColor3=theme.Ink l.Font=Enum.Font.GothamBold l.TextSize=size l.TextWrapped=true l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=12 l.Parent=parent return l
end
local title=text(board,'Title',16,12,160,24,18)title.Text='Pesanan'
local info=text(board,'Info',16,54,500,18,11)info.Font=Enum.Font.GothamMedium
local close=Instance.new('TextButton')close.Name='Close'close.Size=UDim2.fromOffset(44,44)close.Position=UDim2.new(1,-52,0,8)close.Text='×'close.ZIndex=12 close.Parent=board theme.ToolbarButton(close)close.TextSize=21
local offers = Instance.new("ScrollingFrame")
offers.Name = "Offers"
offers.BackgroundTransparency = 1
offers.BorderSizePixel = 0
offers.ScrollBarThickness = 4
offers.ScrollBarImageColor3 = theme.Muted
offers.ScrollingDirection = Enum.ScrollingDirection.Y
offers.ZIndex = 11
offers.Parent = board
local narrow = false
local expandedMap = false
local CAREER_TAB, STORY_TAB = 3, 4
local tab=0 local selectedIds={}local tabs={}local render
for i,label in {'Biasa','Kontrak','Borongan','Karier','Cerita'}do
 local b=Instance.new('TextButton')b.Name='Tab24_'..i;b.Text=label;b.ZIndex=12;b.TextSize=11;b.Parent=board;theme.ToolbarButton(b)
 bind(b.Activated,function()tab=i-1 expandedMap=false offers.CanvasPosition=Vector2.zero render()end)tabs[i]=b
end
local career = Instance.new("ScrollingFrame")
career.Name = "Career"
career.Position = UDim2.fromOffset(16, 78)
career.BackgroundTransparency = 1
career.BorderSizePixel = 0
career.ScrollBarThickness = 5
career.ScrollBarImageColor3 = theme.Muted
career.ScrollingDirection = Enum.ScrollingDirection.Y
career.AutomaticCanvasSize = Enum.AutomaticSize.Y
career.CanvasSize = UDim2.fromOffset(0, 0)
career.ZIndex = 11
career.Visible = false
career.Parent = board
local rank = text(career, "Rank", 0, 0, 0, 22, 16)
local rankGoal = text(career, "RankGoal", 0, 22, 0, 18, 11)
rankGoal.TextColor3 = theme.Muted
local week = text(career, "Week", 0, 48, 0, 21, 14)
local goalButtons = {}
local access = text(career, "ExpressAccess", 0, 230, 0, 22, 11)
access.TextColor3 = theme.Muted
local historyTitle = text(career, "HistoryTitle", 0, 260, 0, 20, 13)
historyTitle.Text = "Riwayat sesi"
local history = text(career, "History24", 0, 282, 0, 0, 11)
history.Font = Enum.Font.GothamMedium
history.TextYAlignment = Enum.TextYAlignment.Top
history.AutomaticSize = Enum.AutomaticSize.Y
local storyComplete = text(offers, "StoryComplete", 0, 4, 0, 74, 14)
storyComplete.Text = "Pameran Foto Kampung terbuka\nPilih Baca panel di depan Galeri Tepi Air, Bata Quay."
local weeklyButton = Instance.new("TextButton")
weeklyButton.Name = "OpenWeeklyGoals"
weeklyButton.Text = "Lihat target mingguan"
weeklyButton.ZIndex = 12
weeklyButton.Parent = offers
theme.ToolbarButton(weeklyButton)
bind(weeklyButton.Activated, function()
 tab = CAREER_TAB
 career.CanvasPosition = Vector2.zero
 render()
end)
storyComplete.TextYAlignment = Enum.TextYAlignment.Top
storyComplete.Visible = false

local function offerAt(i, category)
 category = category or tab
 if category == STORY_TAB then return i == 1 and state.story and state.story.offer or nil end
 if i == 4 then return category == 0 and state.jobOffers and state.jobOffers[7] or nil end
 return category==2 and state.batchOffers and state.batchOffers[i]or category<2 and state.jobOffers and state.jobOffers[category*3+i]or nil
end

local function offerForGoal(goal)
 for category = 0, 2 do
  for i = 1, category == 0 and 4 or 3 do
   local offer = offerAt(i, category)
   if preview.MatchesGoal(goal, offer) then return offer, category end
  end
 end
end

local function rowCount()
 if tab == STORY_TAB then return 1 end
 if tab == 0 and offerAt(4) then return 4 end
 return 3
end
local function selected()
 if tab == STORY_TAB then return offerAt(1) end
 if tab == CAREER_TAB then return nil end
 local first
 local firstShift = tab == 0 and state.deliveryCount == 0
 for i=1,rowCount() do local offer=offerAt(i)
  if offer then
   if not first or not firstShift and not preview.Recommendation(state.career, first) and preview.Recommendation(state.career, offer) then first = offer end
   if selectedIds[tab] == offer.id then return offer end
  end
 end
 selectedIds[tab]=first and first.id return first
end
local function scrollToPreview()
 if not narrow then return end
 local maxScroll = math.max(0, offers.CanvasSize.Y.Offset - offers.AbsoluteWindowSize.Y)
 offers.CanvasPosition = Vector2.new(0, math.min(rowCount() * 64, maxScroll))
end

for i = 1, 3 do
 local button = Instance.new("TextButton")
 button.Name = "WeeklyGoal" .. i
 button.Position = UDim2.fromOffset(0, 72 + (i - 1) * 50)
 button.TextWrapped = true
 button.ZIndex = 12
 button.Parent = career
 theme.ToolbarButton(button)
 goalButtons[i] = button
 bind(button.Activated, function()
  if not career.Visible then return end
  local progress = state.career
  local offer, category = offerForGoal(progress and progress.goals[i])
  if not offer then return end
  tab, expandedMap = category, false
  selectedIds[category] = offer.id
  offers.CanvasPosition = Vector2.zero
  render()
  scrollToPreview()
 end)
end

local rows={}
for i=1,4 do
 local card=Instance.new('TextButton')card.Name='Offer'..i card.Text=''card.AutoButtonColor=false card.BorderSizePixel=0 card.ZIndex=11 card.Parent=offers rounded(card,10)
 local outline=Instance.new('UIStroke')outline.Thickness=2 outline.ApplyStrokeMode=Enum.ApplyStrokeMode.Border outline.Parent=card
 local name=text(card,'Name',10,5,180,19,13)
 local dest=text(card,'Destination',10,27,180,19,11)dest.Font=Enum.Font.GothamMedium
 rows[i]={frame=card,name=name,dest=dest,outline=outline}
 bind(card.Activated, function()
  local offer = offerAt(i)
  if not offer or tab == 3 then return end
  selectedIds[tab] = offer.id
  render()
  scrollToPreview()
 end)
end
local panel=Instance.new('Frame')panel.Name='Preview28'panel.BackgroundColor3=theme.Soft panel.BorderSizePixel=0 panel.ZIndex=11 panel.Parent=offers rounded(panel,12)
local destination=text(panel,'Destination',12,7,330,22,15)
local meta=text(panel,'RouteInfo',12,31,330,18,11)meta.TextColor3=theme.Muted meta.Font=Enum.Font.GothamMedium
local conditions=text(panel,'Conditions',12,54,190,52,11)conditions.Font=Enum.Font.GothamMedium conditions.TextYAlignment=Enum.TextYAlignment.Top
local reward=text(panel,'Reward',12,106,330,24,10)
local diagram=Instance.new('Frame')diagram.Name='RouteMap28'diagram.BackgroundColor3=theme.Cream diagram.BorderSizePixel=0 diagram.ClipsDescendants=true diagram.ZIndex=12 diagram.Parent=panel rounded(diagram,8)
local accept=Instance.new('TextButton')accept.Name='Accept28'accept.Text='Ambil pesanan'accept.ZIndex=12 accept.TextSize=12 accept.Parent=panel
local mapToggle = Instance.new("TextButton")
mapToggle.Name = "ExpandRoute"
mapToggle.Text = "Lihat peta"
mapToggle.ZIndex = 13
mapToggle.Parent = panel
theme.ToolbarButton(mapToggle)

local mapView = Instance.new("Frame")
mapView.Name = "ExpandedRoute"
mapView.BackgroundTransparency = 1
mapView.ZIndex = 11
mapView.Visible = false
mapView.Parent = board
local mapCaption = text(mapView, "Caption", 0, 0, 0, 22, 12)
mapCaption.TextTruncate = Enum.TextTruncate.AtEnd
local mapBack = Instance.new("TextButton")
mapBack.Name = "BackToOffers"
mapBack.Text = "Kembali ke pesanan"
mapBack.ZIndex = 13
mapBack.Parent = mapView
theme.ToolbarButton(mapBack)
bind(mapToggle.Activated, function() expandedMap = true render() end)
bind(mapBack.Activated, function() expandedMap = false render() end)

local drawKey
local function draw(offer,w,h)
 local key=(offer and offer.id or '')..':'..w..':'..h..':'..tostring(expandedMap)
 if key==drawKey then return end drawKey=key
 for _,v in diagram:GetChildren()do if v:IsA('GuiObject')then v:Destroy()end end
 local route=offer and preview.OfferRoute(routes,offer)
 if not route then return end
 local project=preview.Projector(expandedMap and routes or {route.points},w,h,expandedMap and 18 or 10)
 local function line(a,b,color,thickness,z)
  a,b=project(a),project(b)local d=b-a
  local f=Instance.new('Frame')f.AnchorPoint=Vector2.new(.5,.5)f.Position=UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2)
  f.Size=UDim2.fromOffset(d.Magnitude,thickness)f.Rotation=math.deg(math.atan2(d.Y,d.X))f.BackgroundColor3=color f.BorderSizePixel=0 f.ZIndex=z f.Parent=diagram
 end
 if expandedMap then
  for _,path in pairs(routes) do
   for i=1,#path-1 do line(path[i],path[i+1],theme.Line,2,12) end
  end
 end
 for i=1,#route.points-1 do line(route.points[i],route.points[i+1],theme.Ink,3,13)end
 local markers={{point=route.points[1],text='D'}}
 if offer.isBatch then for i,id in ipairs(offer.batchDestinations)do local path=routes[id]table.insert(markers,{point=path[#path],text=tostring(i)})end
 else table.insert(markers,{point=route.points[#route.points],text='T'})end
 for i,mark in ipairs(markers)do
  local point=mark.point
  local p=project(point)local dot=Instance.new('TextLabel')dot.Name=i==1 and 'Depot28'or 'Target28'
  dot.AnchorPoint=Vector2.new(.5,.5)dot.Position=UDim2.fromOffset(p.X,p.Y)dot.Size=UDim2.fromOffset(14,14)dot.Text=mark.text
  dot.BackgroundColor3=i==1 and theme.Ink or theme.Gold dot.TextColor3=i==1 and theme.Cream or theme.Ink dot.Font=Enum.Font.GothamBold dot.TextSize=9 dot.BorderSizePixel=0 dot.ZIndex=14 dot.Parent=diagram rounded(dot,7)
 end
end
bind(accept.Activated,function()
 local offer=selected()
 if offer and accept.Active and os.clock()>=pendingUntil then pendingUntil=os.clock()+1 shared.Remotes.ActionRequest:FireServer(offer.isBatch and 'AcceptBatch'or 'AcceptJob',offer.id)render()end
end)
bind(close.Activated,function()root:SetAttribute('JobBoardOpen17',false)end)
render=function()
 local open=root:GetAttribute('JobBoardOpen17')==true
 if root.Shop.Visible or state.status~='Idle'or not state.profileReady then open=false root:SetAttribute('JobBoardOpen17',false)end
 board.Visible=open backdrop.Visible=open
 local camera=workspace.CurrentCamera if camera then backdrop.Position=UDim2.fromOffset(-root.AbsolutePosition.X,-root.AbsolutePosition.Y)backdrop.Size=UDim2.fromOffset(camera.ViewportSize.X,camera.ViewportSize.Y)end
 if not open then return end
 local width = math.max(1, math.min(620, root.AbsoluteSize.X - 24))
 narrow = width < 545
 local contentY = narrow and 124 or 76
 local height = math.max(1, math.min(narrow and 524 or 280, root.AbsoluteSize.Y - 16))
 local contentHeight = math.max(1, height - contentY - 10)
 local bodyWidth = width - 24
 local left = narrow and bodyWidth - 8 or math.clamp(math.floor(width * .32), 146, 198)
 local right = narrow and left or bodyWidth - left - 16
 board.Size = UDim2.fromOffset(width, height)
 local tabWidth = narrow and (width - 56) / #tabs or 68
 local tabsWidth = #tabs * tabWidth + (#tabs - 1) * 8
 local tabStart = narrow and 12 or width - 60 - tabsWidth
 title.Size = UDim2.fromOffset(narrow and width - 76 or tabStart - 24, 24)
 info.Position = UDim2.fromOffset(16, narrow and 94 or 52)
 info.Size = UDim2.fromOffset(width - 32, narrow and 28 or 22)
 for i, button in ipairs(tabs) do
  local x = tabStart + (i - 1) * (tabWidth + 8)
  button.Position = UDim2.fromOffset(x, narrow and 48 or 6)
  button.Size = UDim2.fromOffset(tabWidth, 44)
  theme.Action(button, true, tab ~= i - 1)
 end
 offers.Position = UDim2.fromOffset(12, contentY)
 offers.Size = UDim2.fromOffset(bodyWidth, contentHeight)
 local storyTab = tab == STORY_TAB
 local rowHeight = rowCount() * 64
 local offerPanelY = narrow and rowHeight or 0
 local finished = storyTab and state.story and state.story.completed == state.story.total
 offers.CanvasSize = UDim2.fromOffset(0, finished and 126 or math.max(rowHeight, offerPanelY + 184))
 weeklyButton.Visible = finished == true
 weeklyButton.Position = UDim2.fromOffset(0, 76)
 weeklyButton.Size = UDim2.fromOffset(math.min(bodyWidth - 8, 220), 44)
 offers.Visible = tab ~= CAREER_TAB
 storyComplete.Visible = finished == true
 storyComplete.Size = UDim2.fromOffset(bodyWidth - 8, 74)
 panel.Visible = not finished
 career.Position = UDim2.fromOffset(16, contentY)
 career.Size = UDim2.fromOffset(width - 32, contentHeight)
 career.Visible = tab == 3
 for _, label in ipairs({rank, rankGoal, week, access, historyTitle, history}) do
  label.Size = UDim2.fromOffset(width - 46, label.Size.Y.Offset)
 end
 if career.Visible and state.career then
  local progress = state.career
  rank.Text = string.format("%s · %d kiriman", progress.rank, state.deliveryCount)
  rankGoal.Text = progress.nextRank and string.format("%d kiriman lagi ke %s · +%d koin", progress.nextRemaining, progress.nextRank, progress.nextRankBonus)
   or "Pangkat tertinggi tercapai."
  week.Text = string.format("%s · %d/3 · %s%d koin", progress.weeklyName, progress.completed,
   progress.completed == 3 and "diterima +" or "+", progress.weeklyBonus)
  for i, button in ipairs(goalButtons) do
   local goal = progress.goals[i]
   local offer = offerForGoal(goal)
   button.Visible = goal ~= nil
   button.Size = UDim2.fromOffset(width - 46, 44)
   button.Text = goal and ((goal.done and "✓ " or "○ ") .. goal.label .. (offer and "  →" or "")) or ""
   button.Active = offer ~= nil
   button.AutoButtonColor = button.Active
   theme.Action(button, button.Active, true)
  end
  access.Text = progress.expressUnlocked and "Ekspres Distrik tersedia di tab Kontrak"
   or string.format("Ekspres Distrik terbuka setelah %d kiriman lagi", progress.expressRemaining)
 end
 local lines={}
 for i,v in state.recentDeliveries or {}do table.insert(lines,string.format('%d. %s · %d★ · +%d koin\n%s · %d/100 · %.1fs · %s',i,v.destinationName,v.stars,v.total,v.jobName or 'Pesanan',v.condition or 0,v.duration or 0,v.contractReason or 'Tanpa kontrak'))end
 history.Text=#lines>0 and table.concat(lines,'\n')or 'Belum ada pengantaran. Ambil pesanan pertamamu.'
 local char=player.Character local hum=char and char:FindFirstChildOfClass('Humanoid')local r=char and char:FindFirstChild('HumanoidRootPart')
 local near=r and state.depotPosition and(r.Position-state.depotPosition).Magnitude<=config.ActionDistance
 info.Text=os.clock()<noticeUntil and notice or near and 'Pilih pekerjaan untuk melihat jalur dan syaratnya.'or 'Dekati depot untuk mengambil pesanan.'
 if tab == 3 and state.career then
  local hours = math.max(1, math.ceil((state.career.resetAt - workspace:GetServerTimeNow()) / 3600))
  info.Text = string.format("Mingguan · kondisi ≥90 · tanpa Pulihkan · ganti dalam %d jam", hours)
 end
 local offer=selected()board:SetAttribute('SelectedOffer28',offer and offer.id)
 for i,row in ipairs(rows)do
  local o=offerAt(i)local chosen=o and offer and o.id==offer.id
  row.frame.Visible = tab ~= CAREER_TAB and i <= rowCount() and (not storyTab or o ~= nil)
  row.frame.Active = open and o ~= nil
  row.frame.Position=UDim2.fromOffset(0,(i-1)*64)row.frame.Size=UDim2.fromOffset(left,56)
  row.name.Size=UDim2.fromOffset(left-20,19)row.dest.Size=UDim2.fromOffset(left-20,19)
  row.frame.BackgroundColor3=chosen and theme.Gold or theme.Soft row.outline.Color=chosen and theme.Ink or theme.Line
  row.name.Text=o and ((preview.Recommendation(state.career,o) and '★ ' or '')..o.name) or 'Memuat...'row.name.TextTruncate=Enum.TextTruncate.AtEnd row.dest.Text=""
  if o then
   local rowRoute=preview.OfferRoute(routes,o)
   local length=rowRoute and string.format(" · %d stud",math.round(rowRoute.distance)) or ""
   row.dest.Text=(o.isBatch and "3 kiriman" or o.destinationName)..length
  end
  row.dest.TextTruncate=Enum.TextTruncate.AtEnd
  row.dest.TextWrapped=false
 end
 panel.Position=UDim2.fromOffset(narrow and 0 or left+8,offerPanelY)panel.Size=UDim2.fromOffset(right,184)
 destination.Size=UDim2.fromOffset(right-24,22)meta.Size=UDim2.fromOffset(right-24,18)
 local mapWidth=math.min(124,math.floor(right*.36))
 conditions.Size=UDim2.fromOffset(right-mapWidth-34,52)
 diagram.Position=UDim2.fromOffset(right-mapWidth-12,54)diagram.Size=UDim2.fromOffset(mapWidth,72)
 reward.Size=UDim2.fromOffset(right-mapWidth-30,24)
 accept.Position=UDim2.fromOffset(12,132)accept.Size=UDim2.fromOffset(right-24,44)
 local route=offer and preview.OfferRoute(routes,offer)
 destination.Text=offer and(offer.isBatch and offer.name or offer.destinationName)or 'Pilih pekerjaan'
 local distance=route and(string.format('%d stud',math.floor(route.distance+.5)))or 'Jalur belum tersedia'
 meta.Text=offer and(offer.packageType..' · '..distance..(preview.Recommendation(state.career,offer) and ' · mingguan' or ''))or ''
 if storyTab and offer then
  meta.Text = offer.cargo .. " · " .. offer.packageType .. " · " .. distance
 end
 conditions.Text=offer and preview.Conditions(offer)or ''
 if offer and offer.careBonus then
  conditions.Text = string.format("Bonus +%d · kondisi akhir ≥%d · tanpa Pulihkan", offer.careBonus, offer.careCondition)
 end
 if offer and offer.isBatch then local stops={}for i,id in ipairs(offer.batchDestinations)do stops[i]=i..'. '..config.Routes[id].Name..(offer.packageTypes[i]=='Rapuh'and ' · rapuh'or '')end conditions.Text=table.concat(stops,'\n')end
 if not offer then
  reward.Text = ""
 elseif offer.storyChapter then
  reward.Text = string.format("Dasar + cerita: %d koin", config.BaseReward + offer.storyBonus)
 elseif offer.isBatch then
  reward.Text = string.format("%d koin per kiriman\nBonus akhir maks. +%d", config.BaseReward, offer.jobBonus)
 elseif not offer.contract and offer.jobBonus == 0 then
  reward.Text = string.format("Dasar: %d koin", config.BaseReward)
 else
  reward.Text = string.format("Dasar: %d koin\n%s +%d", config.BaseReward, offer.contract and "Bonus jika lolos" or "Bonus maks.", offer.jobBonus)
 end
 if near and os.clock()>=noticeUntil then
  if tab==2 then info.Text='*Finish mengikuti kondisi terendah; memakai Pulihkan menggugurkan bonus.'
  elseif tab==1 then info.Text='*Bonus bersyarat. Jarak belum termasuk perjalanan ke pos cap.'
  elseif tab==0 then info.Text='*Bonus kerja mengikuti kondisi. Bonus lain dihitung saat tiba.'end
 end
 local recommendation = tab ~= 3 and preview.Recommendation(state.career, offer)
 if os.clock() >= noticeUntil then
  if storyTab and state.story then
   if finished then
    info.Text = string.format("%d/%d kiriman pameran selesai", state.story.completed, state.story.total)
   elseif offer then
    local actionHint = near and "Pameran Foto Kampung" or "Kembali ke depot untuk mengambil paket"
    info.Text = string.format("Bab %d/%d · %s", offer.storyChapter, state.story.total, actionHint)
   end
  elseif near and recommendation then
   info.Text = "★ " .. recommendation .. " · kondisi ≥90 · tanpa Pulihkan"
  end
 end
 local showMap = expandedMap and tab ~= 3 and route ~= nil
 title.Text = showMap and "Peta rute" or "Pesanan"
 info.Visible = not showMap
 for _, button in ipairs(tabs) do button.Visible = not showMap end
 offers.Visible = tab ~= 3 and not showMap
 mapView.Visible = showMap
 mapToggle.Visible = route ~= nil
 local mapButtonWidth = 90
 if route then
  mapToggle.Position = UDim2.fromOffset(right - mapButtonWidth - 12, 132)
  mapToggle.Size = UDim2.fromOffset(mapButtonWidth, 44)
  accept.Size = UDim2.fromOffset(right - mapButtonWidth - 32, 44)
 end
 if showMap then
  local mapHeight=math.max(1,height-60)
  mapView.Position = UDim2.fromOffset(12, 50)
  mapView.Size = UDim2.fromOffset(bodyWidth, mapHeight)
  mapCaption.Size = UDim2.fromOffset(bodyWidth, 22)
  mapCaption.Text = offer.isBatch and ("D Depot → 1 → 2 → 3 · " .. distance)
   or ("D Depot → T " .. destination.Text .. " · " .. distance)
  mapBack.Position = UDim2.new(0, 0, 1, -44)
  mapBack.Size = UDim2.fromOffset(bodyWidth, 44)
  diagram.Parent = mapView
  diagram.Position = UDim2.fromOffset(0, 25)
  diagram.Size = UDim2.fromOffset(bodyWidth, math.max(1, mapHeight - 75))
 else
  diagram.Parent = panel
 end
 local active=open and not showMap and tab~=3 and near and hum and hum.Health>0 and offer~=nil and os.clock()>=pendingUntil
 accept.Active = active == true
 accept.AutoButtonColor = accept.Active
 if os.clock() < pendingUntil then
  accept.Text = "Menyiapkan..."
 elseif offer and offer.storyChapter then
  accept.Text = "Ambil paket cerita"
 elseif offer and offer.isBatch then
  accept.Text = "Ambil 3 kiriman"
 else
  accept.Text = "Ambil pesanan"
 end
 theme.Action(accept,active==true,false)
 if tab ~= 3 then draw(offer, diagram.Size.X.Offset, diagram.Size.Y.Offset) end
end
bind(shared.Remotes.StateChanged.OnClientEvent,function(s,code)
 state=s
 if code=='OfferExpired'then notice='Daftar diperbarui. Pilih pesanan lagi.'noticeUntil=os.clock()+3
 elseif code=='TooFar'then notice='Dekati depot untuk mengambil pesanan.'noticeUntil=os.clock()+3 end
 render()
end)
local openedOnce = false
local returnTab
bind(root:GetAttributeChangedSignal("JobBoardOpen17"), function()
 if root:GetAttribute("JobBoardOpen17") then
  if root:GetAttribute("OpenStoryFromResult") then
   root:SetAttribute("OpenStoryFromResult", nil)
   tab, returnTab = STORY_TAB, STORY_TAB
  elseif root:GetAttribute("OpenCareerFromResult") then
   root:SetAttribute("OpenCareerFromResult", nil)
   career.CanvasPosition = Vector2.zero
   tab, returnTab = CAREER_TAB, 0
  elseif not openedOnce and state.story and state.story.offer then
   tab = STORY_TAB
  end
  openedOnce = true
 else
  offers.CanvasPosition = Vector2.zero
  expandedMap = false
  if returnTab then tab, returnTab = returnTab, nil end
 end
 render()
end)
local elapsed=0 bind(game:GetService('RunService').Heartbeat,function(dt)elapsed+=dt if elapsed>=.1 then elapsed=0 render()end end)
bind(script.Destroying,function()for _,c in ipairs(connections)do c:Disconnect()end board:Destroy()backdrop:Destroy()end)
render()
