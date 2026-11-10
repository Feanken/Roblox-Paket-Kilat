-- Independent observer: cleanup still runs when the owner's VM is stopped/destroyed.
local scripts=script.Parent
local M=require(game.ReplicatedStorage:WaitForChild("PaketKilat"):WaitForChild("Shared"):WaitForChild("CityResidents37"))
local watched=setmetatable({},{__mode="k"})
local function watch(owner)
 if owner.Name~="PaketKilatResidents37"or not owner:IsA("LocalScript")or watched[owner]then return end
 watched[owner]=true
 owner.Destroying:Connect(function()M.Stop(owner)end)
 owner:GetPropertyChangedSignal("Enabled"):Connect(function()if not owner.Enabled then M.Stop(owner)end end)
 owner.AncestryChanged:Connect(function()if not owner:IsDescendantOf(scripts)then M.Stop(owner)end end)
end
scripts.ChildAdded:Connect(watch)
for _,v in scripts:GetChildren()do watch(v)end
