-- Edit migration after auditing free asset12084344112. Decorative stack only.
local w=workspace.PaketKilat local m=w.Map local o=m.DepotPad.Position
assert(not m:FindFirstChild("DepotParcels10"),"Already installed")
local input=game.ServerStorage.CreatorStoreReview10.CardboardBox
local library=Instance.new("Folder") library.Name="PaketKilat_CreatorAssets10" library.Parent=game.ServerStorage
local template=input:Clone() template.Name="CardboardBox"
for _,v in ipairs(template:GetDescendants()) do
 if v:IsA("LuaSourceContainer") or v:IsA("Camera") or v:IsA("PackageLink") or v:IsA("JointInstance") or v:IsA("Constraint") or v:IsA("Sound") or v:IsA("GuiBase2d") then v:Destroy()
 elseif v:IsA("BasePart") then v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=false end
end
template:SetAttribute("CreatorStoreAssetId","12084344112") template:SetAttribute("CreatorName","NickiBreeki")
template:SetAttribute("SourceURL","https://create.roblox.com/store/asset/12084344112") template:SetAttribute("FreeAtReview",true)
template.Parent=library
local f=Instance.new("Folder") f.Name="DepotParcels10" f.Parent=m
local params=RaycastParams.new() params.FilterType=Enum.RaycastFilterType.Include params.FilterDescendantsInstances={m.DepotPad,m.Polish04.DepotTileFloor} params.RespectCanCollide=false
local floor=workspace:Raycast(o+Vector3.new(-12.7,3,-4.8),Vector3.new(0,-8,0),params)
assert(floor,"Depot floor missing")
for i,at in ipairs({{-12.7,-4.8,0},{-12.7,-7.2,0},{-12.7,-4.8,1.4},{-12.7,-7.2,1.4}}) do
 local clone=template:Clone() clone.Name="ParcelDisplay"..i
 local cf,size=clone:GetBoundingBox() clone:ScaleTo(clone:GetScale()*1.4/size.Y)
 cf,size=clone:GetBoundingBox() local rel=clone:GetPivot():ToObjectSpace(cf)
 local target=CFrame.new(o.X+at[1],floor.Position.Y+at[3]+size.Y/2,o.Z+at[2])
 clone:PivotTo(target*rel:Inverse()) clone.Parent=f
end
game.ServerStorage.CreatorStoreReview10:Destroy()
w:SetAttribute("DepotRevision","Polish10")
return {boxes=4,scripts=0}
