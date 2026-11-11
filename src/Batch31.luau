-- Server-owned route definitions and pure bonus helpers.
local B={}
local catalog={
 {name='Putaran Pasar',ids={'Rumah01','Rumah03','Rumah04'},types={'Biasa','Biasa','Rapuh'}},
 {name='Lintas Kampung',ids={'Rumah02','Rumah05','Rumah03'},types={'Biasa','Rapuh','Biasa'}},
 {name='Lintas Distrik',ids={'CBD01','BQ10','BQ16'},types={'Biasa','Rapuh','Biasa'}},
}
function B.Offers(seed,bonus,C)
 local out={}
 for i,r in ipairs(catalog)do table.insert(out,{id=seed..':batch'..i,name=r.name,isBatch=true,batchDestinations=table.clone(r.ids),packageTypes=table.clone(r.types),destinationId=r.ids[1],destinationName=C.Routes[r.ids[1]].Name,packageType='3 paket',jobBonus=math.floor(bonus),description='Ambil tiga kiriman. Antar berurutan tanpa kembali ke depot.'})end
 return out
end
function B.Bonus(o,initial)
 if not o.isBatch or o.batchIndex~=o.batchTotal or o.batchRecovered or o.recoveryCount~=0 then return 0 end
 if type(initial)~='number'or type(o.condition)~='number'then return 0 end
 local prior=o.batchMinCondition or initial local bonus=o.batchReward or 0
 for _,n in ipairs({initial,prior,o.condition,bonus})do if type(n)~='number'or n~=n or math.abs(n)==math.huge then return 0 end end
 if initial<=0 then return 0 end
 local lowest=math.min(prior,o.condition)
 if lowest~=lowest or bonus~=bonus or math.abs(lowest)==math.huge or math.abs(bonus)==math.huge then return 0 end
 return math.floor(math.clamp(bonus,0,50)*math.clamp(lowest/initial,0,1))
end
function B.Snapshot(b,C,current)
 local stops={}
 for i,id in ipairs(b.ids)do stops[i]={id=id,name=C.Routes[id].Name,packageType=b.types[i],done=i<b.index}end
 local lowest=math.min(b.minCondition,current and current.condition or C.InitialCondition)
 local eligible=not b.recovered and(not current or current.recoveryCount==0)
 return {potentialBonus=eligible and math.floor(b.bonus*math.clamp(lowest/C.InitialCondition,0,1))or 0,id=b.id,name=b.name,index=b.index,total=#b.ids,remaining=#b.ids-b.index+1,stops=stops,earned=b.earned,bonus=b.bonus,bonusEligible=not b.recovered and(not current or current.recoveryCount==0),minCondition=math.min(b.minCondition,current and current.condition or C.InitialCondition)}
end
return B
