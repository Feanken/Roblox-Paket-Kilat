-- Server-owned conditional bonuses, frozen with each accepted offer.
local M={}
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
 if not contract then return 0,nil end
 local ok=result.recoveryCount==0 and result.condition>=contract.condition
 if contract.kind=='priority'then ok=ok and result.duration<=contract.seconds
 elseif contract.kind=='explore'then ok=ok and stamps>=contract.stamps
 elseif contract.kind~='perfect'then ok=false end
 return ok and contract.reward or 0,ok
end
return M
