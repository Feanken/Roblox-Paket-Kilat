-- Pure challenge progression. EconomyService commits it alongside the order ledger.
local tuning=require(script.Parent.MovementTuning)
local M={}
function M.New()
 local t=tuning.Get()
 return {index=1,progress=0,cleanCondition=t.ChallengeCleanCondition,fragileCondition=t.ChallengeFragileCondition,steps={
  {id='clean',name='Kurir Rapi',description=string.format('Antar %d paket kondisi ≥%d',math.floor(t.ChallengeCleanCount),t.ChallengeCleanCondition),target=math.floor(t.ChallengeCleanCount),reward=math.floor(t.ChallengeCleanReward)},
  {id='explore',name='Jelajah Kota',description='Antar paket dengan cap bonus',target=1,reward=math.floor(t.ChallengeExploreReward)},
  {id='fragile',name='Spesialis Rapuh',description=string.format('Antar paket rapuh kondisi ≥%d',t.ChallengeFragileCondition),target=1,reward=math.floor(t.ChallengeFragileReward)},
 }}
end
function M.Snapshot(s)
 local step=s.steps[s.index]
 if not step then return {complete=true,index=3,count=3,name='Shift Selesai',description='Semua target sesi tercapai!',progress=1,target=1,reward=0}end
 return {complete=false,index=s.index,count=#s.steps,name=step.name,description=step.description,progress=s.progress,target=step.target,reward=step.reward}
end
function M.Preview(s,result)
 local nextState=table.clone(s)local step=s.steps[s.index]
 if not step then return nextState,0,nil end
 local qualifies=result.recoveryCount==0 and (
  step.id=='clean'and result.condition>=s.cleanCondition
  or step.id=='explore'and result.routeBonus>0
  or step.id=='fragile'and result.packageType=='Rapuh'and result.condition>=s.fragileCondition)
 if not qualifies then return nextState,0,nil end
 nextState.progress+=1
 if nextState.progress<step.target then return nextState,0,nil end
 nextState.index+=1 nextState.progress=0
 return nextState,step.reward,step.name
end
return M