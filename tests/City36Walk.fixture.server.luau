-- Play-only segmented humanoid fixture. No profile or delivery writes.
local player=game.Players:GetPlayers()[1]assert(player and player.Character)
local original=player.Character local arch=original.Archivable original.Archivable=true
local rig=original:Clone()original.Archivable=arch rig.Name="TemporaryCity36Walker"
for _,v in rig:GetDescendants()do if v:IsA("LuaSourceContainer")then v:Destroy()end end
rig.Parent=workspace
for _,v in rig:GetDescendants()do if v:IsA("BasePart")and not v.Anchored then pcall(function()v:SetNetworkOwner(nil)end)end end
local ok,res=xpcall(function()
 local h=rig:FindFirstChildOfClass("Humanoid")local hr=rig.HumanoidRootPart local b=workspace.PaketKilat.Map.DepotPad.CFrame local out={}
 for _,s in {{"WestLoop",-130,35,-130,135},{"WestTurn",-130,134,-104,144},{"EastLoop",132,36,132,132},{"EastTurn",132,130,110,144},{"BookshopAccess",-90,28,-90,44},{"NewPostShop",-7.32,28,-7.32,43.2},{"QuayDiagonal",-268,174,-343,228},{"CivicKiosk",-12,282,-15.24,293.7},{"ShopPad",-8,12,-8,4},{"DepotPickup",-2,4,-2,-6}}do
  rig:PivotTo(b*CFrame.new(s[2],4,s[3]))hr.AssemblyLinearVelocity=Vector3.zero hr.AssemblyAngularVelocity=Vector3.zero task.wait(.3)
  local target=b:PointToWorldSpace(Vector3.new(s[4],4,s[5]))h:MoveTo(target)
  local time=os.clock()local reached=false
  repeat task.wait(.1)reached=Vector2.new(hr.Position.X-target.X,hr.Position.Z-target.Z).Magnitude<1.6 until reached or os.clock()-time>7.5
  local v=b:PointToObjectSpace(hr.Position)table.insert(out,{name=s[1],reached=reached,elapsed=os.clock()-time,health=h.Health,localPosition={v.X,v.Y,v.Z},material=h.FloorMaterial.Name})
 end return out
end,debug.traceback)
rig:Destroy()if not ok then error(res)end return game.HttpService:JSONEncode(res)