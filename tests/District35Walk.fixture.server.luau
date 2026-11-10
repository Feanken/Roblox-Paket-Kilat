local player=game.Players:GetPlayers()[1]local original=player.Character local arch=original.Archivable original.Archivable=true
local rig=original:Clone()original.Archivable=arch rig.Name="TemporaryDistrict35Walker"
for _,v in rig:GetDescendants()do if v:IsA("LuaSourceContainer")then v:Destroy()end end
rig.Parent=workspace
for _,v in rig:GetDescendants()do if v:IsA("BasePart")and not v.Anchored then pcall(function()v:SetNetworkOwner(nil)end)end end
local ok,result=xpcall(function()
 local h=rig:FindFirstChildOfClass("Humanoid")local hr=rig.HumanoidRootPart local b=workspace.PaketKilat.Map.DepotPad.CFrame local out={}
 local tests={{"BridgeRoad",-122,144,-187,144},{"DiagonalSouth",-190,118,-268,174},{"DiagonalMiddle",-268,174,-343,228},{"DiagonalNorth",-343,228,-417,282},{"QuayWestSeam",-423,114,-423,205},{"ShopFront",-358.2,114,-358.2,128.7}}
 for _,s in tests do
  rig:PivotTo(b*CFrame.new(s[2],4,s[3]))hr.AssemblyLinearVelocity=Vector3.zero hr.AssemblyAngularVelocity=Vector3.zero task.wait(.35)
  local target=b:PointToWorldSpace(Vector3.new(s[4],4,s[5]))h:MoveTo(target)local start=os.clock()local reached=false
  repeat task.wait(.1)reached=Vector2.new(hr.Position.X-target.X,hr.Position.Z-target.Z).Magnitude<2 until reached or os.clock()-start>7
  local at=b:PointToObjectSpace(hr.Position)table.insert(out,{name=s[1],reached=reached,elapsed=os.clock()-start,localPosition={at.X,at.Y,at.Z},health=h.Health,material=h.FloorMaterial.Name})
 end
 return out
end,debug.traceback)
rig:Destroy()if not ok then error(result)end
return game.HttpService:JSONEncode(result)