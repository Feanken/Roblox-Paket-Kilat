-- Edit-mode migration after installing Gear20 and GearShop20 source.
-- Gameplay upgrades use primitive gloves; no external asset is required.
local world = workspace:WaitForChild("PaketKilat")
game:GetService("StarterGui").PaketKilatUI.Root.Shop.Title.Text = "Perlengkapan kurir"
local billboard = world.Map.Depot.ShopPoint:FindFirstChildWhichIsA("BillboardGui")
if billboard then
	for _, child in billboard:GetDescendants() do
		if child:IsA("TextLabel") then child.Text = "TOKO KURIR · B" end
	end
end
world:SetAttribute("ProgressionRevision", "GripGear20")
return "Gear20 shop label ready"
