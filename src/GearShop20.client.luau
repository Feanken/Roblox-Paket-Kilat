-- Tabs share the existing shop modal; no extra permanent HUD.
local player=game.Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild('PaketKilat')
local config=require(shared.Shared.Config)local theme=require(shared.Shared.UITheme12)
local root=player:WaitForChild('PlayerGui'):WaitForChild('PaketKilatUI'):WaitForChild('Root')local shop=root:WaitForChild('Shop')
local state={}local pending=0
root:SetAttribute('ShopTab20','bags')
local function button(parent,name,text)
 local b=Instance.new('TextButton')b.Name=name b.Text=text b.TextSize=12 b.ZIndex=12 b.Parent=parent theme.Action(b,true,false)return b
end
local bags=button(shop,'BagsTab20','Tas')local gear=button(shop,'GearTab20','Peralatan')
local panel=Instance.new('Frame')panel.Name='GearPanel20'panel.BackgroundColor3=theme.Soft panel.BorderSizePixel=0 panel.ZIndex=11 panel.Visible=false panel.Parent=shop
local corner=Instance.new('UICorner')corner.CornerRadius=UDim.new(0,12)corner.Parent=panel
local function label(name,y,height,size)
 local l=Instance.new('TextLabel')l.Name=name l.Position=UDim2.fromOffset(12,y)l.Size=UDim2.new(1,-24,0,height)l.BackgroundTransparency=1 l.Font=Enum.Font.GothamMedium l.TextSize=size l.TextColor3=theme.Ink l.TextWrapped=true l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=12 l.Parent=panel return l
end
local title=label('Title',10,24,18)title.Font=Enum.Font.GothamBold title.Text='Sarung tangan kurir'
local level=label('Level',39,22,14)
local detail=label('Detail',65,52,12)detail.TextColor3=theme.Muted
local price=label('Price',132,44,12)price.Size=UDim2.new(1,-170,0,44)
local buy=button(panel,'BuyGrip20','Memuat...')buy.Size=UDim2.fromOffset(140,44)buy.Position=UDim2.new(1,-152,0,132)
bags.Activated:Connect(function()root:SetAttribute('ShopTab20','bags')end)
gear.Activated:Connect(function()root:SetAttribute('ShopTab20','gear')end)
buy.Activated:Connect(function()
 if buy.Active and state.gear and os.clock()>=pending then pending=os.clock()+1 shared.Remotes.ActionRequest:FireServer('BuyGrip',tostring(state.gear.level))end
end)
local function render()
 local width=shop.AbsoluteSize.X local side=width<500 and 96 or 116 local x=side+24
 shop.Info.Position=UDim2.fromOffset(16,42)shop.Info.Size=UDim2.new(1,-32,0,28)
 bags.Position=UDim2.fromOffset(12,76)bags.Size=UDim2.fromOffset(side,44)
 gear.Position=UDim2.fromOffset(12,128)gear.Size=UDim2.fromOffset(side,44)
 local isGear=root:GetAttribute('ShopTab20')=='gear'
 theme.Action(bags,true,isGear)theme.Action(gear,true,not isGear)
 for i,id in ipairs(config.CosmeticOrder)do local row=shop[id]row.Visible=not isGear row.Position=UDim2.fromOffset(x,76+(i-1)*48)row.Size=UDim2.new(1,-x-12,0,44)end
 panel.Position=UDim2.fromOffset(x,76)panel.Size=UDim2.new(1,-x-12,0,188)panel.Visible=isGear
 local g=state.gear
 if not g then level.Text='Memuat peralatan...'detail.Text=''price.Text=''buy.Text='Memuat...'buy.Active=false return end
 level.Text=g.level==0 and string.format('Level 0/%d · standar',g.maxLevel)or string.format('Level %d/%d · pemakaian genggaman -%d%%',g.level,g.maxLevel,g.reductionPercent)
 detail.Text=g.maxed and 'Peningkatan genggaman sudah maksimal. Bonus berlaku mulai pesanan berikutnya.'or string.format('Level berikut: pemakaian genggaman -%d%% saat sprint. Berlaku mulai pesanan berikutnya.',g.nextReductionPercent)
 price.Text=g.maxed and string.format('Saldo %d koin',state.coins or 0)or string.format('Saldo %d / harga %d koin',state.coins or 0,g.nextPrice)
 local char=player.Character local r=char and char:FindFirstChild('HumanoidRootPart')local hum=char and char:FindFirstChildOfClass('Humanoid')
 local map=workspace:FindFirstChild('PaketKilat')map=map and map:FindFirstChild('Map')local depot=map and map:FindFirstChild('Depot')local point=depot and depot:FindFirstChild('ShopPoint')
 local near=r and point and(r.Position-point.Position).Magnitude<=config.ActionDistance
 local ready=state.profileReady and state.status=='Idle'and near and hum and hum.Health>0 and not g.maxed and(state.coins or 0)>=g.nextPrice and os.clock()>=pending
 buy.Active=ready==true buy.AutoButtonColor=ready==true theme.Action(buy,ready==true,false)
 buy.Text=g.maxed and 'Maksimal'or state.status~='Idle'and 'Selesaikan pesanan'or not near and 'Ke depot'or os.clock()<pending and 'Memproses...'or(state.coins or 0)<g.nextPrice and ('Kurang '..(g.nextPrice-(state.coins or 0)))or ('Beli '..g.nextPrice)
end
shared.Remotes.StateChanged.OnClientEvent:Connect(function(s)state=s render()end)
root:GetAttributeChangedSignal('ShopTab20'):Connect(render)
local elapsed=0 game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed+=dt if elapsed>=.1 then elapsed=0 render()end end)
render()