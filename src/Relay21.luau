-- One optional house-to-house trip after a depot order. No additional currency grant.
local shared = game.ReplicatedStorage.PaketKilat.Shared
local Paths = require(shared.CourierPaths21)
local Routes = require(shared.SafeRoutes08)
local R = {}
function R.Make(config, map, completed, deliveryNumber, id, now, tuning)
	if completed.isRelay then return nil end
	local sourceId = completed.destinationId
	local source = map:FindFirstChild(sourceId)
	local pickup = source and source:FindFirstChild("DestinationPoint")
	if not pickup or not config.Routes[sourceId] then return nil end
	local candidates = {}
	for destinationId in pairs(config.Routes) do
		local house = map:FindFirstChild(destinationId)
		local point = house and house:FindFirstChild("DestinationPoint")
		local path = point and Paths.Between(Routes, sourceId, destinationId)
		if path then table.insert(candidates, {id = destinationId, length = Paths.Length(path)}) end
	end
	table.sort(candidates, function(a, b)
		return a.length == b.length and a.id < b.id or a.length < b.length
	end)
	if #candidates == 0 then return nil end
	local choice = candidates[(deliveryNumber - 1) % math.min(2, #candidates) + 1]
	return {
		id = id, sourceId = sourceId, sourceName = config.Routes[sourceId].Name,
		pickupPosition = pickup.Position, destinationId = choice.id,
		destinationName = config.Routes[choice.id].Name,
		offeredAt = now, expiresAt = now + tuning.RelayOfferSeconds,
		targetSeconds = math.max(15, choice.length / 16 * tuning.RelayTimeScale),
	}
end
function R.Current(offer, now)
	return offer and now < offer.expiresAt and offer or nil
end
return R
