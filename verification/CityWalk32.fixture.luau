-- Studio-only walking fixture, run manually through MCP; never installed in the game.
local player=game.Players:GetPlayers()[1]assert(player and player.Character,"Missing player")
local char=player.Character local hum=char:FindFirstChildOfClass("Humanoid")local hrp=char:FindFirstChild("HumanoidRootPart")
assert(hum and hrp,"Missing character")
local original=hrp.CFrame local b=workspace.PaketKilat.Map.DepotPad.CFrame local results={}
for _,s in {
 {"Akses taman",Vector3.new(-62,4.5,18),Vector3.new(-62,4.5,6)},
 {"Depan bengkel",Vector3.new(88,4.5,40),Vector3.new(95,4.5,48)},
 {"Lorong pasar",Vector3.new(20,4.5,116),Vector3.new(70,4.5,116)},
 {"Zebra cross",Vector3.new(47,4.5,19),Vector3.new(47,4.5,38)},
}do
 hrp.CFrame=b*CFrame.new(s[2])hrp.AssemblyLinearVelocity=Vector3.zero task.wait(.5)
 local dest=b:PointToWorldSpace(s[3])local start=hrp.Position
 hum:MoveTo(dest)local began=os.clock()local dxz=math.huge
 repeat task.wait(.15)local d=hrp.Position-dest dxz=Vector2.new(d.X,d.Z).Magnitude until dxz<1.5 or os.clock()-began>6
 local now=b:PointToObjectSpace(hrp.Position)
 table.insert(results,{name=s[1],arrived=dxz<1.5,distanceRemaining=dxz,seconds=os.clock()-began,moved=(hrp.Position-start).Magnitude,localY=now.Y,floorMaterial=hum.FloorMaterial.Name,health=hum.Health})
 hum:MoveTo(hrp.Position)task.wait(.15)
end
hrp.CFrame=original hrp.AssemblyLinearVelocity=Vector3.zero
return game.HttpService:JSONEncode(results)
