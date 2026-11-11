-- Displays the exhibition according to this player's completed story chapters.
local shared = game.ReplicatedStorage:WaitForChild("PaketKilat")
local remotes = shared:WaitForChild("Remotes")
local player = game:GetService("Players").LocalPlayer
local textService = game:GetService("TextService")
local theme = require(shared.Shared.UITheme12)
local root = player:WaitForChild("PlayerGui"):WaitForChild("PaketKilatUI"):WaitForChild("Root")
local map = workspace:WaitForChild("PaketKilat"):WaitForChild("Map")
local exhibits = map:WaitForChild("GalleryExhibit55")
local opened = false
local activeBoard
local pageIndex = 1

local pages = {
	{
		title = "Kampung sebelum jembatan",
		credit = "Album Bu Sari",
		description = "Sebelum ada jembatan, warga saling titip kabar di warung. Bu Sari menyimpan foto rumah dan toko yang jadi tempat singgah para kurir.",
	},
	{
		title = "Jembatan Kanal",
		credit = "Catatan Maya dan Raka",
		description = "Setelah jembatan dibuka, kurir bisa menyeberang tanpa menunggu perahu. Raka menandai jalur itu di denah, di samping foto lama yang dicatat Maya.",
	},
	{
		title = "Pintu galeri terbuka",
		credit = "Pameran warga · Galeri Tepi Air",
		description = "Undangan Bu Dewi membawa warga dari kedua sisi kanal ke galeri Nisa. Album, denah, dan bingkai yang kamu antar akhirnya dipajang bersama.",
	},
}

local overlay = Instance.new("Frame")
overlay.Name = "GalleryReader"
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = theme.Ink
overlay.BackgroundTransparency = .35
overlay.Active = true
overlay.Visible = false
overlay.ZIndex = 40
overlay.Parent = root

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(.5, .5)
panel.Position = UDim2.fromScale(.5, .5)
panel.BackgroundColor3 = theme.Cream
panel.ZIndex = 41
panel.Parent = overlay
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

local function label(name, size, font)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.BackgroundTransparency = 1
	item.TextColor3 = theme.Ink
	item.TextSize = size
	item.Font = font
	item.TextWrapped = true
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.ZIndex = 42
	item.Parent = panel
	return item
end

local title = label("Title", 19, Enum.Font.GothamBold)
local credit = label("Credit", 12, Enum.Font.GothamMedium)
local caption = label("Caption", 14, Enum.Font.GothamMedium)
local storyScroll = Instance.new("ScrollingFrame")
storyScroll.Name = "StoryText"
storyScroll.BackgroundTransparency = 1
storyScroll.BorderSizePixel = 0
storyScroll.CanvasSize = UDim2.new()
storyScroll.ScrollingDirection = Enum.ScrollingDirection.Y
storyScroll.ScrollBarThickness = 4
storyScroll.ZIndex = 42
storyScroll.Parent = panel
caption.Parent = storyScroll
local counter = label("Page", 12, Enum.Font.GothamBold)
counter.TextXAlignment = Enum.TextXAlignment.Center
local art = Instance.new("Frame")
art.Name = "Illustration"
art.BackgroundTransparency = 1
art.ClipsDescendants = true
art.ZIndex = 42
art.Parent = panel

local function button(name, captionText)
	local item = Instance.new("TextButton")
	item.Name = name
	item.Text = captionText
	item.ZIndex = 44
	item.Parent = panel
	theme.ToolbarButton(item)
	return item
end

local previous = button("Previous", "Sebelumnya")
local nextPage = button("Next", "Berikutnya")
local close = button("Close", "×")

local function layout()
	local w = math.min(480, math.max(1, root.AbsoluteSize.X - 24))
	local h = math.min(248, math.max(1, root.AbsoluteSize.Y - 12))
	local artWidth = math.floor((w - 36) * .40)
	panel.Size = UDim2.fromOffset(w, h)
	title.Position = UDim2.fromOffset(12, 7)
	title.Size = UDim2.fromOffset(w - 68, 42)
	close.Position = UDim2.fromOffset(w - 50, 5)
	close.Size = UDim2.fromOffset(44, 44)
	art.Position = UDim2.fromOffset(12, 55)
	art.Size = UDim2.fromOffset(artWidth, math.max(1, h - 115))
	credit.Position = UDim2.fromOffset(24 + artWidth, 55)
	credit.Size = UDim2.fromOffset(w - 36 - artWidth, 32)
	storyScroll.Position = UDim2.fromOffset(24 + artWidth, 87)
	storyScroll.Size = UDim2.fromOffset(w - 36 - artWidth, math.max(1, h - 147))
	caption.TextSize = w < 380 and 12 or 14
	caption.TextYAlignment = Enum.TextYAlignment.Top
	local textWidth = math.max(1, w - 44 - artWidth)
	local bounds = textService:GetTextSize(caption.Text, caption.TextSize, caption.Font, Vector2.new(textWidth, 1000))
	local textHeight = math.ceil(bounds.Y) + 4
	caption.Size = UDim2.fromOffset(textWidth, textHeight)
	storyScroll.CanvasSize = UDim2.fromOffset(0, textHeight)
	local buttonWidth = math.floor((w - 68) / 2)
	previous.Position = UDim2.fromOffset(12, h - 52)
	previous.Size = UDim2.fromOffset(buttonWidth, 44)
	nextPage.Position = UDim2.fromOffset(w - buttonWidth - 12, h - 52)
	nextPage.Size = previous.Size
	counter.Position = UDim2.fromOffset(12 + buttonWidth, h - 52)
	counter.Size = UDim2.fromOffset(w - 24 - 2 * buttonWidth, 44)
end

local function showPage(index)
	local page = pages[index]
	if not page then return end
	pageIndex = index
	title.Text, credit.Text, caption.Text = page.title, page.credit, page.description
	layout()
	storyScroll.CanvasPosition = Vector2.zero
	counter.Text = string.format("%d/%d", index, #pages)
	previous.Visible = index > 1
	nextPage.Visible = index < #pages
	art:ClearAllChildren()
	local display = exhibits:FindFirstChild("Display" .. index)
	local gui = display and display:FindFirstChild("GalleryDisplay", true)
	local frame = gui and gui:FindFirstChild("Exhibit")
	local illustration = frame and frame:FindFirstChildOfClass("Frame")
	if illustration then
		local copy = illustration:Clone()
		copy.Position, copy.Size = UDim2.fromScale(0, 0), UDim2.fromScale(1, 1)
		copy.ZIndex = 42
		for _, child in ipairs(copy:GetDescendants()) do
			if child:IsA("GuiObject") then child.ZIndex = 43 end
		end
		copy.Parent = art
	end
end

local prompts = {}
local connections = {}
local function bind(signal, handler)
	table.insert(connections, signal:Connect(handler))
end

local function blocked()
	return root.Shop.Visible or root:GetAttribute("JobBoardOpen17") or root:GetAttribute("AudioOpen33")
end

local function refreshPrompts()
	if blocked() then
		activeBoard = nil
		overlay.Visible = false
	end
	for _, prompt in pairs(prompts) do
		prompt.Enabled = opened and not overlay.Visible and not blocked()
	end
end

local function closeReader()
	activeBoard = nil
	overlay.Visible = false
	refreshPrompts()
end

local function addPrompt(board)
	if not board:IsA("BasePart") or board.Name ~= "Board" or prompts[board] then return end
	local index = tonumber(board.Parent.Name:match("^Display(%d+)$"))
	if not pages[index] then return end
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "ReadExhibit"
	prompt.ActionText = "Baca panel"
	prompt.ObjectText = "Pameran Foto Kampung"
	prompt.KeyboardKeyCode = Enum.KeyCode.F
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.ClickablePrompt = true
	prompt.MaxActivationDistance = 7
	prompt.RequiresLineOfSight = false
	prompt.Enabled = opened and not overlay.Visible and not blocked()
	bind(prompt.Triggered, function()
		if not prompt.Enabled or not opened or blocked() then return end
		activeBoard = board
		root:SetAttribute("MobileMenuOpen18", false)
		root:SetAttribute("MobileTargetOpen18", false)
		showPage(index)
		overlay.Visible = true
		refreshPrompts()
	end)
	prompts[board] = prompt
	prompt.Parent = board
end

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

bind(exhibits.DescendantAdded, function(item)
	apply(item)
	addPrompt(item)
end)
bind(exhibits.DescendantRemoving, function(item)
	local prompt = prompts[item]
	if not prompt then return end
	prompts[item] = nil
	prompt:Destroy()
	if item == activeBoard then closeReader() end
end)
bind(remotes.StateChanged.OnClientEvent, function(snapshot)
	local story = snapshot.story
	local show = snapshot.profileReady == true and story ~= nil and story.completed == story.total
	if show == opened then return end
	opened = show
	for _, frame in ipairs(exhibits:GetDescendants()) do apply(frame) end
	if not opened then closeReader() else refreshPrompts() end
end)

for _, item in ipairs(exhibits:GetDescendants()) do
	apply(item)
	addPrompt(item)
end
bind(previous.Activated, function() showPage(pageIndex - 1) end)
bind(nextPage.Activated, function() showPage(pageIndex + 1) end)
bind(close.Activated, closeReader)
bind(root:GetPropertyChangedSignal("AbsoluteSize"), layout)
bind(root.Shop:GetPropertyChangedSignal("Visible"), refreshPrompts)
bind(root:GetAttributeChangedSignal("JobBoardOpen17"), refreshPrompts)
bind(root:GetAttributeChangedSignal("AudioOpen33"), refreshPrompts)
bind(player.CharacterRemoving, closeReader)
bind(game:GetService("RunService").Heartbeat, function()
	if not activeBoard then return end
	local character = player.Character
	local characterRoot = character and character:FindFirstChild("HumanoidRootPart")
	if not characterRoot or (characterRoot.Position - activeBoard.Position).Magnitude > 10 then closeReader() end
end)
layout()
task.delay(1.35, function()
	if script.Parent then remotes.ActionRequest:FireServer("Sync") end
end)
script.Destroying:Connect(function()
	for _, connection in ipairs(connections) do connection:Disconnect() end
	for _, prompt in pairs(prompts) do prompt:Destroy() end
	overlay:Destroy()
end)
