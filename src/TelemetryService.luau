local Http=game:GetService("HttpService")
local Run=game:GetService("RunService")
local Analytics=game:GetService("AnalyticsService")
local Gameplay=require(game:GetService("ReplicatedStorage"):WaitForChild("PaketKilat"):WaitForChild("Shared"):WaitForChild("Config"))
local T={}
local Service={} Service.__index=Service
local fieldKeys={Enum.AnalyticsCustomFieldKeys.CustomField01.Name,Enum.AnalyticsCustomFieldKeys.CustomField02.Name,Enum.AnalyticsCustomFieldKeys.CustomField03.Name}
local function copy(v) if type(v)~="table" then return v end local n={} for k,x in pairs(v) do n[k]=copy(x) end return n end
local function validOrder(o)
	return type(o)=="table" and type(o.orderId)=="string" and #o.orderId<=64
		and Gameplay.Routes[o.destinationId]~=nil and Gameplay.PackageTypes[o.packageType]~=nil
end
function T.new(config,options)
	options=options or {}
	return setmetatable({config=config,sessions={},journal={},queue={},stats={recorded=0,evicted=0,queued=0,callReturned=0,errors=0,dropped=0},
		clock=options.clock or os.clock,guid=options.guid or function() return Http:GenerateGUID(false) end,
		mode=options.mode or "LocalOnly",sink=options.sink,window=0,calls=0},Service)
end
function Service:Push(s,event,fields)
	s.sequence+=1
	local row={sessionId=s.id,sequence=s.sequence,event=event,elapsed=math.max(0,self.clock()-s.started),fields=copy(fields or {})}
	if #self.journal>=self.config.JournalLimit then table.remove(self.journal,1) self.stats.evicted+=1 end
	table.insert(self.journal,row) self.stats.recorded+=1
end
function Service:Queue(s,player,kind,payload)
	if self.mode~="Roblox" and self.mode~="Injected" then return end
	local minute=math.floor(self.clock()/60)
	if self.window~=minute then self.window=minute self.calls=0 end
	if s.window~=minute then s.window=minute s.calls=0 end
	if self.calls>=self.config.MaxCallsPerMinute or s.calls>=self.config.PerSessionCallsPerMinute or #self.queue>=self.config.QueueLimit then self.stats.dropped+=1 return end
	self.calls+=1 s.calls+=1
	table.insert(self.queue,{player=player,kind=kind,payload=payload}) self.stats.queued+=1
end
local function fields(a,b,c)
	local out={} if a then out[fieldKeys[1]]=a end if b then out[fieldKeys[2]]=b end if c then out[fieldKeys[3]]=c end return out
end
function Service:Step(player,s,step,name)
	self:Queue(s,player,"Funnel",{sessionId=s.id,step=step,name=name})
end
function Service:Begin(player)
	if self.sessions[player] then return false end
	local s={id=self.guid(),started=self.clock(),sequence=0,firstPickup=false,deliveries=0,secondOrder=false,activeId=nil,calls=0}
	self.sessions[player]=s self:Push(s,"SessionStarted") self:Step(player,s,1,"Session Started") return true
end
function Service:OrderStarted(player,o)
	local s=self.sessions[player]
	if not s or not validOrder(o) or o.ownerUserId~=player.UserId or o.status~="Carrying" or s.activeId==o.orderId then return false end
	s.activeId=o.orderId s.lastRecovery=0
	if not s.firstPickup then
		s.firstPickup=true self:Push(s,"FirstPackagePicked") self:Step(player,s,2,"First Package Picked")
	end
	if s.deliveries>=1 and not s.secondOrder then
		s.secondOrder=true self:Push(s,"SecondOrderStarted") self:Step(player,s,4,"Second Order Started")
	end
	return true
end
function Service:Cancelled(player)
	local s=self.sessions[player] if s then s.activeId=nil s.lastRecovery=0 end
end
function Service:Recovered(player,o)
	local s=self.sessions[player]
	if not s or not validOrder(o) or s.activeId~=o.orderId or type(o.recoveryCount)~="number" or o.recoveryCount<=s.lastRecovery then return false end
	s.lastRecovery=o.recoveryCount
	self:Push(s,"PackageRecovered",{packageType=o.packageType,destinationId=o.destinationId})
	self:Queue(s,player,"Custom",{name="PKPackageRecovered",value=1,fields=fields("Package - "..o.packageType,"Destination - "..o.destinationId)})
	return true
end
function Service:Completed(player,o,result,balance)
	local s=self.sessions[player]
	if not s or not validOrder(o) or s.activeId~=o.orderId or o.ownerUserId~=player.UserId or not o.rewardProcessed or o.status~="Delivered" then return false end
	s.activeId=nil s.deliveries+=1
	self:Push(s,"DeliveryCompleted",{packageType=o.packageType,destinationId=o.destinationId,deliveryNumber=s.deliveries})
	self:Queue(s,player,"Economy",{amount=result.total,balance=balance,sku=o.packageType,
		fields=fields("Destination - "..o.destinationId,"Package - "..o.packageType,"Condition - "..(o.condition>=80 and "Good" or o.condition>0 and "Damaged" or "Zero"))})
	if s.deliveries==1 then self:Step(player,s,3,"First Delivery Completed") end
	return true
end
function Service:Snapshot(player)
	local s=self.sessions[player]
	if not s then return {stage="FindDepot",deliveryCount=0,firstPickup=false} end
	return {stage=s.secondOrder and "Complete" or s.deliveries>0 and "ReturnDepot" or s.activeId and "Deliver" or "FindDepot",deliveryCount=s.deliveries,firstPickup=s.firstPickup}
end
function Service:End(player,reason)
	local s=self.sessions[player] if not s then return false end
	local stage=s.secondOrder and "SecondOrder" or s.deliveries>0 and "FirstDelivered" or s.firstPickup and "Picked" or "NoPickup"
	reason=reason=="ServerClosing" and "ServerClosing" or "Left"
	self:Push(s,"SessionEnded",{stage=stage,reason=reason})
	self:Queue(s,player,"Custom",{name="PKSessionOutcome",value=1,fields=fields("Stage - "..stage,"End - "..reason,"Deliveries - "..(s.deliveries>1 and "2plus" or tostring(s.deliveries)))})
	self.sessions[player]=nil self:FlushPlayer(player) return true
end
function Service:FlushPlayer(player)
	local i=1
	while i<=#self.queue do
		local q=self.queue[i]
		if q.player==player then
			table.remove(self.queue,i)
			local ok=pcall(self.sink,q.player,q.kind,q.payload)
			if ok then self.stats.callReturned+=1 else self.stats.errors+=1 end
		else i+=1 end
	end
end
function Service:FlushOne()
	local q=table.remove(self.queue,1) if not q then return false end
	local ok=pcall(self.sink,q.player,q.kind,q.payload)
	if ok then self.stats.callReturned+=1 else self.stats.errors+=1 end
	-- No retry: an error might follow a committed event; delivery must not duplicate.
	return true
end
function Service:Inspect() return {mode=self.mode,stats=copy(self.stats),journal=copy(self.journal),queued=#self.queue} end
function Service:Start()
	self.running=true
	task.spawn(function() while self.running do self:FlushOne() task.wait(self.config.FlushInterval) end end)
end
function Service:Close()
	for player in pairs(self.sessions) do self:End(player,"ServerClosing") end
	local deadline=self.clock()+self.config.CloseTimeout
	while #self.queue>0 and self.clock()<deadline do self:FlushOne() task.wait() end
	self.stats.dropped+=#self.queue table.clear(self.queue) self.running=false
end
local function send(player,kind,p,funnel)
	if kind=="Funnel" then Analytics:LogFunnelStepEvent(player,funnel,p.sessionId,p.step,p.name)
	elseif kind=="Economy" then Analytics:LogEconomyEvent(player,Enum.AnalyticsEconomyFlowType.Source,"Coins",p.amount,p.balance,Enum.AnalyticsEconomyTransactionType.Gameplay.Name,p.sku,p.fields)
	elseif kind=="Custom" then Analytics:LogCustomEvent(player,p.name,p.value,p.fields) end
end
function T.CreateRuntime(config)
	local live=not Run:IsStudio() and Run:IsServer() and config.LiveEnabled and game.PlaceId~=0 and game.GameId==config.AllowedUniverseId
	T.Runtime=T.new(config,{mode=Run:IsStudio() and "LocalOnly" or live and "Roblox" or "Disabled",sink=function(player,kind,p) send(player,kind,p,config.Funnel) end})
	T.Runtime:Start() return T.Runtime
end
return T
