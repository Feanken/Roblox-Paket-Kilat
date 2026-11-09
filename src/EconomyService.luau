-- Persistent validated profile references; order ledger remains session-only.
local E={sessions={}}
local C,Data
local function copy(value) return value and table.clone(value) or nil end
function E.Init(config,data) C,Data=config,data end
function E.Join(player)
 local profile=Data:Get(player.UserId)
 if not profile then return false end
 E.sessions[player.UserId]={profile=profile,creditedOrders={},nextOrderIndex=1}
 return true
end
function E.Has(player) return E.sessions[player.UserId]~=nil and Data:Ready(player.UserId) end
function E.PeekAssignment(player)
	local s=E.sessions[player.UserId]
	return table.clone(C.OrderSchedule[s and s.nextOrderIndex or 1])
end
function E.AdvanceAssignment(player)
	local s=E.sessions[player.UserId]
	s.nextOrderIndex=s.nextOrderIndex%#C.OrderSchedule+1
end
function E.GetBest(player,destinationId,packageType)
	local s=E.sessions[player.UserId]
	return s and s.profile.bestTimes[destinationId.."|"..packageType] or nil
end
function E.Snapshot(player)
 local s=E.sessions[player.UserId]
 local out=Data:Info(player.UserId)
 out.profileOwnerUserId=player.UserId
 if s and out.profileReady then
  local p=s.profile
  out.coins=p.coins out.deliveryCount=p.deliveryCount
  out.lastResult=copy(s.lastResult) out.bestTimes=table.clone(p.bestTimes)
  out.ownedCosmetics=table.clone(p.ownedCosmetics) out.equippedCosmetic=p.equippedCosmetic
 end
 return out
end
function E.Buy(player,id)
 if not E.Has(player) then return false,"ProfileUnavailable" end
 local item=C.Cosmetics[id] if not item then return false,"UnknownCosmetic" end
 local p=E.sessions[player.UserId].profile
 if p.ownedCosmetics[id] then return false,"AlreadyOwned" end
 if p.coins<item.Price then return false,"InsufficientCoins" end
 p.coins-=item.Price p.ownedCosmetics[id]=true Data:Dirty(player.UserId)
 return true,"Purchased"
end
function E.Equip(player,id)
 if not E.Has(player) then return false,"ProfileUnavailable" end
 local p=E.sessions[player.UserId].profile
 if not C.Cosmetics[id] then return false,"UnknownCosmetic" end
 if not p.ownedCosmetics[id] then return false,"NotOwned" end
 if p.equippedCosmetic==id then return true,"Equipped" end
 p.equippedCosmetic=id Data:Dirty(player.UserId)
 return true,"Equipped"
end
function E.Award(player,order,now)
	local s=E.sessions[player.UserId]
	if not E.Has(player) then return false,"ProfileUnavailable" end
 local p=s.profile
	if s.creditedOrders[order.orderId] or order.rewardProcessed then return false,"AlreadyRewarded" end
	if order.ownerUserId~=player.UserId or not order.completionLocked or order.status~="Delivered" then return false,"InvalidState" end
	local route=C.Routes[order.destinationId]
	if not route or not C.PackageTypes[order.packageType] then return false,"WrongDestination" end
	local duration=math.max(0.001,now-order.startedAt)
	local condition=math.clamp(order.condition,0,C.InitialCondition)
	local conditionBonus=math.floor(C.ConditionBonus*condition/C.InitialCondition)
	local timeBonus=math.floor(C.TimeBonus*math.clamp(1-duration/route.TargetSeconds,0,1))
	local key=order.destinationId.."|"..order.packageType
	local previous=p.bestTimes[key]
	local eligible=order.recoveryCount==0
	local newRecord=eligible and (previous==nil or duration<previous)
	local result={
		orderId=order.orderId,destinationId=order.destinationId,destinationName=route.Name,packageType=order.packageType,
		duration=duration,condition=condition,recoveryCount=order.recoveryCount,
		baseReward=C.BaseReward,conditionBonus=conditionBonus,timeBonus=timeBonus,
		routeBonus=require(script.Parent.CityBonus13).Reward(order),
  total=C.BaseReward+conditionBonus+timeBonus+require(script.Parent.CityBonus13).Reward(order),completedAt=now,
		recordEligible=eligible,recordReason=not eligible and "Recovered" or nil,
		previousBest=previous,newRecord=newRecord,
	}
	-- Tidak ada yield: kunci kredit, koin, rekor, dan hasil bersifat satu transisi.
	if p.coins+result.total>1000000000 or p.deliveryCount>=1000000000 then return false,"EconomyLimit" end
 order.rewardProcessed=true
	s.creditedOrders[order.orderId]=true
	p.coins+=result.total
	p.deliveryCount+=1
	if newRecord then p.bestTimes[key]=duration end
	result.bestTime=p.bestTimes[key]
	s.lastResult=result
 Data:Dirty(player.UserId)
	return true,copy(result)
end
function E.Leave(player) E.sessions[player.UserId]=nil end
return E
