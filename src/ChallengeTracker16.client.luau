-- Snapshot-only challenge HUD; no reward/claim remote.
local player=game.Players.LocalPlayer
local root=player:WaitForChild('PlayerGui'):WaitForChild('PaketKilatUI'):WaitForChild('Root')
local shared=game.ReplicatedStorage:WaitForChild('PaketKilat')
local theme=require(shared.Shared.UITheme12)
local frame=Instance.new('Frame')frame.Name='SessionChallenge16'frame.AnchorPoint=Vector2.new(.5,0)frame.BackgroundColor3=theme.Cream frame.BorderSizePixel=0 frame.Visible=false frame.Parent=root
local corner=Instance.new('UICorner')corner.CornerRadius=UDim.new(0,14)corner.Parent=frame
local stroke=Instance.new('UIStroke')stroke.Color=theme.Line stroke.Parent=frame
local function label(name,y,h,size,color)
 local l=Instance.new('TextLabel')l.Name=name l.Position=UDim2.fromOffset(12,y)l.Size=UDim2.new(1,-24,0,h)l.BackgroundTransparency=1 l.TextColor3=color l.Font=Enum.Font.GothamBold l.TextSize=size l.TextWrapped=true l.TextXAlignment=Enum.TextXAlignment.Left l.Parent=frame return l
end
local title=label('Title',9,15,10,theme.Muted)
local goal=label('Goal',27,28,12,theme.Ink)
local progress=label('Progress',61,16,10,theme.Muted)
local track=Instance.new('Frame')track.Name='Track'track.Position=UDim2.new(0,12,1,-9)track.Size=UDim2.new(1,-24,0,3)track.BackgroundColor3=theme.Line track.BorderSizePixel=0 track.Parent=frame
local fill=track:Clone()fill.Name='Fill'fill.Position=UDim2.fromOffset(0,0)fill.Size=UDim2.fromScale(0,1)fill.BackgroundColor3=theme.Gold fill.Parent=track
local state
local function render()
 local compact=root.AbsoluteSize.Y<500
 frame.Size=UDim2.fromOffset(compact and 180 or 300,90)frame.Position=UDim2.new(.5,0,0,compact and 12 or 20)
 local toast=root:FindFirstChild('DeliveryCelebration')
 frame.Visible=state~=nil and not root.Shop.Visible and not(toast and toast.Visible)
 if not state then return end
 title.Text=state.complete and 'TARGET SESI · SELESAI'or string.format('TARGET SESI %d/%d',state.index,state.count)
 goal.Text=state.description
 progress.Text=state.complete and 'Hebat! Semua target tercapai.'or string.format('%d/%d selesai · hadiah +%d',state.progress,state.target,state.reward)
 fill.Size=UDim2.fromScale(math.clamp(state.progress/state.target,0,1),1)
end
shared.Remotes.StateChanged.OnClientEvent:Connect(function(s)state=s.profileReady and s.challenge or nil render()end)
root:GetPropertyChangedSignal('AbsoluteSize'):Connect(render)
local elapsed=0 game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed+=dt if elapsed>=.1 then elapsed=0 render()end end)