-- Edit migration. Rebuild offsets after individually moving streets/houses.
local m=workspace.PaketKilat.Map local origin=m.DepotPad.Position local depot=m.Depot.PickupPoint.Position
local module=game.ReplicatedStorage.PaketKilat.Shared:FindFirstChild("SafeRoutes08")
assert(not module,"Inspect existing navigation before rebuilding")
local lines={"-- Generated from actual map; vectors are offsets from pickup anchor.","return {"}
local function vector(p)
 local d=p-depot return string.format("Vector3.new(%.4f,0,%.4f)",d.X,d.Z)
end
for i=1,5 do
 local id=string.format("Rumah%02d",i) local dest=m[id].DestinationPoint.Position
 local target=dest-origin
 local points={depot,origin+Vector3.new(0,1,28)}
 if target.Z>60 then
  for _,p in ipairs({{-24,28},{-24,44},{-48,44},{-48,86},{-24,86},{-24,144}}) do table.insert(points,origin+Vector3.new(p[1],1,p[2])) end
  table.insert(points,origin+Vector3.new(target.X,1,144))
 else table.insert(points,origin+Vector3.new(target.X,1,28)) end
 table.insert(points,dest)
 local values={} for _,p in ipairs(points) do table.insert(values,vector(p)) end
 table.insert(lines,id.."={"..table.concat(values,",").."},")
end
table.insert(lines,"}")
module=Instance.new("ModuleScript") module.Name="SafeRoutes08" module.Source=table.concat(lines,"\n") module.Parent=game.ReplicatedStorage.PaketKilat.Shared
workspace.PaketKilat:SetAttribute("NavigationRevision","Polish08")
return module.Source
