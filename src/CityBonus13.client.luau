-- Local station presentation; all claims and rewards are server-owned.
local player=game.Players.LocalPlayer
local stations=workspace:WaitForChild('PaketKilat'):WaitForChild('Map'):WaitForChild('City13'):WaitForChild('Stations')
game.ReplicatedStorage:WaitForChild('PaketKilat').Remotes.StateChanged.OnClientEvent:Connect(function(s)
 local b=s.routeBonus
 for _,p in ipairs(stations:GetChildren())do
  local claimed=b and b.visited[p.Name]
  local active=s.status=='Carrying'and b and b.count<b.limit and not claimed
  p.Transparency=active and .1 or .75
  local gui=p:FindFirstChildOfClass('BillboardGui')local label=gui and gui:FindFirstChildOfClass('TextLabel')
  if label then label.Text=claimed and 'CAP TERKUMPUL' or active and 'POS BONUS · LEWATI' or 'POS BONUS'label.TextColor3=active and Color3.fromRGB(249,197,81)or Color3.fromRGB(225,213,185)end
 end
end)
