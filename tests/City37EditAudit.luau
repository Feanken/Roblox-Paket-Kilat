-- Final Edit audit: attached art never changes floors or gameplay anchors.
local map=workspace.PaketKilat.Map local root=map.City37
local snap=game.HttpService:JSONDecode(game.ServerStorage.PaketKilat_PreCity37.Snapshot.Value)
local function find(path)local p=game for name in string.gmatch(path,"[^%.]+")do p=p and p:FindFirstChild(name)end return p end
local out={anchors={},models={},art={models=0,parts=0,bad={},mesh=0},hud=game.StarterGui.PaketKilatUI.Enabled}
for _,a in snap.anchors do local p=find(a.path)local cf=CFrame.new(table.unpack(a.cf))table.insert(out.anchors,{path=a.path,positionDelta=(p.Position-cf.Position).Magnitude,sizeDelta=(p.Size-Vector3.new(table.unpack(a.size))).Magnitude})end
for _,a in snap.models do local p=find(a.path)local cf=CFrame.new(table.unpack(a.cf))table.insert(out.models,{path=a.path,positionDelta=(p.Position-cf.Position).Magnitude,sizeDelta=(p.Size-Vector3.new(table.unpack(a.size))).Magnitude})end
for _,ref in root.ArtReferences:GetChildren()do
 local m=ref.Value out.art.models+=1
 if not m or not m.Parent then table.insert(out.art.bad,"Missing reference "..ref.Name)continue end
 for _,p in m:GetDescendants()do
  if p:IsA("BasePart")then out.art.parts+=1 if p.CanCollide or p.CanQuery or p.CanTouch or not p.Anchored then table.insert(out.art.bad,p:GetFullName())end end
  if p:IsA("DataModelMesh")then out.art.mesh+=1 end
  if p:IsA("LuaSourceContainer")or p:IsA("Light")then table.insert(out.art.bad,p:GetFullName())end
 end
end
out.runtimeResidue=workspace:FindFirstChild("PaketKilatLocalResidents37")~=nil
out.oldControllerActive=game.StarterPlayer.StarterPlayerScripts:FindFirstChild("PaketKilatCityLife15")~=nil
out.oldControllerArchived=game.ServerStorage.PaketKilat_PreCity37:FindFirstChild("PaketKilatCityLife15")~=nil
out.totalCandidates=#map.City36.FutureAddresses:GetChildren()+#map.Districts35.FutureAddresses:GetChildren()
return game.HttpService:JSONEncode(out)