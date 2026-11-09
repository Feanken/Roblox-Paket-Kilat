-- Edit migration after clean templates are installed. Stall categories use distinct free props.
local map=workspace.PaketKilat.Map local city=map.City13 local y=map.Surface15:GetAttribute('SurfaceY')
assert(not map:FindFirstChild('MarketGoods18'),'MarketGoods18 already exists')
local folder=Instance.new('Folder')folder.Name='MarketGoods18'folder.Parent=map
local assets=game.ServerStorage.PaketKilat_MarketAssets18
local counters={}
for _,p in ipairs(city:GetChildren())do if p:IsA('BasePart')and p.Name=='MarketCounter'then table.insert(counters,p)end end
table.sort(counters,function(a,b)return map.DepotPad.CFrame:PointToObjectSpace(a.Position).X<map.DepotPad.CFrame:PointToObjectSpace(b.Position).X end)
assert(#counters==3,'Expected three market counters')
for _,p in ipairs(city:GetChildren())do
 if p.Name=='ProduceCrate'then p.Transparency=1 p.CanCollide=false p.CanQuery=false end
 if p:IsA('BasePart')and p.Name=='MarketAwning'then
  local label=p:FindFirstChildWhichIsA('TextLabel',true)
  if label then
   local closest,index=math.huge,1
   for i,counter in ipairs(counters)do local d=(counter.Position-p.Position).Magnitude if d<closest then closest,index=d,i end end
   label.Text=({'ROTI HANGAT','SAYUR SEGAR','BUAH SEGAR'})[index]
  end
 end
end
local function place(template,name,counter,x,z,height,angle,flat)
 local m=template:Clone()m.Name=name
 local _,s=m:GetBoundingBox()m:ScaleTo(m:GetScale()*height/s.Y)
 m:PivotTo(counter.CFrame.Rotation*CFrame.Angles(0,math.rad(angle or 0),0)*CFrame.Angles(flat and math.pi/2 or 0,0,0))
 local cf,size=m:GetBoundingBox()
 local ey=math.abs(cf.RightVector.Y)*size.X/2+math.abs(cf.UpVector.Y)*size.Y/2+math.abs(cf.LookVector.Y)*size.Z/2
 local at=counter.CFrame:PointToWorldSpace(Vector3.new(x,counter.Size.Y/2,z))
 m:PivotTo(m:GetPivot()+Vector3.new(at.X-cf.Position.X,at.Y-(cf.Position.Y-ey),at.Z-cf.Position.Z))
 m:SetAttribute('Stall',counter==counters[1]and 'Bread'or counter==counters[2]and 'Vegetables'or 'Fruit')
 m.Parent=folder return m
end
for i,p in ipairs({{-4,-2},{1,-2},{-3,1.5},{2,1.5}})do place(assets.Bread,'Bread'..i,counters[1],p[1],p[2],1,0)end
for i,p in ipairs({{-4,-1.5},{0,-1.5},{4,-1.5},{-4,1.5},{0,1.5},{4,1.5}})do place(assets.Carrot,'Carrot'..i,counters[2],p[1],p[2],3,i%2==0 and 10 or -10,true)end
place(assets.FruitBasket,'FruitBasket',counters[3],0,-1,2,0)
for i,p in ipairs({{-5,-2},{-5,1},{5,-2},{5,1}})do place(assets.LooseFruit,'Fruit'..i,counters[3],p[1],p[2],1.1,i*90)end
workspace.PaketKilat:SetAttribute('MarketRevision','DistinctStalls18')
return {models=#folder:GetChildren()}
