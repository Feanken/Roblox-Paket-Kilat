-- Run only in Edit after inserting free asset 15022611108 into ServerStorage.PaketKilat_City32Review.
-- Keep candidate code out of Workspace/Play; whitelist rendering descendants into a new template.
assert(not game:GetService("RunService"):IsRunning(),"Edit only")
local storage=game.ServerStorage
assert(not storage:FindFirstChild("PaketKilat_CreatorAssets32"),"Template already installed")
local raw=storage:FindFirstChild("PaketKilat_City32Review")assert(raw,"Insert the reviewed bicycle candidate first")
local allowed={MeshPart=true,Part=true,SpecialMesh=true,SurfaceAppearance=true,Decal=true,Texture=true}
local model=Instance.new("Model")model.Name="Bicycle"
local count=0
for _,v in raw:GetDescendants()do
 if v:IsA("BasePart")then
  local p=v:Clone()
  for _,child in p:GetDescendants()do if not allowed[child.ClassName]then child:Destroy()end end
  p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false
  p.Parent=model count+=1
 end
end
assert(count==3,"Candidate structure changed; inspect again")
for _,v in model:GetDescendants()do assert(allowed[v.ClassName],"Unexpected template descendant")end
local lib=Instance.new("Folder")lib.Name="PaketKilat_CreatorAssets32"lib.Parent=storage
model:SetAttribute("SourceAssetId","15022611108")model.Parent=lib
raw:Destroy()
return {parts=count,template=model:GetFullName()}
