-- Displays the exhibition according to this player's completed story chapters.
local shared = game.ReplicatedStorage:WaitForChild("PaketKilat")
local remotes = shared:WaitForChild("Remotes")
local map = workspace:WaitForChild("PaketKilat"):WaitForChild("Map")
local exhibits = map:WaitForChild("GalleryExhibit55")
local opened = false

local function apply(frame)
	if not frame:IsA("Frame") then return end
	local gui = frame.Parent
	if not gui or gui.Name ~= "GalleryDisplay" then return end
	if frame.Name == "Covered" then
		frame.Visible = not opened
	elseif frame.Name == "Exhibit" then
		frame.Visible = opened
	end
end

local added = exhibits.DescendantAdded:Connect(apply)
local state = remotes.StateChanged.OnClientEvent:Connect(function(snapshot)
	local story = snapshot.story
	local show = snapshot.profileReady == true and story ~= nil and story.completed == story.total
	if show == opened then return end
	opened = show
	for _, frame in ipairs(exhibits:GetDescendants()) do apply(frame) end
end)

for _, frame in ipairs(exhibits:GetDescendants()) do apply(frame) end
task.delay(1.35, function()
	if script.Parent then remotes.ActionRequest:FireServer("Sync") end
end)
script.Destroying:Connect(function()
	state:Disconnect()
	added:Disconnect()
end)
