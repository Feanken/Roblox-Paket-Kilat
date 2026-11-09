-- Server-side catalog. Quote and effect use the session's locked tuning values.
local G={MaxGripLevel=3}
function G.Quote(level,t)
 level=math.clamp(math.floor(level or 0),0,G.MaxGripLevel)
 local reduction=level*t.GripUpgradeReduction
 return {level=level,maxLevel=G.MaxGripLevel,maxed=level==G.MaxGripLevel,
  multiplier=1-reduction,reductionPercent=math.floor(reduction*100+.5),
  nextReductionPercent=math.floor(math.min(level+1,G.MaxGripLevel)*t.GripUpgradeReduction*100+.5),
  nextPrice=level<G.MaxGripLevel and math.floor(t['GripUpgradePrice'..(level+1)])or nil}
end
return G