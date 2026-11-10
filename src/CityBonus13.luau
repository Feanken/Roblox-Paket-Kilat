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
 local crossing=map:FindFirstChild("City34")
 local nodes=crossing and crossing:FindFirstChild("WalkNodes")
 if nodes then
  local line={}for _,name in {"Node1","Node2","Node3"}do local p=nodes:FindFirstChild(name)if p then table.insert(line,p.Position)end end
  if #line>=2 then table.insert(paths,line)end
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
