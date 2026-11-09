-- Presentation and selection only. Server validates the current offer/depot/order state.
local player=game.Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild('PaketKilat')local theme=require(shared.Shared.UITheme12)
local config=require(shared.Shared.Config)
local root=player:WaitForChild('PlayerGui'):WaitForChild('PaketKilatUI'):WaitForChild('Root')
local state,pendingUntil,noticeUntil,notice={},0,0,''
local backdrop=Instance.new('Frame')backdrop.Name='JobBoardBackdrop17'backdrop.BackgroundColor3=theme.Ink backdrop.BackgroundTransparency=.35 backdrop.BorderSizePixel=0 backdrop.Active=true backdrop.ZIndex=8 backdrop.Visible=false backdrop.Parent=root
local board=Instance.new('Frame')board.Name='JobBoard17'board.AnchorPoint=Vector2.new(.5,.5)board.Position=UDim2.fromScale(.5,.5)board.BackgroundColor3=theme.Cream board.BorderSizePixel=0 board.ZIndex=10 board.Visible=false board.Parent=root
local corner=Instance.new('UICorner')corner.CornerRadius=UDim.new(0,16)corner.Parent=board
local function text(parent,name,x,y,w,h,size)
 local l=Instance.new('TextLabel')l.Name=name l.Position=UDim2.fromOffset(x,y)l.Size=UDim2.fromOffset(w,h)l.BackgroundTransparency=1 l.TextColor3=theme.Ink l.Font=Enum.Font.GothamBold l.TextSize=size l.TextWrapped=true l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=12 l.Parent=parent return l
end
local title=text(board,'Title',16,12,400,24,20)title.Text='Pilih pesanan'
local info=text(board,'Info',16,42,500,24,11)info.Font=Enum.Font.GothamMedium
local close=Instance.new('TextButton')close.Name='Close'close.Size=UDim2.fromOffset(44,44)close.Position=UDim2.new(1,-52,0,8)close.Text='×'close.ZIndex=12 close.Parent=board theme.ToolbarButton(close)close.TextSize=21
local rows={}
for i=1,3 do
 local card=Instance.new('Frame')card.Name='Offer'..i card.BackgroundColor3=theme.Soft card.BorderSizePixel=0 card.ZIndex=11 card.Parent=board
 local c=corner:Clone()c.CornerRadius=UDim.new(0,12)c.Parent=card
 local name=text(card,'Name',12,10,165,20,14)
 local dest=text(card,'Destination',12,38,165,38,14)
 local detail=text(card,'Detail',12,81,165,42,11)detail.Font=Enum.Font.GothamMedium detail.TextColor3=theme.Muted
 local button=Instance.new('TextButton')button.Name='Accept'button.Text='Ambil pesanan'button.Size=UDim2.new(1,-24,0,44)button.Position=UDim2.fromOffset(12,132)button.ZIndex=12 button.TextSize=12 button.Parent=card
 rows[i]={frame=card,name=name,dest=dest,detail=detail,button=button}
 button.Activated:Connect(function()
  local offer=state.jobOffers and state.jobOffers[i]
  if offer and button.Active and os.clock()>=pendingUntil then pendingUntil=os.clock()+1 shared.Remotes.ActionRequest:FireServer('AcceptJob',offer.id)end
 end)
end
close.Activated:Connect(function()root:SetAttribute('JobBoardOpen17',false)end)
local function render()
 local open=root:GetAttribute('JobBoardOpen17')==true
 if root.Shop.Visible or state.status~='Idle'or not state.profileReady then open=false root:SetAttribute('JobBoardOpen17',false)end
 board.Visible=open backdrop.Visible=open
 local camera=workspace.CurrentCamera if camera then backdrop.Position=UDim2.fromOffset(-root.AbsolutePosition.X,-root.AbsolutePosition.Y)backdrop.Size=UDim2.fromOffset(camera.ViewportSize.X,camera.ViewportSize.Y)end
 local width=math.min(620,root.AbsoluteSize.X-24)local column=(width-40)/3
 board.Size=UDim2.fromOffset(width,280)info.Size=UDim2.fromOffset(width-32,24)title.Size=UDim2.fromOffset(width-80,24)
 local char=player.Character local hum=char and char:FindFirstChildOfClass('Humanoid')local r=char and char:FindFirstChild('HumanoidRootPart')
 local near=r and state.depotPosition and(r.Position-state.depotPosition).Magnitude<=config.ActionDistance
 info.Text=os.clock()<noticeUntil and notice or near and 'Pilih tujuan. Bonus pekerjaan bergantung kondisi paket.'or 'Dekati depot untuk mengambil pesanan.'
 for i,row in ipairs(rows)do
  row.frame.Position=UDim2.fromOffset(12+(i-1)*(column+8),76)row.frame.Size=UDim2.fromOffset(column,188)
  for _,l in ipairs({row.name,row.dest,row.detail})do l.Size=UDim2.fromOffset(column-24,l.Size.Y.Offset)end
  local offer=state.jobOffers and state.jobOffers[i]
  row.name.Text=offer and offer.name or 'Memuat...'
  row.dest.Text=offer and offer.destinationName or ''
  row.detail.Text=offer and string.format('%s · bonus maks. +%d\n%s',offer.packageType,offer.jobBonus,offer.description)or ''
  local active=open and near and hum and hum.Health>0 and offer~=nil and os.clock()>=pendingUntil
  row.button.Active=active==true row.button.AutoButtonColor=active==true row.button.Text=os.clock()<pendingUntil and 'Menyiapkan...'or 'Ambil pesanan'
  theme.Action(row.button,active==true,false)
 end
end
shared.Remotes.StateChanged.OnClientEvent:Connect(function(s,code)
 state=s
 if code=='OfferExpired'then notice='Daftar diperbarui. Pilih pesanan lagi.'noticeUntil=os.clock()+3
 elseif code=='TooFar'then notice='Dekati depot untuk mengambil pesanan.'noticeUntil=os.clock()+3 end
 render()
end)
root:GetAttributeChangedSignal('JobBoardOpen17'):Connect(render)
local elapsed=0 game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed+=dt if elapsed>=.1 then elapsed=0 render()end end)
render()