-- Edit only. Insert assets under ServerStorage.CreatorReview15 using their original names first.
assert(not game.ServerStorage:FindFirstChild('PaketKilat_CreatorAssets15'),'Clean library exists')
local clean=Instance.new('Folder')clean.Name='PaketKilat_CreatorAssets15'clean.Parent=game.ServerStorage
for _,spec in ipairs({{'food cart for hunter project','FoodCart',5362266328},{'Simple low poly picnic table','PicnicTable',5256845941}})do
 local src=game.ServerStorage.CreatorReview15[spec[1]]local model=Instance.new('Model')model.Name=spec[2]model:SetAttribute('CreatorAssetId',spec[3])model.Parent=clean
 for _,p in ipairs(src:GetDescendants())do if p:IsA('BasePart')then
  local copy=p:Clone()
  for _,d in ipairs(copy:GetDescendants())do if not(d:IsA('DataModelMesh')or d:IsA('SurfaceAppearance')or d:IsA('Texture')or d:IsA('Decal'))then d:Destroy()end end
  copy.Anchored=true copy.CanCollide=false copy.CanTouch=false copy.CanQuery=false copy.Parent=model
 end end
end
