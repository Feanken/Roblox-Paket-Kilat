local Players = game:GetService("Players")
local L = {bindings = {}}
local D, E, W, C,Data,K,T
local function disconnect(list)
	for _,connection in ipairs(list) do connection:Disconnect() end
	table.clear(list)
end
function L.Unbind(player)
	local b = L.bindings[player]
	if b then
		disconnect(b.characterConnections)
		disconnect(b.playerConnections)
		L.bindings[player] = nil
	end
	if T then T:End(player,"Left") end
 D.RemovePlayer(player)
 task.spawn(function() Data:Release(player.UserId) end)
end
function L.Bind(player)
	if L.bindings[player] then return end
	player.RespawnLocation = W.Map.PrototypeSpawn
	local b = {characterConnections = {}, playerConnections = {}}
	L.bindings[player] = b
 if T then T:Begin(player) end
 local function interrupt()
  local order=D.orders[player.UserId]
  if order then
   b.resumeCode=order.storyChapter and "RespawnStory" or order.isBatch and "RespawnBatch" or "RespawnOrder"
  end
  D.Cancel(player,"Cancelled")
 end
	local function character(char)
		if L.bindings[player] ~= b or player.Character ~= char then return end
		b.character = char
		disconnect(b.characterConnections)
  if D.orders[player.UserId] then interrupt() end
		local function group(v) if v:IsA("BasePart") then v.CollisionGroup = "PKCharacters" end end
		for _,v in ipairs(char:GetDescendants()) do group(v) end
		table.insert(b.characterConnections, char.DescendantAdded:Connect(group))
		local hum = char:WaitForChild("Humanoid", 10)
		local r = char:WaitForChild("HumanoidRootPart", 10)
		if not hum or not r or L.bindings[player] ~= b or player.Character ~= char or player.Parent ~= Players then return end
		table.insert(b.characterConnections, hum.Died:Connect(function()
			if b.character == char and player.Character == char then interrupt() end
		end))
		char:PivotTo(W.Map.PrototypeSpawn.CFrame + C.SpawnOffset)
  K.Apply(player)
  local code=b.resumeCode or "Respawned"
  b.resumeCode=nil
  D.Publish(player,code)
	end
	table.insert(b.playerConnections, player.CharacterAdded:Connect(character))
	table.insert(b.playerConnections, player.CharacterRemoving:Connect(function(char)
		if b.character ~= char then return end
		b.character = nil
		disconnect(b.characterConnections)
  if D.orders[player.UserId] or D.relayOffers[player.UserId] then interrupt() end
	end))
	if player.Character then task.spawn(character, player.Character) end
 task.spawn(function()
  local ok=Data:Load(player.UserId)
  if L.bindings[player]~=b or player.Parent~=Players then Data:Release(player.UserId) return end
  if ok then E.Join(player) K.Apply(player) end
  D.Publish(player,ok and "ProfileReady" or "ProfileUnavailable")
 end)
end
function L.Start(delivery, economy, world, config, data,cosmetics,telemetry)
	D, E, W, C,Data,K,T = delivery, economy, world, config,data,cosmetics,telemetry
	Players.PlayerAdded:Connect(L.Bind)
	Players.PlayerRemoving:Connect(L.Unbind)
	for _,player in ipairs(Players:GetPlayers()) do L.Bind(player) end
end
return L
