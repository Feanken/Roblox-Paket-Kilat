-- Run after PolishVillage01 and procedural generation 8a74bd48-5f8c-4e42-b7a7-1b670915870d.
local map=workspace.PaketKilat.Map
local f=map.Polish01
assert(not f:FindFirstChild("DepotFacade"),"Facade already installed")
local generated=workspace:FindFirstChild("ParcelDepotFacade")
assert(generated,"Generated depot missing")
-- Retain the editable generated source outside Workspace. Runtime gets static geometry only.
local model=generated:Clone() model.Name="DepotFacade"
for _,v in ipairs(model:GetDescendants()) do
 if v:IsA("LuaSourceContainer") then v:Destroy()
 elseif v:IsA("BasePart") then v.Anchored=true v.CanCollide=false v.CanTouch=false v.CanQuery=false end
end
local box,size=model:GetBoundingBox()
local relative=model:GetPivot():ToObjectSpace(box)
local target=CFrame.new(map.DepotPad.Position+Vector3.new(0,1+size.Y/2,-8))*CFrame.Angles(0,math.pi,0)
model:PivotTo(target*relative:Inverse()) model.Parent=f
generated.Parent=game.ServerStorage.PaketKilat_PrePolish01
for _,name in ipairs({"BackWall","BackWallRight","Roof"}) do map.Depot[name].Transparency=1 end
-- Retire the provisional duplicate canopy and supports in the scoped backup.
local archive=Instance.new("Folder") archive.Name="ProvisionalTrim" archive.Parent=game.ServerStorage.PaketKilat_PrePolish01
for _,v in ipairs(f:GetChildren()) do
 if v.Name=="StripedAwning" or v.Name=="DepotPost" or v.Name=="DepotFascia" then v.Parent=archive end
end
local brand=f.DepotBrand
brand.Position=map.DepotPad.Position+Vector3.new(0,8.6,.6)
brand.Size=Vector3.new(7,1.35,.2)
-- Generated gable wedges protruded above the roof. Hide these four artifacts.
for _,v in ipairs(model:GetDescendants()) do
 if v:IsA("BasePart") and v.Name:find("Gable") then v.Transparency=1 end
end
f.CanalWater.Color=Color3.fromRGB(79,128,123)
f.CanalWater.Material=Enum.Material.SmoothPlastic f.CanalWater.Transparency=.12 f.CanalWater.Reflectance=.04
return {facadeSize=tostring(size),staticParts=#model:GetDescendants()}
