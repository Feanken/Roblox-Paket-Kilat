local S={}
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function integer(n) return finite(n) and n>=0 and n<=1000000000 and n%1==0 end
function S.Copy(v)
	if type(v)~="table" then return v end
	local t={} for k,x in pairs(v) do t[k]=S.Copy(x) end return t
end
function S.Default()
	return {schemaVersion=3,coins=0,deliveryCount=0,careerWeek={week=0,mask=0},ownedCosmetics={TasStandar=true},equippedCosmetic="TasStandar",bestTimes={},upgrades={Grip=0}}
end
function S.Validate(raw,C)
	if type(raw)~="table" then return nil,"InvalidProfile" end
	local p=S.Copy(raw)
	if p.schemaVersion==0 then
		-- Migration is explicit; an empty/corrupt record is never a new player.
		if not integer(p.coins) then return nil,"InvalidLegacyCoins" end
		p.schemaVersion=1
		p.deliveryCount=p.deliveryCount or 0
		p.ownedCosmetics=p.ownedCosmetics or {TasStandar=true}
		p.equippedCosmetic=p.equippedCosmetic or "TasStandar"
		p.bestTimes=p.bestTimes or {}
	end
	if p.schemaVersion==1 then p.schemaVersion=2 p.upgrades={Grip=0}end
 if p.schemaVersion==2 then
  p.schemaVersion=3
  p.careerWeek={week=0,mask=0}
 end
 if p.schemaVersion~=3 then return nil,"UnsupportedSchema" end
 local career=p.careerWeek
 if type(career)~="table" or not integer(career.week) or not integer(career.mask) or career.mask>7 then
  return nil,"InvalidCareer"
 end
 if type(p.upgrades)~="table"or not integer(p.upgrades.Grip)or p.upgrades.Grip>3 then return nil,"InvalidUpgrades"end
 for id in pairs(p.upgrades)do if id~="Grip"then return nil,"UnknownUpgrade"end end
	if not integer(p.coins) or not integer(p.deliveryCount) then return nil,"InvalidCounters" end
	if type(p.ownedCosmetics)~="table" or type(p.bestTimes)~="table" then return nil,"InvalidCollections" end
	local owned={} for id,v in pairs(p.ownedCosmetics) do
		if type(id)~="string" or not C.Cosmetics[id] or v~=true then return nil,"InvalidOwnership" end
		owned[id]=true
	end
	if not owned.TasStandar or type(p.equippedCosmetic)~="string" or not owned[p.equippedCosmetic] then return nil,"InvalidEquipment" end
	local best={}
	for key,seconds in pairs(p.bestTimes) do
		if type(key)~="string" or #key>64 then return nil,"InvalidRecordKey" end
		local goal,kind=key:match("^([^|]+)|([^|]+)$")
		if not C.Routes[goal] or not C.PackageTypes[kind] or not finite(seconds) or seconds<=0 then return nil,"InvalidRecord" end
		best[key]=seconds
	end
	return {schemaVersion=3,coins=p.coins,deliveryCount=p.deliveryCount,careerWeek={week=career.week,mask=career.mask},ownedCosmetics=owned,equippedCosmetic=p.equippedCosmetic,bestTimes=best,upgrades={Grip=p.upgrades.Grip}}
end
function S.Decode(raw,C)
	if raw==nil then return S.Default(),0 end
	if type(raw)~="table" then return nil,"InvalidEnvelope" end
	if raw.envelopeVersion~=1 then return nil,"UnsupportedEnvelope" end
	if not integer(raw.revision) or type(raw.lock)~="table" then return nil,"InvalidEnvelope" end
	local lock=raw.lock
	if lock.token~=nil and (type(lock.token)~="string" or type(lock.owner)~="string" or not finite(lock.expiresAt)) then return nil,"InvalidLock" end
	local p,err=S.Validate(raw.profile,C)
	return p,p and raw.revision or err
end
return S
