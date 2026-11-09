-- Additive Edit migration; existing stage3 HUD/map preserved.
local root=game.StarterGui.PaketKilatUI.Root
assert(not root:FindFirstChild("Shop"),"Inspect existing shop before replacing")
local function label(parent,name,size,pos,text,button)
	local x=Instance.new(button and "TextButton" or "TextLabel")
	x.Name=name x.Size=size x.Position=pos x.Text=text x.TextSize=14
	x.Font=Enum.Font.GothamMedium x.TextColor3=Color3.fromRGB(244,248,250)
	x.BackgroundColor3=Color3.fromRGB(40,65,80) x.BorderSizePixel=0 x.Parent=parent
	local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,8) c.Parent=x
	return x
end
local status=label(root,"StorageStatus",UDim2.fromOffset(360,38),UDim2.fromOffset(14,174),"Memuat profil...")
status.TextWrapped=true status.TextSize=12 status.ZIndex=2
local toggle=label(root,"ShopToggle",UDim2.fromOffset(100,42),UDim2.new(1,-116,0,12),"Toko [B]",true)
toggle.ZIndex=3
local shop=Instance.new("Frame") shop.Name="Shop" shop.Size=UDim2.fromOffset(430,300)
shop.AnchorPoint=Vector2.new(0.5,0.5) shop.Position=UDim2.fromScale(0.5,0.5)
shop.BackgroundColor3=Color3.fromRGB(27,42,58) shop.BorderSizePixel=0 shop.Visible=false shop.ZIndex=10 shop.Parent=root
local corner=Instance.new("UICorner") corner.CornerRadius=UDim.new(0,12) corner.Parent=shop
label(shop,"Title",UDim2.new(1,-82,0,34),UDim2.fromOffset(12,8),"TOKO TAS · koin permainan").ZIndex=11
label(shop,"Close",UDim2.fromOffset(48,44),UDim2.new(1,-60,0,6),"Tutup",true).ZIndex=11
local info=label(shop,"Info",UDim2.new(1,-24,0,36),UDim2.fromOffset(12,52),"Beli/pakai di depot. Tanpa tambahan kecepatan.")
info.TextWrapped=true info.TextSize=12 info.ZIndex=11
local C=require(game.ReplicatedStorage.PaketKilat.Shared.Config)
for i,id in ipairs(C.CosmeticOrder) do
	local item=C.Cosmetics[id]
	local row=Instance.new("Frame") row.Name=id row.Size=UDim2.new(1,-24,0,44) row.Position=UDim2.fromOffset(12,94+(i-1)*48)
	row.BackgroundColor3=item.Color row.BorderSizePixel=0 row.ZIndex=11 row.Parent=shop
	local t=label(row,"Name",UDim2.new(1,-132,1,0),UDim2.fromOffset(8,0),item.Name.." · "..item.Price)
	t.BackgroundTransparency=1 t.TextXAlignment=Enum.TextXAlignment.Left t.ZIndex=12
	local b=label(row,"Action",UDim2.fromOffset(112,44),UDim2.new(1,-118,0,0),"Memuat",true) b.ZIndex=12
end
local depot=workspace.PaketKilat.Map.Depot
assert(not depot:FindFirstChild("ShopPoint"),"ShopPoint already exists")
local point=Instance.new("Part") point.Name="ShopPoint" point.Size=Vector3.new(5,0.3,5)
point.Anchored=true point.Color=Color3.fromRGB(246,196,74)
point.CFrame=CFrame.new(depot.PickupPoint.Position+Vector3.new(-7,0,0)) point.Parent=depot
local billboard=Instance.new("BillboardGui") billboard.Size=UDim2.fromOffset(160,34) billboard.StudsOffset=Vector3.new(0,4,0) billboard.AlwaysOnTop=true billboard.MaxDistance=70 billboard.Parent=point
label(billboard,"Label",UDim2.fromScale(1,1),UDim2.new(),"TOKO TAS · B")
return "Store UI + ShopPoint added"
