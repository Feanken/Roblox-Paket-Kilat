-- Injected backend/clock allow fault tests without touching public data.
local Http=game:GetService("HttpService")
local S=require(script.Parent.ProfileSchema)
local Backend=require(script.Parent.StorageBackend)
local Data={}
local Manager={} Manager.__index=Manager
function Data.new(config,gameplay,backend,options)
	options=options or {}
	return setmetatable({config=config,gameplay=gameplay,backend=backend,profiles={},
		now=options.now or os.time,sleep=options.sleep or task.wait,
		guid=options.guid or function() return Http:GenerateGUID(false) end,
		owner=options.owner or Http:GenerateGUID(false),changed=options.changed or function() end},Manager)
end
function Manager:Notify(s) self.changed(s.uid,s.status,s.lastError) end
function Manager:Ready(uid)
	local s=self.profiles[uid]
	return s~=nil and s.status=="Ready" and s.data~=nil and self.now()<s.expiresAt-self.config.LeaseSafety
end
function Manager:Get(uid) local s=self.profiles[uid] return self:Ready(uid) and s.data or nil end
function Manager:Info(uid)
	local s=self.profiles[uid]
	return {profileReady=self:Ready(uid),profileStatus=s and s.status or "Loading",storageMode=self.config.Mode,
		saveStatus=s and (s.saving and "Saving" or s.lastError and "RetryPending" or s.dirty and "Pending" or "Acknowledged") or "Loading"}
end
function Manager:Retry(operation)
	local last
	for attempt=1,self.config.RetryCount do
		local ok,value=pcall(operation)
		if ok then return true,value end
		last=tostring(value)
		if attempt<self.config.RetryCount then self.sleep(self.config.Backoff*2^(attempt-1)) end
	end
	return false,last
end
function Manager:Load(uid)
	if self.profiles[uid] then return false,"AlreadyLoading" end
	local s={uid=uid,status="Loading",token=self.guid(),dirty=false,localRevision=0,expiresAt=0}
	self.profiles[uid]=s self:Notify(s)
	local reason
	local ok,result=self:Retry(function()
		return self.backend:Update(self.config.KeyPrefix..uid,function(raw)
			local p,revision=S.Decode(raw,self.gameplay)
			if not p then reason=revision return nil end
			local lock=raw and raw.lock
			if lock and lock.token and lock.token~=s.token and lock.expiresAt>self.now() then reason="SessionLocked" return nil end
			return {envelopeVersion=1,profile=p,revision=revision,updatedAt=self.now(),lastCommitId=raw and raw.lastCommitId,
				lock={token=s.token,owner=self.owner,expiresAt=self.now()+self.config.LeaseSeconds}}
		end)
	end)
	if not ok or not result or not result.lock or result.lock.token~=s.token then
		s.status="Failed" s.lastError=ok and (reason or "LoadRejected") or result self:Notify(s)
		if s.cancelled then self.profiles[uid]=nil end
		return false,s.lastError
	end
	local p,err=S.Validate(result.profile,self.gameplay)
	if not p then s.status="Failed" s.lastError=err self:Notify(s) return false,err end
	s.data=p s.expiresAt=result.lock.expiresAt s.status="Ready" s.nextSave=self.now()+self.config.SaveInterval
	if s.cancelled then s.status="Closing" return self:Save(uid,true) end
	self:Notify(s) return true,p
end
function Manager:Dirty(uid)
	assert(self:Ready(uid),"Profile not ready")
	local s=self.profiles[uid] s.localRevision+=1 s.dirty=true
end
function Manager:Save(uid,release)
	local s=self.profiles[uid]
	if not s or not s.data or s.status=="Failed" or s.status=="Lost" then return false,"NoLoadedProfile" end
	if s.saving then return false,"SaveBusy" end
	if self.now()>=s.expiresAt then s.status="Lost" s.lastError="LeaseExpired" self:Notify(s) return false,s.lastError end
	s.saving=true if release then s.status="Closing" end
	local snapshot,err=S.Validate(s.data,self.gameplay)
	if not snapshot then s.saving=false s.status="Lost" s.lastError=err self:Notify(s) return false,err end
	local revision=s.localRevision
	-- An ambiguous response must retry the SAME operation; never unlock/reacquire.
	local commit=self.guid()
	local reason
	self:Notify(s)
	local ok,result=self:Retry(function()
		return self.backend:Update(self.config.KeyPrefix..uid,function(raw)
			local valid,storedRevision=S.Decode(raw,self.gameplay)
			if not raw or not valid then reason="InvalidStoredProfile" return nil end
			if raw.lastCommitId==commit then
				if (release and raw.lock.token==nil) or (not release and raw.lock.token==s.token and raw.lock.expiresAt>self.now()) then return raw end
				reason="SessionLost" return nil
			end
			if raw.lock.token~=s.token or raw.lock.expiresAt<=self.now() then reason="SessionLost" return nil end
			return {envelopeVersion=1,profile=S.Copy(snapshot),revision=storedRevision+1,updatedAt=self.now(),lastCommitId=commit,
				lock=release and {} or {token=s.token,owner=self.owner,expiresAt=self.now()+self.config.LeaseSeconds}}
		end)
	end)
	s.saving=false
	if not ok or not result or result.lastCommitId~=commit then
		s.lastError=ok and (reason or "SaveRejected") or result
		if ok or self.now()>=s.expiresAt then s.status="Lost" end
		s.dirty=true s.nextSave=self.now()+self.config.SaveInterval
		warn("[PaketKilat] save failed uid="..uid.." "..s.lastError) self:Notify(s)
		return false,s.lastError
	end
	s.lastError=nil s.dirty=s.localRevision~=revision s.expiresAt=release and 0 or result.lock.expiresAt
	s.nextSave=self.now()+self.config.SaveInterval
	if release then self.profiles[uid]=nil else self:Notify(s) end
	return true
end
function Manager:Release(uid)
	local s=self.profiles[uid] if not s then return true end
	s.cancelled=true
	if s.status=="Loading" then return false,"LoadPending" end
	if not s.data or s.status=="Lost" then self.profiles[uid]=nil return false,"NoLoadedProfile" end
	s.status="Closing" return self:Save(uid,true)
end
function Manager:Tick()
	local now=self.now()
	for uid,s in pairs(self.profiles) do
		if s.status=="Lost" and s.cancelled then self.profiles[uid]=nil
		elseif s.data and not s.saving and (s.cancelled or now>=(s.nextSave or 0)) then
			s.nextSave=now+self.config.SaveInterval
			task.spawn(function() self:Save(uid,s.cancelled) end)
		end
	end
end
function Data.CreateRuntime(config,C,changed)
	local backend
	if config.Mode=="StudioMemory" then
		assert(game:GetService("RunService"):IsStudio(),"StudioMemory is Studio only") backend=Backend.Memory()
	else
		-- Adapter failures are load failures, never blank profile fallbacks.
		local ok,value=pcall(Backend.DataStore,config)
		backend=ok and value or {Update=function() error(tostring(value)) end}
	end
	Data.Runtime=Data.new(config,C,backend,{changed=changed})
	return Data.Runtime
end
return Data
