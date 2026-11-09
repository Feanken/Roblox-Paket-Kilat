-- Edit geometry support audit. Gameplay markers, houses and raised planter foliage stay in place.
local map=workspace.PaketKilat.Map local ground=map.Surface15:GetAttribute('SurfaceY')
local rp=RaycastParams.new()rp.FilterType=Enum.RaycastFilterType.Include
local results={}local queryState={}
local function partsOf(model)
 local list={}if model:IsA('BasePart')then table.insert(list,model)end
 for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')and p.Transparency<.95 then table.insert(list,p)end end
 return list
end
local groups={map.CreatorStore07,map.Landscape09,map.DepotParcels10,map.CityDecor15}
for _,folder in ipairs(groups)do for _,m in ipairs(folder:GetChildren())do for _,p in ipairs(partsOf(m))do queryState[p]=p.CanQuery p.CanQuery=true end end end
task.wait(.2)
for _,folder in ipairs(groups)do
 for _,m in ipairs(folder:GetChildren())do
  local parts=partsOf(m)
  if #parts>0 then
   local cf,size
   if m:IsA('Model')then cf,size=m:GetBoundingBox()else cf,size=m.CFrame,m.Size end
   local ex=math.abs(cf.RightVector.X)*size.X/2+math.abs(cf.UpVector.X)*size.Y/2+math.abs(cf.LookVector.X)*size.Z/2
   local ez=math.abs(cf.RightVector.Z)*size.X/2+math.abs(cf.UpVector.Z)*size.Y/2+math.abs(cf.LookVector.Z)*size.Z/2
   local pitch=math.max(.15,math.max(ex,ez)*2/40)
   rp.FilterDescendantsInstances=parts
   local low=math.huge local hits=0 local count=0
   for x=cf.Position.X-ex,cf.Position.X+ex,pitch do
    for z=cf.Position.Z-ez,cf.Position.Z+ez,pitch do
     local h=workspace:Raycast(Vector3.new(x,ground-2,z),Vector3.new(0,30,0),rp)
     if h then low=math.min(low,h.Position.Y)hits+=1 end count+=1
     if count%1000==0 then task.wait()end
    end
   end
   local planted=m.Name:find('PottedShrub')~=nil or(folder.Name=='DepotParcels10'and(m.Name=='ParcelDisplay3'or m.Name=='ParcelDisplay4'))
   local gap=low~=math.huge and low-ground or nil local delta=0
   if gap and not planted and gap>.06 and gap<1.5 then delta=-gap-.015 m:PivotTo(m:GetPivot()+Vector3.new(0,delta,0))end
   table.insert(results,{group=folder.Name,name=m.Name,samples=count,hits=hits,beforeGap=gap,offsetY=delta,afterGap=gap and gap+delta,planterException=planted,review=not planted and(not gap or gap>=1.5)})
   task.wait()
  end
 end
end
for p,value in pairs(queryState)do if p.Parent then p.CanQuery=value end end
workspace.PaketKilat:SetAttribute('PropGroundRevision','GeometryFeet18')
return game.HttpService:JSONEncode(results)
