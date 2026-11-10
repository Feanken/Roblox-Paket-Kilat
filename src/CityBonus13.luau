-- Server-owned optional route stamps. No client claim/reward remote.
local B={}
local tuning=require(script.Parent.MovementTuning)
local function data(o)
 if not o then return nil end
 if not o.cityBonus then
  local t=tuning.Get()
  o.cityBonus={visited={},count=0,limit=math.floor(t.CityStampLimit),reward=math.floor(t.CityStampReward),radius=t.CityStampRadius}
 end
 return o.cityBonus
end
function B.Snapshot(o)
 local d=data(o)if not d then return nil end
 return {count=d.count,limit=d.limit,total=d.count*d.reward,radius=d.radius,visited=table.clone(d.visited)}
end
function B.Navigation(world)
 local map=world.Map local pickup=map.Depot.PickupPoint.Position local basis=map.DepotPad.CFrame.Rotation
 local stations={}
 for _,p in ipairs(map.City13.Stations:GetChildren())do
  if p:IsA('BasePart')then table.insert(stations,{id=p.Name,position=p.Position})end
 end
 table.sort(stations,function(a,b)return a.id<b.id end)
 local paths={}
 local bridge=map.City13:FindFirstChild('PedestrianBridge')
 local west=map.City13:FindFirstChild('WestRamp')local east=map.City13:FindFirstChild('EastRamp')
 if bridge and west and east then
  local function endpoints(ramp)
   local a=ramp.CFrame:PointToWorldSpace(Vector3.new(0,ramp.Size.Y/2,-ramp.Size.Z/2))
   local b=ramp.CFrame:PointToWorldSpace(Vector3.new(0,ramp.Size.Y/2,ramp.Size.Z/2))
   if a.Y>b.Y then a,b=b,a end
   b=Vector3.new(b.X,bridge.Position.Y+bridge.Size.Y/2,b.Z)
   return a,b
  end
  local wl,wh=endpoints(west)local el,eh=endpoints(east)
  table.insert(paths,{wl,wh,eh,el})
  for _,foot in ipairs({wl,el})do
   local offset=basis:VectorToObjectSpace(foot-pickup)
   local side=pickup+basis:VectorToWorldSpace(Vector3.new(offset.X,0,offset.Z+6))
   local street=pickup+basis:VectorToWorldSpace(Vector3.new(-22,0,offset.Z+6))
   table.insert(paths,{foot,side,street})
  end
 end
 return {stations=stations,paths=paths}
end
function B.Reward(o)local d=data(o)return d and d.count*d.reward or 0 end
function B.Start(D,E,world)
 local stations=world.Map:WaitForChild('City13'):WaitForChild('Stations')
 task.spawn(function()
  while task.wait(.2)do
   for _,player in ipairs(game.Players:GetPlayers())do
    local o=D.orders[player.UserId]
    local char=player.Character local root=char and char:FindFirstChild('HumanoidRootPart')
    local hum=char and char:FindFirstChildOfClass('Humanoid')
    if o and o.status=='Carrying'and not o.completionLocked and E.Has(player)and root and hum and hum.Health>0 then
     local d=data(o)
     if d.count<d.limit then
      for _,station in ipairs(stations:GetChildren())do
       if not d.visited[station.Name]and(root.Position-station.Position).Magnitude<=d.radius then
        d.visited[station.Name]=true d.count+=1 D.Publish(player,'CityStamp')break
       end
      end
     end
    end
   end
  end
 end)
end
return B
