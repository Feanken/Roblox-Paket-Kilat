-- Clean Creator Store templates only. No vendor scripts/interactive vehicles.
local m=workspace.PaketKilat.Map local y=m.DepotPad.Position.Y+1
assert(not m:FindFirstChild('CityDecor15'),'CityDecor15 exists')
local f=Instance.new('Folder')f.Name='CityDecor15'f.Parent=m
local assets=game.ServerStorage.PaketKilat_CreatorAssets15
local old=game.ServerStorage.PaketKilat_CreatorAssets07
local function place(template,name,x,z,height,angle)
 local model=template:Clone()model.Name=name
 for _,p in ipairs(model:GetDescendants())do
  assert(not p:IsA('LuaSourceContainer'),'Template contains code')
  if p:IsA('BasePart')then p.Anchored=true p.CanCollide=false p.CanTouch=false p.CanQuery=false end
 end
 local _,s=model:GetBoundingBox()model:ScaleTo(model:GetScale()*height/s.Y)
 model:PivotTo(CFrame.new(x,y,z)*CFrame.Angles(0,math.rad(angle or 0),0))
 local cf,size=model:GetBoundingBox()model:PivotTo(model:GetPivot()+Vector3.new(0,y-(cf.Position.Y-size.Y/2),0))
 model.Parent=f return model
end
place(assets.FoodCart,'MarketFoodCart',85,124,7.2,90)
place(assets.FoodCart,'ParkFoodCart',40,-8,7.2,0)
place(assets.PicnicTable,'ParkPicnic',65,1,4.4,0)
place(assets.PicnicTable,'GardenPicnic',-62,113,4.4,90)
for i,p in ipairs({{29,1,90},{-50,115,90},{120,78,0},{-118,72,180}})do place(old.ParkBench,'Bench'..i,p[1],p[2],2.9,p[3])end
for i,p in ipairs({{-124,-13},{-67,-14},{-38,-15},{26,-17},{59,-17},{80,-17},{126,-12},{-122,62},{-118,127},{-80,126},{-47,126},{128,58},{127,86},{24,85},{-78,89},{92,12}})do
 place(old.BroadleafTree,'ShadeTree'..i,p[1],p[2],i%3==0 and 15 or 12,i*37)
end
-- Short garden fence groups frame the seating; open approaches stay unobstructed.
for i,p in ipairs({{-76,105,0},{-76,121,0},{77,-9,90},{77,6,90}})do place(old.WoodFence,'GardenFence'..i,p[1],p[2],2.4,p[3])end
workspace.PaketKilat:SetAttribute('DecorRevision','CreatorCity15')
return {models=#f:GetChildren()}
