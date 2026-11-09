-- Edit migration after auditing free Creator Store candidates in ServerStorage.
local ss=game.ServerStorage local w=workspace.PaketKilat local m=w.Map local o=m.DepotPad.Position
assert(ss:FindFirstChild("PaketKilat_PrePolish07"),"Backup first")
assert(not m:FindFirstChild("CreatorStore07"),"Already installed")
local review=ss.CreatorStoreReview07
local f=Instance.new("Folder") f.Name="CreatorStore07" f.Parent=m
local library=Instance.new("Folder") library.Name="PaketKilat_CreatorAssets07" library.Parent=ss
local function clean(source,name,id,creator)
 local clone=source:Clone() clone.Name=name
 for _,v in ipairs(clone:GetDescendants()) do
  if v:IsA("LuaSourceContainer") or v:IsA("PackageLink") or v:IsA("JointInstance") or v:IsA("Constraint") or v:IsA("Sound") or v:IsA("ProximityPrompt") or v:IsA("ClickDetector") or v:IsA("GuiBase2d") then v:Destroy()
  elseif v:IsA("BasePart") then
   v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=false
   if v:IsA("Seat") or v:IsA("VehicleSeat") then v.Disabled=true end
  end
 end
 clone:SetAttribute("CreatorStoreAssetId",id) clone:SetAttribute("CreatorName",creator)
 clone:SetAttribute("SourceURL","https://create.roblox.com/store/asset/"..id)
 clone:SetAttribute("FreeAtReview",true) clone.Parent=library return clone
end
local tree=clean(review.TreeCandidateB,"BroadleafTree","4893246329","Abishpc")
local bench=clean(review.WoodenBench,"ParkBench","111013476485423","thatpower29")
local fence=clean(review.WoodenFence,"WoodFence","8092188374","logoffkid")
local function place(source,name,x,z,height,yaw)
 local clone=source:Clone() clone.Name=name
 local cf,size=clone:GetBoundingBox()
 if height then clone:ScaleTo(clone:GetScale()*height/size.Y) end
 cf,size=clone:GetBoundingBox()
 local rel=clone:GetPivot():ToObjectSpace(cf)
 local target=CFrame.new(o+Vector3.new(x,1.08+size.Y/2,z))*CFrame.Angles(0,yaw or 0,0)
 clone:PivotTo(target*rel:Inverse()) clone.Parent=f return clone
end
-- Replace the old sphere trees at the exact supported garden locations.
local oldTrunks={}
for _,v in ipairs(m.Expansion.Decor:GetChildren()) do if v.Name=="TreeTrunk" then table.insert(oldTrunks,v) end end
for i,trunk in ipairs(oldTrunks) do
 local pos=trunk.Position-o
 place(tree,"GardenTree"..i,pos.X,pos.Z,11.5,math.rad(i*37))
 for _,v in ipairs(m.Expansion.Decor:GetChildren()) do
  if v:IsA("BasePart") and v.Name=="TreeCrown" and math.abs(v.Position.X-trunk.Position.X)<.05 and math.abs(v.Position.Z-trunk.Position.Z)<.05 then v:Destroy() end
 end
 trunk:Destroy()
end
place(bench,"DepotBench",-13,2,nil,math.pi/2)
for i,z in ipairs({-9,-.5,8}) do place(fence,"DepotFence"..i,-15,z,2.44,0) end
-- Retain no rejected pack, unused templates, or off-map comparison objects.
if workspace:FindFirstChild("CreatorStorePreview07") then workspace.CreatorStorePreview07:Destroy() end
review:Destroy()
game.StarterGui.PaketKilatUI.Enabled=true
w:SetAttribute("AssetRevision","CreatorStore07")
return {trees=#oldTrunks,bench=1,fenceSegments=3,staticParts=(function()local n=0 for _,v in ipairs(f:GetDescendants())do if v:IsA("BasePart")then n+=1 end end return n end)()}
