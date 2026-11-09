-- Edit-only import: insert asset13782728612 into ServerStorage.PaketKilat_CreatorReview23 first.
local ss=game.ServerStorage
assert(not ss:FindFirstChild('PaketKilat_CreatorAssets23'),'Library already exists')
local source=ss.PaketKilat_CreatorReview23:FindFirstChild('Better Low Poly Fountain')
assert(source,'Insert the named Creator Store candidate first')
local lib=Instance.new('Folder')lib.Name='PaketKilat_CreatorAssets23'lib.Parent=ss
local model=Instance.new('Model')model.Name='Fountain'
for _,p in source:GetDescendants()do
	if p:IsA('BasePart')and p.Transparency<.99 and p.Material~=Enum.Material.Glass and not(p.Material==Enum.Material.Neon and p.Color.B<.5)then
		local q=p:Clone()
		for _,child in q:GetChildren()do
			if not(child:IsA('DataModelMesh')or child:IsA('SurfaceAppearance')or child:IsA('Texture')or child:IsA('Decal'))then child:Destroy()end
		end
		q.Anchored=true q.CanCollide=false q.CanTouch=false q.CanQuery=false
		if q.Material==Enum.Material.Neon then q.Material=Enum.Material.SmoothPlastic q.Color=Color3.fromRGB(92,178,190)end
		q.Parent=model
	end
end
model:SetAttribute('SourceAssetId','13782728612')model.Parent=lib
return #model:GetDescendants()
