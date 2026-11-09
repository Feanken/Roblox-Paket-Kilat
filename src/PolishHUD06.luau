-- Edit migration. Source rendering/feedback patches must accompany this layout.
local root=game.StarterGui.PaketKilatUI.Root
local card=root.TopCard
card.Size=UDim2.fromOffset(320,132)
card.BackgroundColor3=Color3.fromRGB(25,65,66)
card.Title.TextSize=12 card.Title.Position=UDim2.fromOffset(14,7)
card.Coins.TextSize=16 card.Coins.Position=UDim2.new(1,-130,0,7)
card.Destination.Position=UDim2.fromOffset(14,33) card.Destination.TextSize=16
card.ConditionText.Position=UDim2.fromOffset(14,58) card.ConditionText.TextSize=12
card.ConditionTrack.Position=UDim2.fromOffset(14,83) card.ConditionTrack.Size=UDim2.new(1,-28,0,5)
card.Hint.Position=UDim2.fromOffset(14,96) card.Hint.Size=UDim2.new(1,-28,0,28) card.Hint.TextSize=11
root.StorageStatus.Position=UDim2.fromOffset(14,150) root.StorageStatus.Size=UDim2.fromOffset(320,22)
root.StorageStatus.TextSize=10 root.StorageStatus.BackgroundColor3=Color3.fromRGB(39,82,82)
root.Guide.Size=UDim2.fromOffset(430,52) root.Guide.Close.Position=UDim2.new(1,-52,0,4)
root.Guide.BackgroundColor3=Color3.fromRGB(25,65,66)
workspace.PaketKilat:SetAttribute("InterfaceRevision","Polish06")
return "Compact HUD layout installed"
