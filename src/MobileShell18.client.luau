-- Phone-only disclosure menu; existing controllers retain their callbacks.
local player=game.Players.LocalPlayer
local shared=game.ReplicatedStorage:WaitForChild('PaketKilat')local theme=require(shared.Shared.UITheme12)
local root=player:WaitForChild('PlayerGui'):WaitForChild('PaketKilatUI'):WaitForChild('Root')
local originalSigns=setmetatable({},{__mode='k'})
local menu=Instance.new('TextButton')menu.Name='MobileMenu18'menu.Size=UDim2.fromOffset(84,44)menu.Position=UDim2.new(1,-96,0,8)menu.Text='Menu'menu.ZIndex=5 menu.Parent=root theme.ToolbarButton(menu)
local panel=Instance.new('Frame')panel.Name='MobileMenuPanel18'panel.Position=UDim2.new(1,-240,0,60)panel.Size=UDim2.fromOffset(228,154)panel.BackgroundColor3=theme.Ink panel.BorderSizePixel=0 panel.ZIndex=2 panel.Parent=root
local c=Instance.new('UICorner')c.CornerRadius=UDim.new(0,14)c.Parent=panel
local target=menu:Clone()target.Name='MobileTargetButton18'target.Text='Target sesi'target.Size=UDim2.fromOffset(204,44)target.Position=UDim2.new(1,-228,0,162)target.ZIndex=4 target.Parent=root
local notice=Instance.new('TextLabel')notice.Name='MobileNotice18'notice.AnchorPoint=Vector2.new(.5,0)notice.Position=UDim2.new(.5,0,0,140)notice.Size=UDim2.fromOffset(330,36)notice.BackgroundColor3=theme.Ink notice.TextColor3=theme.Cream notice.Font=Enum.Font.GothamMedium notice.TextSize=12 notice.TextWrapped=true notice.ZIndex=6 notice.Parent=root c:Clone().Parent=notice
menu.Activated:Connect(function()local open=not root:GetAttribute('MobileMenuOpen18')root:SetAttribute('MobileMenuOpen18',open)if open then root:SetAttribute('MobileTargetOpen18',false)end end)
target.Activated:Connect(function()root:SetAttribute('MobileTargetOpen18',not root:GetAttribute('MobileTargetOpen18'))root:SetAttribute('MobileMenuOpen18',false)end)
local function render()
 local mobile=theme.IsMobile(root)local result=root:FindFirstChild('DeliveryCelebration')
 local gallery=root:FindFirstChild('GalleryReader')
 local blocked=root:GetAttribute("OrderOptionsOpen") or (gallery and gallery.Visible)or root.Shop.Visible or root:GetAttribute('JobBoardOpen17')or root:GetAttribute('AudioOpen33')or(result and result.Visible)
 if blocked or not mobile then root:SetAttribute('MobileMenuOpen18',false)root:SetAttribute('MobileTargetOpen18',false)end
 local open=root:GetAttribute('MobileMenuOpen18')==true
 menu.Visible=mobile and not blocked panel.Visible=mobile and open and not blocked target.Visible=panel.Visible
 local status=root:GetAttribute("Status")
 target.Size=UDim2.fromOffset((status=="Carrying" or status=="Dropped") and 96 or 204,44)
 notice.Text=root:GetAttribute('MobileNoticeText18')or ''
 notice.Size=UDim2.fromOffset(math.max(1, math.min(330, root.AbsoluteSize.X - 24)), 36)
 notice.Visible=mobile and not blocked and not open and not root:GetAttribute('MobileTargetOpen18') and os.clock()<(root:GetAttribute('MobileNoticeUntil18')or 0)
 theme.ToolbarLayout(root)
 local world=workspace:FindFirstChild('PaketKilat')local map=world and world:FindFirstChild('Map')
 local depot=map and map:FindFirstChild('Depot')
 for _,spec in ipairs({{depot and depot:FindFirstChild('PickupPoint'),'Idle'},{map and map:FindFirstChild('RecoveryPoint'),'Dropped'},{depot and depot:FindFirstChild('ShopPoint'),'Never'}})do
  local point=spec[1]local sign=point and point:FindFirstChildWhichIsA('BillboardGui')
  if sign then
   if originalSigns[sign]==nil then originalSigns[sign]=sign.Enabled end
   sign.Enabled=mobile and(root:GetAttribute('Status')==spec[2]and not blocked and not open)or not mobile and originalSigns[sign]
  end
 end
end
local elapsed=0 game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed+=dt if elapsed>=.1 then elapsed=0 render()end end)
render()
