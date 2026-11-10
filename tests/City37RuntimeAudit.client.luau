-- Play/client read-only observation; does not move players or modify orders.
local folder=workspace:FindFirstChild("PaketKilatLocalResidents37")
assert(folder,"Resident controller is not running")
local out={count=#folder:GetChildren(),budget=folder:GetAttribute("Budget37"),bad={},motion={}}
assert(out.count<=out.budget,"Resident budget exceeded")
local before={}
for _,model in folder:GetChildren()do
 before[model.Name]=model:GetPivot().Position
 for _,p in model:GetDescendants()do if p:IsA("BasePart")and(not p.Anchored or p.CanCollide or p.CanTouch or p.CanQuery)then table.insert(out.bad,p:GetFullName())end end
end
task.wait(1.2)
for _,model in folder:GetChildren()do if before[model.Name]then table.insert(out.motion,{id=model.Name,delta=(model:GetPivot().Position-before[model.Name]).Magnitude,walking=model:GetAttribute("Walking37")})end end
assert(#out.bad==0,"Resident part flags differ")
return game.HttpService:JSONEncode(out)
