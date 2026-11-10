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
 return {count=d.count,limit=d.limit,total=d.count*d.reward,visited=table.clone(d.visited)}
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