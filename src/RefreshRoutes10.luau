-- Edit maintenance after owner's street changes. Does not restore deleted bypass roads.
local w=workspace.PaketKilat local map=w.Map local roads=map.Expansion.Roads
local depot=map.Depot.PickupPoint.Position local origin=map.DepotPad.Position
local frontZ=map.SafeRoadAcross.Position.Z local rearZ=roads.MarketStreet.Position.Z
local spine=roads.NorthStreet local spineX=spine.Position.X
-- Close the small connection gap along the existing central street corridor.
spine.Position=Vector3.new(spineX,spine.Position.Y,(frontZ+rearZ)/2)
spine.Size=Vector3.new(spine.Size.X,spine.Size.Y,math.abs(rearZ-frontZ))
local module=game.ReplicatedStorage.PaketKilat.Shared.SafeRoutes08
module:Clone().Parent=game.ServerStorage.PaketKilat_PrePolish10
local lines={"-- Current map routes. General guidance, not a guarantee of no hazards.","return {"}
local function vec(p) local d=p-depot return string.format("Vector3.new(%.4f,0,%.4f)",d.X,d.Z) end
for i=1,5 do
 local id=string.format("Rumah%02d",i) local target=map[id].DestinationPoint.Position
 local points={depot,Vector3.new(origin.X,depot.Y,frontZ)}
 if target.Z>(frontZ+rearZ)/2 then
  table.insert(points,Vector3.new(spineX,depot.Y,frontZ))
  local bypass=roads:FindFirstChild("BarrierBypassWest")
  if bypass and bypass.CanCollide then
   local south=roads.BarrierBypassSouth.Position.Z local north=roads.BarrierBypassNorth.Position.Z
   for _,pt in ipairs({{spineX,south},{bypass.Position.X,south},{bypass.Position.X,north},{spineX,north}}) do table.insert(points,Vector3.new(pt[1],depot.Y,pt[2])) end
  end
  table.insert(points,Vector3.new(spineX,depot.Y,rearZ))
  table.insert(points,Vector3.new(target.X,depot.Y,rearZ))
 else table.insert(points,Vector3.new(target.X,depot.Y,frontZ)) end
 table.insert(points,target)
 local values={} for _,pt in ipairs(points) do table.insert(values,vec(pt)) end
 table.insert(lines,id.."={"..table.concat(values,",").."},")
end
table.insert(lines,"}") module.Source=table.concat(lines,"\n")
if not roads:FindFirstChild("BarrierBypassWest") then
 local sign=map.Expansion.Decor:FindFirstChild("BypassSign")
 if sign then sign.Parent=game.ServerStorage.PaketKilat_PrePolish10 end
 for _,v in ipairs(map.Wayfinding06:GetChildren()) do
  if v:IsA("BasePart") and math.abs((v.Position-origin).X+35)<.05 then
   local y=v.Position.Y v.Position=Vector3.new(spineX-spine.Size.X/2+1,y,origin.Z+47)
   for _,t in ipairs(v:GetDescendants()) do if t:IsA("TextLabel") then
    t.Text=t.Text=="JALUR AMAN" and "AWAS PENGHALANG" or "Tunggu celah, lalu lanjut"
   end end
  end
 end
end
w:SetAttribute("RouteRevision","CurrentStreets10")
return {bypassRetained=roads:FindFirstChild("BarrierBypassWest")~=nil,spineLength=spine.Size.Z}
