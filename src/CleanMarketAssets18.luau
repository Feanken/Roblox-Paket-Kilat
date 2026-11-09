-- Edit only. Insert source models under ServerStorage.CreatorReview18 with these names.
assert(not game.ServerStorage:FindFirstChild('PaketKilat_MarketAssets18'),'Clean library exists')
local f=Instance.new('Folder')f.Name='PaketKilat_MarketAssets18'f.Parent=game.ServerStorage
for _,spec in ipairs({{'Low-Poly Bread Loaf','Bread',14375985405},{'Grow A Garden Carrot Plant','Carrot',80121378677251},{'Fruit basket','FruitBasket',4563688216},{'Fruit Model','LooseFruit',12831453}})do
 local m=Instance.new('Model')m.Name=spec[2]m:SetAttribute('CreatorAssetId',spec[3])m.Parent=f
 for _,p in ipairs(game.ServerStorage.CreatorReview18[spec[1]]:GetDescendants())do if p:IsA('BasePart')then
  local copy=p:Clone()for _,d in ipairs(copy:GetDescendants())do if not(d:IsA('DataModelMesh')or d:IsA('SurfaceAppearance')or d:IsA('Texture')or d:IsA('Decal'))then d:Destroy()end end
  copy.Anchored=true copy.CanCollide=false copy.CanTouch=false copy.CanQuery=false copy.Parent=m
 end end
end
