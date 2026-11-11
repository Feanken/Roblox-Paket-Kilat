-- Shared presentation tokens and deterministic layout; no gameplay state or remotes.
local T={Cream=Color3.fromRGB(250,246,234),Ink=Color3.fromRGB(25,65,66),Muted=Color3.fromRGB(95,114,110),
 Gold=Color3.fromRGB(249,197,81),Line=Color3.fromRGB(217,224,210),Soft=Color3.fromRGB(235,239,226),White=Color3.fromRGB(255,253,246)}
local function round(obj,r)
 local c=obj:FindFirstChildOfClass("UICorner")or Instance.new("UICorner") c.CornerRadius=UDim.new(0,r) c.Parent=obj
end
local function border(obj,color)
 local s=obj:FindFirstChildOfClass("UIStroke")or Instance.new("UIStroke") s.Color=color or T.Line s.Thickness=1 s.Transparency=0 s.Parent=obj
end
local function label(t,color,size,font)
 if not t then return end t.TextColor3=color t.TextSize=size t.Font=font or Enum.Font.GothamMedium
 t.BackgroundTransparency=1
end
function T.ToolbarButton(b)
 b.BackgroundColor3=T.Cream b.TextColor3=T.Ink b.BorderSizePixel=0 b.TextSize=12 b.Font=Enum.Font.GothamBold
 round(b,12) border(b,T.Line)
end
function T.IsMobile(ui)
 return game:GetService("UserInputService").TouchEnabled and (ui.AbsoluteSize.X<1000 or ui.AbsoluteSize.Y<600)
end
function T.MobileCardWidth(ui)
 return math.clamp(ui.AbsoluteSize.X - 112, 160, 238)
end

function T.ToolbarLayout(ui)
 local mobile=T.IsMobile(ui)
 local open=ui:GetAttribute("MobileMenuOpen18")==true
 local result=ui:FindFirstChild("DeliveryCelebration")
 local gallery=ui:FindFirstChild("GalleryReader")
 local blocked=ui.Shop.Visible or ui:GetAttribute("JobBoardOpen17")==true
  or ui:GetAttribute("AudioOpen33")==true or (result and result.Visible) or (gallery and gallery.Visible)
 for i,name in ipairs({"RouteToggle","HelpToggle","ShopToggle","AudioToggle33"})do
  local b=ui:FindFirstChild(name)
  if b then
   b.Size=UDim2.fromOffset(mobile and 96 or 84,44)
   b.Position=mobile and UDim2.new(1,-228+((i-1)%2)*108,0,66+math.floor((i-1)/2)*48)or UDim2.new(1,name=="AudioToggle33"and -98 or -282+(i-1)*92,0,(ui.AbsoluteSize.Y<500 and 12 or 20)+(name=="AudioToggle33"and 50 or 0))
   if name~="RouteToggle" then b.Visible=(not mobile or open) and not blocked end
   b.ZIndex=mobile and 4 or 2
  end
 end
end
function T.Action(b,enabled,secondary)
 b.BackgroundColor3=not enabled and T.Soft or secondary and T.Cream or T.Gold
 b.TextColor3=enabled and T.Ink or T.Muted b.Font=Enum.Font.GothamBold
 b.BorderSizePixel=0 round(b,12) border(b,secondary and T.Line or b.BackgroundColor3)
end
function T.Layout(ui,manual)
 local compact=ui.AbsoluteSize.Y<500 local margin=compact and 12 or 20
 local width=compact and math.min(260,math.max(230,ui.AbsoluteSize.X-300))or 300
 local card=ui.TopCard local height=compact and 136 or 152
 card.Size=UDim2.fromOffset(width,height)card.Position=UDim2.fromOffset(margin,margin)
 card.Title.Position=UDim2.fromOffset(14,13)card.Title.Size=UDim2.new(1,-120,0,18)
 card.Coins.Position=UDim2.new(1,-102,0,10)card.Coins.Size=UDim2.fromOffset(88,25)
 card.Destination.Position=UDim2.fromOffset(14,compact and 45 or 48)card.Destination.Size=UDim2.new(1,-28,0,24)
 card.Destination.TextSize=compact and 16 or 18
 card.ConditionText.Position=UDim2.fromOffset(14,compact and 71 or 76)
 card.ConditionTrack.Position=UDim2.fromOffset(14,compact and 91 or 97)
 card.Hint.Position=UDim2.fromOffset(14,compact and 101 or 107)card.Hint.Size=UDim2.new(1,-28,0,compact and 28 or 34)
 card.Hint.TextSize=11
 ui.StorageStatus.Position=UDim2.fromOffset(margin+2,margin+height+4)ui.StorageStatus.Size=UDim2.fromOffset(width,20)
 local guideHeight=manual and 66 or 52
 ui.Guide.Size=UDim2.fromOffset(math.min(compact and 370 or 430,math.max(260,ui.AbsoluteSize.X-290)),guideHeight)
 ui.Guide.Close.Position=UDim2.new(1,-52,0,(guideHeight-44)/2)
 ui.Guide.FPS.Position=UDim2.new(1,-106,0,(guideHeight-44)/2)
 local mobile=T.IsMobile(ui)
 card.Hint.Visible=not mobile
 local divider=card:FindFirstChild("Divider")if divider then divider.Visible=not mobile end
 local pill=card:FindFirstChild("CoinBadge")
 if mobile then
  card.Size=UDim2.fromOffset(T.MobileCardWidth(ui),78)card.Position=UDim2.fromOffset(12,8)
  card.Title.Position=UDim2.fromOffset(10,8)card.Title.Size=UDim2.fromOffset(110,16)card.Title.TextSize=10
  card.Coins.Position=UDim2.new(1,-95,0,5)card.Coins.Size=UDim2.fromOffset(82,22)card.Coins.TextSize=12
  if pill then pill.Size=UDim2.fromOffset(88,22)pill.Position=UDim2.new(1,-98,0,5)end
  card.Destination.Position=UDim2.fromOffset(10,31)card.Destination.Size=UDim2.new(1,-20,0,20)card.Destination.TextSize=14
  card.ConditionText.Position=UDim2.fromOffset(10,49)card.ConditionText.Size=UDim2.new(1,-20,0,18)card.ConditionText.TextSize=10
  card.ConditionTrack.Position=UDim2.fromOffset(10,69)card.ConditionTrack.Size=UDim2.new(1,-20,0,3)
  ui.StorageStatus.Position=UDim2.fromOffset(12,90)
  local actionWidth = ui.AbsoluteSize.X < 430 and 112 or 140
  ui.Actions.AnchorPoint=Vector2.new(1,0)ui.Actions.Position=UDim2.new(1,-12,0,90)ui.Actions.Size=UDim2.fromOffset(actionWidth,96)
  ui.Actions.Primary.Size=UDim2.fromOffset(actionWidth,44)ui.Actions.Secondary.Size=UDim2.fromOffset(actionWidth,44)ui.Actions.Secondary.Position=UDim2.fromOffset(0,52)
 else
  card.Title.TextSize=11 card.Coins.TextSize=14 card.ConditionText.TextSize=11
  card.ConditionText.Size=UDim2.new(1,-28,0,20)card.ConditionTrack.Size=UDim2.new(1,-28,0,4)
  if pill then pill.Size=UDim2.fromOffset(94,25)pill.Position=UDim2.new(1,-105,0,10)end
  ui.Actions.AnchorPoint=Vector2.new(1,.5)ui.Actions.Position=UDim2.new(1,-16,.47,0)ui.Actions.Size=UDim2.fromOffset(152,108)
  ui.Actions.Primary.Size=UDim2.fromOffset(152,48)ui.Actions.Secondary.Size=UDim2.fromOffset(152,48)ui.Actions.Secondary.Position=UDim2.fromOffset(0,58)
 end
 if ui:GetAttribute("NavigationHeader19")then card.Title.Position=UDim2.fromOffset(mobile and 36 or 40,mobile and 8 or 13)card.Title.Size=UDim2.new(1,mobile and -146 or -152,0,18)end
 T.ToolbarLayout(ui)
 local backdrop=ui:FindFirstChild("ShopBackdrop")local camera=workspace.CurrentCamera
 if backdrop and camera then backdrop.Position=UDim2.fromOffset(-ui.AbsolutePosition.X,-ui.AbsolutePosition.Y)backdrop.Size=UDim2.fromOffset(camera.ViewportSize.X,camera.ViewportSize.Y)end
end
function T.Storage(t,state)
 local errorState=state.profileReady==false and state.profileStatus~="Loading" or state.saveStatus=="RetryPending"
 t:SetAttribute("Alert18",errorState or state.profileStatus=="Loading")
 t.BackgroundTransparency=0.05 t.BackgroundColor3=errorState and Color3.fromRGB(255,231,221)or T.Cream
 round(t,7)
 t.TextColor3=errorState and Color3.fromRGB(155,55,40)or T.Muted t.TextSize=10 t.TextXAlignment=Enum.TextXAlignment.Center
end
function T.Static(ui)
 local card=ui.TopCard card.BackgroundColor3=T.Cream round(card,16)border(card,T.Line)
 label(card.Title,T.Muted,11,Enum.Font.GothamBold)card.Title.Text="PAKET KILAT"
 label(card.Coins,T.Ink,14,Enum.Font.GothamBold)card.Coins.TextXAlignment=Enum.TextXAlignment.Center card.Coins.ZIndex=3
 local pill=card:FindFirstChild("CoinBadge")or Instance.new("Frame")pill.Name="CoinBadge"pill.Size=UDim2.fromOffset(94,25)pill.Position=UDim2.new(1,-105,0,10)pill.BackgroundColor3=T.Gold pill.BorderSizePixel=0 pill.ZIndex=1 pill.Parent=card round(pill,9)
 label(card.Destination,T.Ink,18,Enum.Font.GothamBold)label(card.ConditionText,T.Muted,11)
 for _, field in ipairs({card.Destination, card.ConditionText, card.Title}) do
  field.TextWrapped=false
  field.TextTruncate=Enum.TextTruncate.AtEnd
 end
 round(card.ConditionTrack,3)
 round(card.ConditionTrack.Fill,3)
 label(card.Hint,T.Muted,11)card.ConditionTrack.BackgroundColor3=T.Line
 local divider=card:FindFirstChild("Divider")or Instance.new("Frame")divider.Name="Divider"divider.Size=UDim2.new(1,-28,0,1)divider.Position=UDim2.fromOffset(14,39)divider.BackgroundColor3=T.Line divider.BorderSizePixel=0 divider.Parent=card
 T.ToolbarButton(ui.HelpToggle)T.ToolbarButton(ui.ShopToggle)
 ui.Guide.BackgroundColor3=T.Cream round(ui.Guide,14)border(ui.Guide,T.Line)
 label(ui.Guide.Hint,T.Ink,12)T.ToolbarButton(ui.Guide.Close)ui.Guide.Close.Text="×"ui.Guide.Close.TextSize=21
 T.ToolbarButton(ui.Guide.FPS)ui.Guide.FPS.TextSize=11
 local backdrop=ui:FindFirstChild("ShopBackdrop")or Instance.new("Frame")
 backdrop.Name="ShopBackdrop"backdrop.Size=UDim2.fromScale(1,1)backdrop.BackgroundColor3=T.Ink
 backdrop.BackgroundTransparency=.4 backdrop.BorderSizePixel=0 backdrop.ZIndex=8 backdrop.Active=true backdrop.Visible=false backdrop.Parent=ui
 local shop=ui.Shop shop.BackgroundColor3=T.Cream round(shop,18)border(shop,T.Line)
 label(shop.Title,T.Ink,19,Enum.Font.GothamBold)shop.Title.Text="Perlengkapan kurir"
 T.ToolbarButton(shop.Close)shop.Close.Text="×"shop.Close.TextSize=21
 label(shop.Info,T.Muted,11)
 for _,id in ipairs({"TasStandar","TasMerah","TasBiru","TasHijau"})do
  local row=shop[id]row.BackgroundColor3=T.Soft round(row,10)
  label(row:FindFirstChild("Name"),T.Ink,14,Enum.Font.GothamMedium)
  T.Action(row.Action,true,false)
 end
 T.Layout(ui,false)
end
function T.Result(toast)
 toast.BackgroundColor3=T.Cream round(toast,18)border(toast,T.Gold)
 label(toast.Title,T.Muted,12,Enum.Font.GothamBold)
 label(toast.Reward,T.Ink,36,Enum.Font.GothamBlack)
 label(toast.Detail,T.Muted,12)
 label(toast.Next,T.Ink,11,Enum.Font.GothamBold)
end
function T.Movement(hud,button)
 hud.BackgroundColor3=T.Ink round(hud,14)border(hud,Color3.fromRGB(62,104,100))
 T.Action(button,true,false)
 for _,name in ipairs({"StaminaText","GripText"})do label(hud[name],T.Cream,11,Enum.Font.GothamMedium)end
end
return T

