-- Edit-only after P03. Operate on the owner's currently used Studio session.
local w=workspace.PaketKilat local map=w.Map local o=map.DepotPad.Position
assert(map:FindFirstChild("Polish03"),"Apply front-street revision first")
assert(game.ServerStorage:FindFirstChild("PaketKilat_PrePolish04"),"Backup first")
assert(not map:FindFirstChild("Polish04"),"Already applied")
local folder=Instance.new("Folder") folder.Name="Polish04" folder.Parent=map
-- Replace the *material* of the supporting depot slab, with a flush tiled finish.
-- No grass remains underneath the entrance/shelves; dimensions and top height remain unchanged.
map.DepotPad.Material=Enum.Material.Concrete
map.DepotPad.Color=Color3.fromRGB(211,201,179)
local function part(name,size,pos,color,material,collide)
 local p=Instance.new("Part") p.Name=name p.Size=size p.Position=o+pos
 p.Anchored=true p.CanCollide=collide==true p.CanTouch=false p.CanQuery=collide==true
 p.Color=color p.Material=material p.TopSurface=Enum.SurfaceType.Smooth p.BottomSurface=Enum.SurfaceType.Smooth p.Parent=folder return p
end
part("DepotTileFloor",Vector3.new(17,.08,13),Vector3.new(0,1.045,-6),Color3.fromRGB(235,226,207),Enum.Material.CeramicTiles,false)
-- Low-contrast grout grid reinforces the floor rather than leaving grass through the walls.
for x=-8,8,2 do part("TileJoint",Vector3.new(.025,.012,12.8),Vector3.new(x,1.09,-6),Color3.fromRGB(191,180,157),Enum.Material.SmoothPlastic,false) end
for z=-12,0,2 do part("TileJoint",Vector3.new(16.8,.012,.025),Vector3.new(0,1.09,z),Color3.fromRGB(191,180,157),Enum.Material.SmoothPlastic,false) end
-- Match each old tree by its original X/Z, including duplicates with the same name.
local trees={
 {16,12,10,10}, {-114,128,-110,128}, {114,128,110,128},
 {-65,43,-108,9}, {24,144,-9,112},
}
local gardenTargets={
 {map.DepotPad,10,10}, {map.Rumah05.HousePad5,-8,8},
 {map.Rumah04.HousePad4,8,8}, {map.Rumah02.HousePad2,-8,8}, {map.Rumah03.HousePad3,-8,0},
}
for i,t in ipairs(trees) do
 local garden=gardenTargets[i] local center=garden[1].Position-o
 t[3],t[4]=center.X+garden[2],center.Z+garden[3]
end
local used={}
for _,t in ipairs(trees) do
 local trunk,best=nil,math.huge
 for _,v in ipairs(map.Expansion.Decor:GetChildren()) do
  if v:IsA("BasePart") and v.Name=="TreeTrunk" and not used[v] then
   local pos=v.Position-o local distance=Vector2.new(pos.X-t[1],pos.Z-t[2]).Magnitude
   if distance<best then trunk,best=v,distance end
  end
 end
 assert(trunk and best<30,"Tree was edited beyond expected garden; inspect first")
 used[trunk]=true
 local old=trunk.Position-o local patch,crown
 for _,v in ipairs(map.Expansion.Decor:GetChildren()) do
  if v:IsA("BasePart") then
   local pos=v.Position-o
   if math.abs(pos.X-old.X)<.05 and math.abs(pos.Z-old.Z)<.05 then
    if v.Name=="TreePatch" then patch=v elseif v.Name=="TreeCrown" then crown=v end
   end
  end
 end
 assert(crown,"Tree crown missing")
 local delta=Vector3.new(t[3]-old.X,0,t[4]-old.Z)
 trunk.Position+=delta crown.Position+=delta
 if not patch then
  patch=part("TreePatch",Vector3.new(7.8,.06,7.8),Vector3.new(t[3],1.05,t[4]),Color3.fromRGB(111,146,89),Enum.Material.Grass,false)
  patch.Parent=map.Expansion.Decor
 end
 patch.Size=Vector3.new(7.8,.06,7.8) patch.Position=o+Vector3.new(t[3],1.05,t[4])
 patch.CanCollide=false patch.CanTouch=false patch.CanQuery=false patch.Material=Enum.Material.Grass patch.Color=Color3.fromRGB(111,146,89)
end
-- Foundation for remaining yards: these align to the old 28x28 support pads.
-- P03 supplies houses02–05 and P01 depot/house01, so no detached tree islands remain.
w:SetAttribute("GroundRevision","Polish04")
return "Tiled depot and five supported garden trees installed"
