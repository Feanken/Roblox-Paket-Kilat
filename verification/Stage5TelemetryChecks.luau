local M=game.ServerScriptService.PaketKilat
local T=require(M.TelemetryService) local cfg=require(M.TelemetryConfig)
local checks={} local function check(name,ok) table.insert(checks,{name=name,passed=not not ok}) assert(ok,name) end
local now=1 local serial=0 local sent={}
local service=T.new(cfg,{mode="Injected",clock=function() return now end,guid=function() serial+=1 return "random-session-"..serial end,
	sink=function(_,kind,p) table.insert(sent,{kind=kind,payload=p}) end})
local player={UserId=987654321,Name="SENSITIVE_MARKER"}
local function order(id) return {orderId=id,ownerUserId=player.UserId,status="Carrying",packageType="Rapuh",destinationId="Rumah01",recoveryCount=0,condition=80,chat="SENSITIVE_MARKER"} end
check("begin",service:Begin(player)) check("duplicate begin rejected",not service:Begin(player))
check("initial guide",service:Snapshot(player).stage=="FindDepot")
local bad=order("bad") bad.destinationId="SENSITIVE_MARKER"
check("unknown category rejected",not service:OrderStarted(player,bad))
local o=order("one") check("first pickup",service:OrderStarted(player,o))
check("pickup repeat suppressed",not service:OrderStarted(player,o))
check("deliver guide",service:Snapshot(player).stage=="Deliver")
o.recoveryCount=1 check("recovery",service:Recovered(player,o))
check("recovery duplicate suppressed",not service:Recovered(player,o))
check("unrewarded completion denied",not service:Completed(player,o,{total=43},43))
o.rewardProcessed=true o.status="Delivered"
check("completion",service:Completed(player,o,{total=43},43))
check("completion replay suppressed",not service:Completed(player,o,{total=43},86))
check("return depot guide",service:Snapshot(player).stage=="ReturnDepot")
check("stale recovery denied",not service:Recovered(player,o))
local two=order("two") check("second order",service:OrderStarted(player,two))
check("guide complete",service:Snapshot(player).stage=="Complete")
service:Cancelled(player) check("reset retains milestone",service:Snapshot(player).stage=="Complete")
local three=order("three") service:OrderStarted(player,three) three.rewardProcessed=true three.status="Delivered" service:Completed(player,three,{total=42},85)
local snapshot=service:Snapshot(player) snapshot.stage="SENSITIVE_MARKER" check("snapshot copied",service:Snapshot(player).stage=="Complete")
check("end",service:End(player,"SENSITIVE_MARKER")) check("end duplicate suppressed",not service:End(player,"Left"))
check("session cache and queue cleaned",next(service.sessions)==nil and #service.queue==0)
local names={} local steps={} local economy=0
for _,row in ipairs(service.journal) do names[row.event]=(names[row.event] or 0)+1 end
for _,row in ipairs(sent) do if row.kind=="Funnel" then table.insert(steps,row.payload.step) end if row.kind=="Economy" then economy+=1 end end
check("five requested events observed",names.SessionStarted==1 and names.FirstPackagePicked==1 and names.PackageRecovered==1 and names.DeliveryCompleted==2 and names.SessionEnded==1)
check("second order event once",names.SecondOrderStarted==1)
check("funnel FIFO order",table.concat(steps,",")=="1,2,3,4")
check("economy once per success",economy==2)
local encoded=game.HttpService:JSONEncode(service:Inspect())
check("journal privacy",not encoded:find("SENSITIVE_MARKER",1,true) and not encoded:find("987654321",1,true) and not encoded:find('"orderId"',1,true) and not encoded:find('"chat"',1,true))
local inspect=service:Inspect() inspect.journal[1].event="changed" check("inspect copied",service.journal[1].event=="SessionStarted")
local failure=T.new(cfg,{mode="Injected",sink=function() error("Injected analytics outage") end})
failure:Begin(player) check("transport failure isolated",failure:End(player,"Left") and failure.stats.errors==2 and next(failure.sessions)==nil)
check("transport not retried",#failure.queue==0 and failure.stats.callReturned==0)
local localOnly=T.new(cfg,{mode="LocalOnly",sink=function() error("must not send") end}) localOnly:Begin(player) localOnly:End(player,"Left")
check("Studio LocalOnly never calls sink",localOnly.stats.queued==0 and localOnly.stats.errors==0 and #localOnly.journal==2)
local flood=T.new(cfg,{mode="Injected",clock=function() return now end,sink=function() end})
for i=1,300 do flood:Begin({UserId=i}) end
check("bounded journal",#flood.journal==cfg.JournalLimit and flood.stats.evicted>0)
check("bounded queue and rate",#flood.queue<=cfg.QueueLimit and flood.stats.queued<=cfg.MaxCallsPerMinute and flood.stats.dropped>0)
flood:Close() check("close cleans all sessions and queue",next(flood.sessions)==nil and #flood.queue==0)
return {mode="Injected transport / local journal; NOT dashboard receipt",passed=#checks,checks=checks}
