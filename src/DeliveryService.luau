-- Seluruh transisi dan kredit resmi berjalan sinkron di server.
local HttpService = game:GetService("HttpService")
local Movement = require(script.Parent.CourierMovement)
local Delivery = {orders = {}, requests = {}}
local C, P, W, emit, E, H, K, T
function Delivery.Init(config, packages, world, publish, economy, hazards, cosmetics, telemetry)
	C, P, W, emit, E, H = config, packages, world, publish, economy, hazards
 K,T=cosmetics,telemetry
end
local function root(player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	return hum and hum.Health > 0 and char:FindFirstChild("HumanoidRootPart") or nil
end
local function near(player, point)
	local r = root(player)
	return r ~= nil and (r.Position - point).Magnitude <= C.ActionDistance
end
local function destinationPoint(id)
	local model=W.Map:FindFirstChild(id)
	return model and model:FindFirstChild("DestinationPoint")
end
function Delivery.Snapshot(player)
	local snapshot = E.Snapshot(player)
	snapshot.status = "Idle"
 snapshot.movement=Movement.Snapshot(player)
 snapshot.routeBonus=require(script.Parent.CityBonus13).Snapshot(Delivery.orders[player.UserId])
 if T then snapshot.onboarding=T:Snapshot(player) end
	snapshot.depotPosition = W.Map.Depot.PickupPoint.Position
 snapshot.routeBasis=W.Map.DepotPad.CFrame.Rotation
	snapshot.recoveryPosition = W.Map.RecoveryPoint.Position
	local nextAssignment=E.PeekAssignment(player)
	local nextRoute=C.Routes[nextAssignment.DestinationId]
	snapshot.nextOrder={destinationId=nextAssignment.DestinationId,destinationName=nextRoute.Name,
		packageType=nextAssignment.PackageType,targetSeconds=nextRoute.TargetSeconds,
		bestTime=E.GetBest(player,nextAssignment.DestinationId,nextAssignment.PackageType)}
	local point=destinationPoint(nextAssignment.DestinationId)
	snapshot.destinationPosition=point and point.Position
	local o = Delivery.orders[player.UserId]
	if o then
		for _,key in ipairs({"orderId","ownerUserId","packageType","destinationId","status","condition","startedAt","rewardProcessed","completionLocked","recoveryCount","lastRecoveryAt","outOfBounds","jobName","jobBonus"}) do snapshot[key] = o[key] end
		snapshot.destinationName=C.Routes[o.destinationId].Name
		local point=destinationPoint(o.destinationId)
		snapshot.destinationPosition=point and point.Position
		snapshot.currentBestTime=E.GetBest(player,o.destinationId,o.packageType)
	end
	return snapshot
end
function Delivery.Publish(player, code)
	local o = Delivery.orders[player.UserId]
	if o then P.Update(o) end
	emit(player, Delivery.Snapshot(player), code)
end
function Delivery.ValidateCompletion(player, orderId, destinationId)
	if not E.Has(player) then return false, "PlayerInactive" end
	if not root(player) then return false, "NotAlive" end
	local o = Delivery.orders[player.UserId]
	if not o or o.ownerUserId ~= player.UserId or o.orderId ~= orderId then return false, "NotOwnerOrStale" end
	if o.completionLocked or o.rewardProcessed then return false, "CompletionLocked" end
	if o.status ~= "Carrying" or o.outOfBounds or not o.package or not o.package.Parent then return false, "InvalidState" end
	if destinationId ~= o.destinationId then return false, "WrongDestination" end
	local target=destinationPoint(o.destinationId)
	if not target then return false,"UnavailableDestination" end
	local point=target.Position
	if not near(player, point) or not ((o.package.Position - point).Magnitude <= C.PackageDeliveryDistance) then return false, "TooFar" end
	return true, "Valid"
end
function Delivery.LockCompletion(player, orderId, destinationId)
	local ok, code = Delivery.ValidateCompletion(player, orderId, destinationId)
	if ok then Delivery.orders[player.UserId].completionLocked = true end
	return ok, code
end
function Delivery.Complete(player, orderId, destinationId)
	local ok, code = Delivery.LockCompletion(player, orderId, destinationId)
	if not ok then return false, code end
	local o = Delivery.orders[player.UserId]
	o.status = "Delivered"
	local awarded, result = E.Award(player, o, workspace:GetServerTimeNow())
	if not awarded then o.status, o.completionLocked = "Carrying", false; return false, result end
	if T then T:Completed(player,o,result,E.Snapshot(player).coins) end
 P.Destroy(o)
	Delivery.orders[player.UserId] = nil
	Delivery.Publish(player, "Delivered")
	return true, "Delivered"
end
function Delivery.Handle(player, action, orderId, destinationId, arity)
	local now = os.clock()
	if now - (Delivery.requests[player.UserId] or -math.huge) < C.RequestCooldown then return false, "RateLimited" end
	Delivery.requests[player.UserId] = now
	if arity and arity>3 then return false,"InvalidArguments" end
	if type(action) ~= "string" or #action > 16
		or (orderId ~= nil and (type(orderId) ~= "string" or #orderId > 64))
		or (destinationId ~= nil and (type(destinationId) ~= "string" or #destinationId > 64)) then return false, "InvalidArguments" end
	local allowed = {Start = true, Pickup = true, Drop = true, Recover = true, Sync = true, Deliver = true, BuyCosmetic=true, EquipCosmetic=true, AcceptJob=true}
	if not allowed[action] then return false, "UnknownAction" end
	if (action=="Start" or action=="Sync") and orderId~=nil then return false,"InvalidArguments" end
	if (action == "Deliver" and type(destinationId) ~= "string") or (action ~= "Deliver" and destinationId ~= nil) then return false, "InvalidArguments" end
	if action == "Sync" then Delivery.Publish(player, "Sync"); return true, "Sync" end
	if not E.Has(player) then return false,"ProfileUnavailable" end
 if not root(player) then return false, "NotAlive" end
 if action=="BuyCosmetic" or action=="EquipCosmetic" then
  if not orderId then return false,"InvalidArguments" end
  if not near(player,W.Map.Depot.ShopPoint.Position) then return false,"TooFar" end
  local ok,code
  if action=="BuyCosmetic" then ok,code=E.Buy(player,orderId) else ok,code=E.Equip(player,orderId) end
  if ok then K.Apply(player) Delivery.Publish(player,code) end
  return ok,code
 end
 if action == "Deliver" then return Delivery.Complete(player, orderId, destinationId) end
	local o = Delivery.orders[player.UserId]
	if action == "Start" or action=="AcceptJob" then
		if o then return false, "OrderActive" end
		if not near(player, W.Map.Depot.PickupPoint.Position) then return false, "TooFar" end
		local assignment=E.PeekAssignment(player)
  if action=='AcceptJob'then assignment=E.ResolveOffer(player,orderId)if not assignment then return false,'OfferExpired'end end
		o = {
			orderId = HttpService:GenerateGUID(false), ownerUserId = player.UserId,
			packageType = assignment.PackageType, destinationId = assignment.DestinationId, status = "Carrying",
			condition = C.InitialCondition, startedAt = workspace:GetServerTimeNow(),
			rewardProcessed = false, completionLocked = false, recoveryCount = 0,
			lastRecoveryAt = -1, lastRecoveryClock = -math.huge, lastDamageAt = -math.huge,
			outOfBounds = false, player = player, jobName=assignment.name or 'Reguler',jobBonus=assignment.JobBonus or 0,
		}
		Delivery.orders[player.UserId] = o
		P.Create(o)
		P.Carry(o, root(player))
		E.AdvanceAssignment(player)
  if T then T:OrderStarted(player,o) end
	else
		if not o or o.ownerUserId ~= player.UserId or o.orderId ~= orderId then return false, "NotOwnerOrStale" end
		if o.completionLocked then return false, "CompletionLocked" end
		if action == "Pickup" then
			if o.status ~= "Dropped" then return false, "InvalidState" end
			if o.outOfBounds or not o.package or not o.package.Parent or not near(player, o.package.Position) then return false, "TooFar" end
			o.status = "Carrying"
			P.Carry(o, root(player))
		elseif action == "Drop" then
			if o.status ~= "Carrying" then return false, "InvalidState" end
			o.status = "Dropped"
			P.Drop(o, root(player))
		elseif action == "Recover" then
			if o.status ~= "Dropped" then return false, "InvalidState" end
			if now - o.lastRecoveryClock < C.RecoveryCooldown then return false, "RecoveryCooldown" end
			o.lastRecoveryClock, o.lastRecoveryAt = now, workspace:GetServerTimeNow()
			o.recoveryCount += 1
			o.condition = math.clamp(o.condition - C.RecoveryPenalty, 0, C.InitialCondition)
			o.outOfBounds = false
			if H then H.Clear(player) end
			P.Recover(o)
   if T then T:Recovered(player,o) end
			local r = root(player)
			local relative = r.Position - W.Map.DepotPad.Position
			local lo, hi = C.BoundsMin, C.BoundsMax
			if relative.Y < 0 or relative.X < lo.X or relative.X > hi.X or relative.Z < lo.Z or relative.Z > hi.Z or relative.Y > hi.Y then
				player.Character:PivotTo(W.Map.PrototypeSpawn.CFrame + C.RecoveryPlayerOffset)
				r.AssemblyLinearVelocity, r.AssemblyAngularVelocity = Vector3.zero, Vector3.zero
			end
		end
	end
	Delivery.Publish(player, action=='AcceptJob'and 'Start'or action)
	return true, action
end
function Delivery.Impact(o, cause)
	if Delivery.orders[o.ownerUserId] ~= o or o.completionLocked or o.outOfBounds then return false end
	local now = os.clock()
	if now - o.lastDamageAt < C.DamageCooldown then return false end
	if o.status ~= "Carrying" and o.status ~= "Dropped" then return false end
	o.lastDamageAt = now
	o.condition = math.clamp(o.condition - C.PackageTypes[o.packageType].ImpactDamage, 0, C.InitialCondition)
	if o.status == "Carrying" then o.status = "Dropped"; P.Drop(o, root(o.player)) end
	Delivery.Publish(o.player, cause or "Impact")
	return true
end
function Delivery.OutOfBounds(o)
	if o.outOfBounds or Delivery.orders[o.ownerUserId] ~= o then return end
	if o.status == "Carrying" then o.status = "Dropped"; P.Drop(o, root(o.player)) end
	o.outOfBounds = true
	P.Hold(o)
	Delivery.Publish(o.player, "OutOfBounds")
end
function Delivery.Cancel(player, code)
 if T then T:Cancelled(player) end
	if H then H.Clear(player) end
	local o = Delivery.orders[player.UserId]
	if o then P.Destroy(o); Delivery.orders[player.UserId] = nil end
	Delivery.requests[player.UserId] = nil
	Delivery.Publish(player, code or "Cancelled")
end
function Delivery.RemovePlayer(player)
	if H then H.Clear(player) end
	local o = Delivery.orders[player.UserId]
	if o then P.Destroy(o); Delivery.orders[player.UserId] = nil end
	Delivery.requests[player.UserId] = nil
	E.Leave(player)
end
return Delivery
