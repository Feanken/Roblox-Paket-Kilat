-- Server-owned conditional bonuses, frozen with each accepted offer.
local M={}
local Status=require(game.ReplicatedStorage.PaketKilat.Shared.ContractStatus25)
function M.Build(C,index,revision,t)
 local destination=C.OrderSchedule[index].DestinationId
 local excellent=math.max(t.RatingCleanCondition,t.RatingExcellentCondition)
 local clean=t.RatingCleanCondition local stamps=math.floor(t.CityStampLimit)
 return {
  {id=revision..':priority',name='Prioritas',DestinationId=destination,PackageType='Biasa',JobBonus=0,Contract={kind='priority',reward=math.floor(t.ContractPriorityReward),condition=excellent,seconds=C.Routes[destination].TargetSeconds},description=string.format('Kondisi ≥%d, tepat waktu, tanpa pulih.',excellent)},
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
