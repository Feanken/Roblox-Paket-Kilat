-- Tabs share the existing shop modal; no extra permanent HUD.
local player=game.Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild('PaketKilat')
local config=require(shared.Shared.Config)local theme=require(shared.Shared.UITheme12)
local root=player:WaitForChild('PlayerGui'):WaitForChild('PaketKilatUI'):WaitForChild('Root')local shop=root:WaitForChild('Shop')
local catalog=shop:WaitForChild("Catalog")
local state={}local pending=0
root:SetAttribute('ShopTab20','bags')
local function button(parent,name,text)
 local b=Instance.new('TextButton')b.Name=name b.Text=text b.TextSize=12 b.ZIndex=12 b.Parent=parent theme.Action(b,true,false)return b
end
local bags=button(shop,'BagsTab20','Tas')local gear=button(shop,'GearTab20','Peralatan')
local panel=Instance.new('Frame')panel.Name='GearPanel20'panel.BackgroundColor3=theme.Soft panel.BorderSizePixel=0 panel.ZIndex=11 panel.Visible=false panel.Parent=catalog
local corner=Instance.new('UICorner')corner.CornerRadius=UDim.new(0,12)corner.Parent=panel
local function label(name,y,height,size)
 local l=Instance.new('TextLabel')l.Name=name l.Position=UDim2.fromOffset(12,y)l.Size=UDim2.new(1,-24,0,height)l.BackgroundTransparency=1 l.Font=Enum.Font.GothamMedium l.TextSize=size l.TextColor3=theme.Ink l.TextWrapped=true l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=12 l.Parent=panel return l
end
local title=label('Title',10,24,18)title.Font=Enum.Font.GothamBold title.Text='Sarung tangan kurir'
local level=label('Level',40,36,13)
local detail=label('Detail',80,38,12)detail.TextColor3=theme.Muted
local price=label('Price',132,44,12)
local buy=button(panel,'BuyGrip20','Memuat...')
bags.Activated:Connect(function()root:SetAttribute('ShopTab20','bags')end)
gear.Activated:Connect(function()root:SetAttribute('ShopTab20','gear')end)
buy.Activated:Connect(function()
 if buy.Active and state.gear and os.clock()>=pending then pending=os.clock()+1 shared.Remotes.ActionRequest:FireServer('BuyGrip',tostring(state.gear.level))end
end)
local function render()
 if not shop.Visible then return end
 local width=shop.AbsoluteSize.X
 local compact=width<500
 local x,y=compact and 12 or 144,compact and 118 or 72
 shop.Info.Position=UDim2.fromOffset(16,42)
 shop.Info.Size=UDim2.new(1,-32,0,24)
 bags.Position=UDim2.fromOffset(12,68)
 bags.Size=UDim2.fromOffset(compact and math.floor((width-32)/2) or 116,44)
 gear.Position=compact and UDim2.new(.5,4,0,68) or UDim2.fromOffset(12,120)
 gear.Size=bags.Size
 catalog.Position=UDim2.fromOffset(x,y)
 catalog.Size=UDim2.new(1,-x-12,1,-y-10)
 local isGear=root:GetAttribute('ShopTab20')=='gear'
 theme.Action(bags,true,isGear)
 theme.Action(gear,true,not isGear)
 catalog.CanvasSize=UDim2.fromOffset(0,isGear and 184 or #config.CosmeticOrder*50)
 local actionWidth=compact and 88 or 108
 for index,id in ipairs(config.CosmeticOrder) do
  local row=catalog[id]
  row.Visible=not isGear
  row.Position=UDim2.fromOffset(0,(index-1)*50)
  row.Size=UDim2.new(1,-6,0,44)
  row.Action.Size=UDim2.fromOffset(actionWidth,44)
  row.Action.Position=UDim2.new(1,-actionWidth-2,0,0)
  row:FindFirstChild("Name").Size=UDim2.new(1,-actionWidth-64,1,0)
 end
 panel.Position=UDim2.fromOffset(0,0)
 panel.Size=UDim2.new(1,-6,0,182)
 panel.Visible=isGear
 local previewWidth=compact and 76 or 100
 local preview=panel:FindFirstChild("GlovePreview34")
 local note=panel:FindFirstChild("ModelLabel34")
 if preview then
  preview.Size=UDim2.fromOffset(previewWidth,86)
  preview.Position=UDim2.new(1,-previewWidth-8,0,8)
 end
 if note then
  note.Size=UDim2.fromOffset(previewWidth,16)
  note.Position=UDim2.new(1,-previewWidth-8,0,94)
 end
 for _,label in ipairs({title,level,detail}) do
  label.Size=UDim2.new(1,-previewWidth-28,0,label.Size.Y.Offset)
 end
 title.TextSize=compact and 14 or 17
 local buyWidth=compact and 110 or 140
 buy.Position=UDim2.new(1,-buyWidth-10,0,128)
 buy.Size=UDim2.fromOffset(buyWidth,44)
 price.Position=UDim2.fromOffset(12,128)
 price.Size=UDim2.new(1,-buyWidth-30,0,44)
 local g=state.gear
 if not g then level.Text='Memuat peralatan...'detail.Text=''price.Text=''buy.Text='Memuat...'buy.Active=false return end
 level.Text=string.format("Lv %d/%d · pemakaian genggaman −%d%%",g.level,g.maxLevel,g.reductionPercent)
 detail.Text=g.maxed and "Genggaman sudah maksimal." or string.format("Lv %d · −%d%% saat sprint. Aktif mulai kiriman berikutnya.",g.level+1,g.nextReductionPercent)
 price.Text=g.maxed and "Semua level terbuka" or string.format("Harga upgrade\n%d koin",g.nextPrice)
 local near=root:GetAttribute("ShopInRange")==true
 local ready=state.profileReady and state.status=='Idle'and near and not g.maxed and(state.coins or 0)>=g.nextPrice and os.clock()>=pending
 buy.Active=ready==true buy.AutoButtonColor=ready==true theme.Action(buy,ready==true,false)
 buy.Text=g.maxed and 'Maksimal'or state.status~='Idle'and 'Selesaikan pesanan'or not near and 'Ke depot'or os.clock()<pending and 'Memproses...'or(state.coins or 0)<g.nextPrice and ('Kurang '..(g.nextPrice-(state.coins or 0)))or ('Beli '..g.nextPrice)
end
shared.Remotes.StateChanged.OnClientEvent:Connect(function(s)state=s render()end)
root:GetAttributeChangedSignal('ShopTab20'):Connect(function()
 catalog.CanvasPosition=Vector2.zero
 render()
end)
shop:GetPropertyChangedSignal("Visible"):Connect(function()
 catalog.CanvasPosition=Vector2.zero
 render()
end)
local elapsed=0 game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed+=dt if elapsed>=.1 then elapsed=0 render()end end)
render()
