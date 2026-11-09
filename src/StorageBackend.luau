local S=require(script.Parent.ProfileSchema)
local B={}
function B.Memory(seed)
	local rows=S.Copy(seed or {})
	return {rows=rows,Update=function(_,key,transform)
		local nextValue=transform(S.Copy(rows[key]))
		if nextValue~=nil then rows[key]=S.Copy(nextValue) return S.Copy(nextValue) end
		return nil
	end}
end
function B.DataStore(config)
	assert(config.Mode=="DataStoreTest" and game.GameId==config.TestUniverseId,"Test universe required")
	assert(config.Name=="PaketKilat_TEST_v1" and config.Scope=="T16_T20_QA" and config.KeyPrefix=="qa:","Test namespace required")
	local service=game:GetService("DataStoreService")
	local store=service:GetDataStore(config.Name,config.Scope)
	return {Update=function(_,key,transform)
		if service:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.UpdateAsync)<1 then error("DataStore budget unavailable") end
		return store:UpdateAsync(key,transform)
	end}
end
return B
