-- Run in Edit against injected memory backend. NO cloud calls.
local M=game.ServerScriptService.PaketKilat
local S=require(M.ProfileSchema)
local Data=require(M.DataService)
local B=require(M.StorageBackend)
local C=require(game.ReplicatedStorage.PaketKilat.Shared.Config)
local cfg=table.clone(require(M.StorageConfig)) cfg.Mode="InjectedMemory"
local checks={}
local function check(name,ok) table.insert(checks,{name=name,passed=not not ok}) assert(ok,name) end
local time=1000 local serial=0 local sleeps={}
local function manager(backend,owner)
	return Data.new(cfg,C,backend,{now=function() return time end,sleep=function(n) table.insert(sleeps,n) end,
		owner=owner,guid=function() serial+=1 return owner..serial end})
end
local function envelope(p,lock) return {envelopeVersion=1,profile=p,revision=0,lock=lock or {}} end
check("default schema",S.Validate(S.Default(),C)~=nil)
check("empty profile rejected",S.Validate({},C)==nil)
for _,n in ipairs({-1,0.5,math.huge,0/0,1000000001}) do local p=S.Default() p.coins=n check("invalid coins "..tostring(n),S.Validate(p,C)==nil) end
local legacy={schemaVersion=0,coins=73}
local migrated=S.Validate(legacy,C) check("v0 migration preserves coins",migrated and migrated.coins==73 and migrated.ownedCosmetics.TasStandar)
check("migration does not mutate raw",legacy.schemaVersion==0 and legacy.ownedCosmetics==nil)
local p=S.Default() p.schemaVersion=2 check("future schema rejected",S.Validate(p,C)==nil)
p=S.Default() p.equippedCosmetic="TasMerah" check("unowned equipment rejected",S.Validate(p,C)==nil)
p=S.Default() p.bestTimes["Rumah99|Biasa"]=12 check("unknown record rejected",S.Validate(p,C)==nil)
p=S.Default() p.bestTimes["Rumah01|Biasa"]=0 check("zero record rejected",S.Validate(p,C)==nil)
local backend=B.Memory() local a=manager(backend,"A") local b=manager(backend,"B")
check("new load success",a:Load(123)) check("new default zero",a:Get(123).coins==0)
check("lease excludes second server",not b:Load(123) and b:Get(123)==nil)
check("failed load cannot save",not b:Save(123) and backend.rows["qa:123"].lock.owner=="A")
local profile=a:Get(123) profile.coins=80 profile.ownedCosmetics.TasMerah=true profile.equippedCosmetic="TasMerah" profile.bestTimes["Rumah02|Rapuh"]=21.5 profile.deliveryCount=2 a:Dirty(123)
check("dirty flagged",a:Info(123).saveStatus=="Pending")
check("save success",a:Save(123)) check("save acknowledged",not a.profiles[123].dirty)
check("release success",a:Release(123)) check("cache cleaned",a.profiles[123]==nil)
b:Release(123) b=manager(backend,"B2") check("next simulated session load",b:Load(123))
local q=b:Get(123) check("roundtrip coins cosmetics count record",q.coins==80 and q.equippedCosmetic=="TasMerah" and q.ownedCosmetics.TasMerah and q.deliveryCount==2 and q.bestTimes["Rumah02|Rapuh"]==21.5)
time+=cfg.LeaseSeconds+1
local c=manager(backend,"C") check("expired lease takeover",c:Load(123))
check("stale save rejected",not b:Save(123) and b.profiles[123].status=="Lost")
check("new owner untouched",backend.rows["qa:123"].lock.owner=="C") c:Release(123)
-- Corrupt data is not overwritten even by acquire.
local bad=B.Memory({["qa:9"]=envelope({schemaVersion=99,coins=900})}) local d=manager(bad,"D")
check("corrupt load fails",not d:Load(9)) check("corrupt save blocked",not d:Save(9))
check("corrupt record preserved",bad.rows["qa:9"].profile.coins==900 and bad.rows["qa:9"].profile.schemaVersion==99)
local existing=envelope(S.Default()) existing.profile.coins=321
local fail=B.Memory({["qa:5"]=existing}) local realUpdate=fail.Update local calls=0
fail.Update=function() calls+=1 error("Injected load outage") end
local f=manager(fail,"F") check("outage load fails",not f:Load(5))
check("bounded load retries",calls==cfg.RetryCount)
check("no data after failed load",f.profiles[5].data==nil and not f:Ready(5))
check("failed load no overwrite",not f:Release(5) and fail.rows["qa:5"].profile.coins==321)
check("exponential backoff",sleeps[#sleeps-1]==0.5 and sleeps[#sleeps]==1)
fail.Update=realUpdate local g=manager(fail,"G") check("recovered load",g:Load(5))
g:Get(5).coins=333 g:Dirty(5)
fail.Update=function() error("Injected save outage") end
check("save outage fails",not g:Save(5)) check("save outage remains dirty",g.profiles[5].dirty and g.profiles[5].lastError~=nil)
check("save outage old value",fail.rows["qa:5"].profile.coins==321)
fail.Update=realUpdate check("save retry recovers",g:Save(5) and fail.rows["qa:5"].profile.coins==333)
-- Response lost AFTER commit: same commit id must not double revision or rollback.
local once=true local before=fail.rows["qa:5"].revision
fail.Update=function(self,key,transform)
	local result=realUpdate(self,key,transform)
	if once then once=false error("Injected committed response lost") end return result
end
g:Get(5).coins=350 g:Dirty(5)
check("ambiguous save acknowledged",g:Save(5))
check("ambiguous save commits once",fail.rows["qa:5"].revision==before+1 and fail.rows["qa:5"].profile.coins==350)
-- Simulate gameplay mutation while UpdateAsync yields.
once=true fail.Update=function(self,key,transform)
	local result=realUpdate(self,key,transform)
	if once then once=false g:Get(5).coins=370 g:Dirty(5) end return result
end
check("concurrent dirty save returns",g:Save(5)) check("concurrent mutation remains dirty",g.profiles[5].dirty and g:Get(5).coins==370 and fail.rows["qa:5"].profile.coins==350)
fail.Update=realUpdate check("next save captures mutation",g:Save(5) and fail.rows["qa:5"].profile.coins==370)
once=true fail.Update=function(self,key,transform)
	local result=realUpdate(self,key,transform) if once then once=false error("Injected release response lost") end return result
end
check("ambiguous release idempotent",g:Release(5) and fail.rows["qa:5"].lock.token==nil)
-- Leave during load cannot leave a session cache/lease behind.
local cancel=B.Memory() local base=cancel.Update local h
cancel.Update=function(self,key,transform) local result=base(self,key,transform) if h.profiles[7].status=="Loading" then h:Release(7) end return result end
h=manager(cancel,"H") h:Load(7)
check("leave during load clears profile",h.profiles[7]==nil)
check("leave during load releases lease",cancel.rows["qa:7"].lock.token==nil)
local safe=manager(B.Memory(),"SAFE") safe:Load(1) time+=cfg.LeaseSeconds-cfg.LeaseSafety+1
check("near-expiry freezes economy",not safe:Ready(1))
local ec=M.EconomyService:Clone() ec.Name="Stage4EconomyIsolated" ec.Parent=M
local E=require(ec) local econData=manager(B.Memory(),"ECON") local player={UserId=810}
E.Init(C,econData)
check("unloaded economy cannot join",not E.Join(player))
check("unloaded purchase blocked",not E.Buy(player,"TasMerah"))
econData:Load(810) check("loaded economy join",E.Join(player))
check("zero coins insufficient",not E.Buy(player,"TasMerah") and E.Snapshot(player).coins==0)
local order={orderId="zero-duration",ownerUserId=810,completionLocked=true,status="Delivered",destinationId="Rumah01",packageType="Biasa",startedAt=100,condition=100,recoveryCount=0}
check("zero-duration reward stays serializable",E.Award(player,order,100) and S.Validate(econData:Get(810),C)~=nil)
check("duplicate credit refused",not E.Award(player,order,101) and E.Snapshot(player).deliveryCount==1)
econData.profiles[810].status="Failed"
check("failed profile snapshot hides balance",not E.Snapshot(player).profileReady and E.Snapshot(player).coins==nil)
check("failed profile purchase blocked",not E.Buy(player,"TasMerah"))
check("failed profile equip blocked",not E.Equip(player,"TasStandar"))
E.Leave(player) check("economy cache cleaned",E.sessions[810]==nil) ec:Destroy()
return {backend="InjectedMemory; NOT real DataStore cross-session",passed=#checks,checks=checks}
