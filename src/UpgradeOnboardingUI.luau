-- Additive Edit migration. Inspect before running; preserve existing HUD/shop.
local root=game.StarterGui.PaketKilatUI.Root
assert(not root:FindFirstChild("Guide"),"Guide exists; inspect instead of rebuilding")
local function text(parent,name,size,pos,value,button)
	local v=Instance.new(button and "TextButton" or "TextLabel") v.Name=name v.Size=size v.Position=pos v.Text=value
	v.BackgroundColor3=Color3.fromRGB(31,57,73) v.TextColor3=Color3.fromRGB(243,248,250)
	v.BorderSizePixel=0 v.Font=Enum.Font.GothamMedium v.TextSize=12 v.ZIndex=3 v.Parent=parent
	local round=Instance.new("UICorner") round.CornerRadius=UDim.new(0,8) round.Parent=v
	return v
end
local help=text(root,"HelpToggle",UDim2.fromOffset(100,44),UDim2.new(1,-228,0,12),"Petunjuk",true)
local guide=Instance.new("Frame") guide.Name="Guide" guide.AnchorPoint=Vector2.new(0.5,1)
guide.Size=UDim2.fromOffset(430,66) guide.Position=UDim2.new(0.5,0,1,-12)
guide.BackgroundColor3=Color3.fromRGB(27,42,58) guide.BorderSizePixel=0 guide.ZIndex=2 guide.Parent=root
local hint=text(guide,"Hint",UDim2.new(1,-124,1,-12),UDim2.fromOffset(12,6),"Memuat petunjuk...") hint.BackgroundTransparency=1 hint.TextWrapped=true hint.TextXAlignment=Enum.TextXAlignment.Left
local fps=text(guide,"FPS",UDim2.fromOffset(48,44),UDim2.new(1,-106,0,11),"FPS",true)
fps.Visible=false -- Only manual Help exposes the diagnostic to operators.
text(guide,"Close",UDim2.fromOffset(44,44),UDim2.new(1,-52,0,11),"Tutup",true)
return "Guide and HelpToggle added; no mechanics changed"
