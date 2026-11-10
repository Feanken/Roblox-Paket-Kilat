-- Read-only City32 geometry and route audit; safe in Edit.
local map=workspace.PaketKilat.Map local root=map.City32 local basis=map.DepotPad.CFrame
local out={parts=0,meshParts=0,unanchored={},colliders={},touchable={},queryable={},code={},constraints={},lights=0,routeReview={},roofSupports={},ground={},labels={}}
local routes={
 {{-2,-6},{0,28},{98,28},{98,3}},
 {{-2,-6},{0,28},{-102,28},{-102,3}},
 {{-2,-6},{0,28},{-24,28},{-24,144},{-5,144},{-5,114}},
 {{-2,-6},{0,28},{-24,28},{-24,144},{108,144},{108,114}},
 {{-2,-6},{0,28},{-24,28},{-24,144},{-102,144},{-102,114}},
}
local function rect(p)
 local cf=basis:ToObjectSpace(p.CFrame)local s=p.Size/2 local r,u,l=cf.RightVector,cf.UpVector,cf.LookVector
 local ex=math.abs(r.X)*s.X+math.abs(u.X)*s.Y+math.abs(l.X)*s.Z
 local ez=math.abs(r.Z)*s.X+math.abs(u.Z)*s.Y+math.abs(l.Z)*s.Z
 local ey=math.abs(r.Y)*s.X+math.abs(u.Y)*s.Y+math.abs(l.Y)*s.Z
 return cf.Position.X-ex,cf.Position.X+ex,cf.Position.Z-ez,cf.Position.Z+ez,cf.Position.Y-ey,cf.Position.Y+ey
end
local function boxSeg(x1,x2,z1,z2,a,b)
 -- All safe route segments are axis aligned except the short depot lead-in.
 local best=math.huge
 for i=0,60 do
  local t=i/60 local x=a[1]+(b[1]-a[1])*t local z=a[2]+(b[2]-a[2])*t
  local dx=math.max(x1-x,0,x-x2)local dz=math.max(z1-z,0,z-z2)
  best=math.min(best,math.sqrt(dx*dx+dz*dz))
 end
 return best
end
local minRoute=math.huge
for _,p in root:GetDescendants()do
 if p:IsA("LuaSourceContainer")then table.insert(out.code,p:GetFullName())end
 if p:IsA("Constraint")or p:IsA("JointInstance")then table.insert(out.constraints,p:GetFullName())end
 if p:IsA("Light")then out.lights+=1 end
 if p:IsA("TextLabel")then table.insert(out.labels,{text=p.Text,fits=p.TextFits,face=p.Parent.Face.Name})end
 if p:IsA("BasePart")then
  out.parts+=1 if p:IsA("MeshPart")then out.meshParts+=1 end
  if not p.Anchored then table.insert(out.unanchored,p:GetFullName())end
  if p.CanCollide then table.insert(out.colliders,p:GetFullName())end
  if p.CanTouch then table.insert(out.touchable,p:GetFullName())end
  if p.CanQuery then table.insert(out.queryable,p:GetFullName())end
  local top=p;while top.Parent~=root do top=top.Parent end
  local attached=top==root.HouseEntries or string.find(top.Name,"_Details")or top.Name=="BengkelWorkshop"
  local x1,x2,z1,z2,y1,y2=rect(p)
  if not attached and y1<7 and y2>1.3 then
   local nearest=math.huge
   for _,route in routes do for i=2,#route do nearest=math.min(nearest,boxSeg(x1,x2,z1,z2,route[i-1],route[i]))end end
   minRoute=math.min(minRoute,nearest)
   if nearest<4 then table.insert(out.routeReview,{name=p:GetFullName(),distance=nearest})end
  end
 end
 if p:IsA("Model")and p:GetAttribute("SupportY32")then table.insert(out.ground,{name=p:GetFullName(),gap=p:GetAttribute("SupportGap32")})end
end
out.minimumRouteClearance=minRoute
for _,name in {"TOKO ROTI","RUMAH SUSUN","BENGKEL","TOKO BUKU","KANTOR KAMPUNG"}do
 local roof=map.City13[name].Roof local base=root[name.."_Details"].RoofVentBase
 local roofTop=roof.Position.Y+roof.Size.Y/2
 table.insert(out.roofSupports,{name=name,gap=base.Position.Y-base.Size.Y/2-roofTop})
end
out.mapRevision=workspace.PaketKilat:GetAttribute("CityRevision")
return game.HttpService:JSONEncode(out)
