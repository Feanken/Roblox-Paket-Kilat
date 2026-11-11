-- Server-owned conditional bonuses, frozen with each accepted offer.
local M={}
local Status=require(game.ReplicatedStorage.PaketKilat.Shared.ContractStatus25)
function M.Build(C,index,revision,t,expressUnlocked)
 local destination = expressUnlocked and (index % 2 == 1 and "CBD01" or "BQ10") or C.OrderSchedule[index].DestinationId
 local excellent=math.max(t.RatingCleanCondition,t.RatingExcellentCondition)
 local seconds = C.Routes[destination].TargetSeconds
 if expressUnlocked then seconds = math.floor(seconds * .7) end
 local priority = {
  id = revision .. (expressUnlocked and ":districtExpress" or ":priority"),
  name = expressUnlocked and "Ekspres Distrik" or "Prioritas",
  DestinationId = destination,
  PackageType = expressUnlocked and "Rapuh" or "Biasa",
  JobBonus = 0,
  Contract = {
   kind = "priority", condition = expressUnlocked and math.max(excellent, 95) or excellent,
   reward = math.floor(t.ContractPriorityReward) + (expressUnlocked and 18 or 0),
   seconds = seconds, express = expressUnlocked == true,
  },
  description = expressUnlocked and "Jaga paket rapuh dan tiba sebelum tenggat." or "Tiba tepat waktu dan jaga kondisi paket.",
 }
 local clean=t.RatingCleanCondition local stamps=math.floor(t.CityStampLimit)
 return {
  priority,
  {id=revision..':perfect',name='Paket mulus',DestinationId=string.format('Rumah%02d',index%5+1),PackageType='Rapuh',JobBonus=0,Contract={kind='perfect',reward=math.floor(t.ContractPerfectReward),condition=C.InitialCondition},description=string.format('Rapuh tetap%d, tanpa pulih.',C.InitialCondition)},
  {id=revision..':explore',name='Pemburu cap',DestinationId=index%2==1 and 'Rumah04'or 'Rumah05',PackageType='Biasa',JobBonus=0,Contract={kind='explore',reward=math.floor(t.ContractExploreReward),condition=clean,stamps=stamps},description=string.format('%d cap, kondisi ≥%d, tanpa pulih.',stamps,clean)},
 }
end
function M.Evaluate(contract,result,stamps)
 local status=Status.Get(contract,{condition=result.condition,duration=result.duration,recoveryCount=result.recoveryCount,stamps=stamps})
 if not status then return 0,nil,nil end
 return status.eligible and contract.reward or 0,status.eligible,status
end
return M
