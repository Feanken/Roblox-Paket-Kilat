-- Edit-only normalization and foot sampling. Restores model bottom to SupportY35; mutates vertical pivots.
local root=workspace.PaketKilat.Map.Districts35 local out={}
for _,m in root.StreetDetails:GetDescendants()do if m:IsA("Model")and m:GetAttribute("PublicRealm35")then
 local support=m:GetAttribute("SupportY35")local box,sz=m:GetBoundingBox()m:PivotTo(m:GetPivot()+Vector3.new(0,support-(box.Position.Y-sz.Y/2),0))local low=math.huge
 for _,p in m:GetDescendants()do if p:IsA("BasePart")then
  p.CanQuery=true local minX,maxX,minY,minZ,maxZ=math.huge,-math.huge,math.huge,math.huge,-math.huge
  for _,x in {-1,1}do for _,y in {-1,1}do for _,z in {-1,1}do
   local v=p.CFrame:PointToWorldSpace(p.Size*Vector3.new(x,y,z)/2)
   minX=math.min(minX,v.X)maxX=math.max(maxX,v.X)minY=math.min(minY,v.Y)minZ=math.min(minZ,v.Z)maxZ=math.max(maxZ,v.Z)
  end end end
  if minY<support+.15 then
   local params=RaycastParams.new()params.FilterType=Enum.RaycastFilterType.Include params.FilterDescendantsInstances={p}
   for i=0,16 do for j=0,16 do
    local hit=workspace:Raycast(Vector3.new(minX+(maxX-minX)*i/16,support-.05,minZ+(maxZ-minZ)*j/16),Vector3.new(0,3,0),params)
    if hit then low=math.min(low,hit.Position.Y)end
   end end
  end
  p.CanQuery=false
 end end
 local gap=low<math.huge and low-support or -999
 m:SetAttribute("MeshFootGap35",gap)
 if math.abs(gap)>.08 then table.insert(out,{name=m.Name,gap=gap})end task.wait()
end end
return game.HttpService:JSONEncode(out)