-- Approved public benches only. No client recovery/reward command.
local R={}
local seats={} local started=false local economy
function R.IsResting(hum)
 local seat=hum and hum.SeatPart
 local root=hum and hum.Parent and hum.Parent:FindFirstChild('HumanoidRootPart')
 return seat~=nil and seats[seat]~=nil and seat.Parent==seats[seat]
  and seat.Anchored and seat.Occupant==hum and hum.Health>0 and hum.Sit
  and root~=nil and (root.Position-seat.Position).Magnitude<=8
end
function R.TrySit(player,seat)
 if not seats[seat]or seat.Parent~=seats[seat]or not seat.Anchored then return false,'UnknownBench'end
 if not economy.Has(player)then return false,'ProfileUnavailable'end
 local char=player.Character local hum=char and char:FindFirstChildOfClass('Humanoid')
 local root=char and char:FindFirstChild('HumanoidRootPart')
 if not hum or hum.Health<=0 or not root then return false,'NotAlive'end
 if(root.Position-seat.Position).Magnitude>8 then return false,'TooFar'end
 if seat.Occupant and seat.Occupant~=hum then return false,'Occupied'end
 if hum.SeatPart and hum.SeatPart~=seat then return false,'AlreadySeated'end
 seat:Sit(hum)return true,'Resting'
end
function R.Start(world,e)
 assert(not started,'Rest stops already started')started=true economy=e
 local folder=world.Map:FindFirstChild('RestStops27')if not folder then return end
 for _,seat in ipairs(folder:GetChildren())do
  if seat:IsA('Seat')and seat.Anchored then
   seats[seat]=folder
   local prompt=seat:FindFirstChildOfClass('ProximityPrompt')
   if prompt then
    prompt.Enabled=seat.Occupant==nil
    seat:GetPropertyChangedSignal('Occupant'):Connect(function()prompt.Enabled=seat.Occupant==nil end)
    prompt.Triggered:Connect(function(player)R.TrySit(player,seat)end)
   end
  end
 end
end
return R
