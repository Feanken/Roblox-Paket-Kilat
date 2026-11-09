-- Server-only balance defaults. Published experiences may override through ConfigService.
local T={}
local defaults={SprintMultiplier=1.4,StaminaDrain=18,StaminaRegen=16,RestartAt=20,
 GripDrain=14,FragileGripDrain=22,GripRegen=10,IntentLease=1.2,IntentInterval=.12,CityStampReward=6,CityStampLimit=2,CityStampRadius=6,ChallengeCleanCount=2,ChallengeCleanCondition=90,ChallengeFragileCondition=80,ChallengeCleanReward=20,ChallengeExploreReward=25,ChallengeFragileReward=30,JobFragileBonus=8,JobLongBonus=10,GripUpgradePrice1=80,GripUpgradePrice2=140,GripUpgradePrice3=220,GripUpgradeReduction=.1}
local bounds={SprintMultiplier={1,1.8},StaminaDrain={1,60},StaminaRegen={1,60},RestartAt={5,80},
 GripDrain={1,60},FragileGripDrain={1,80},GripRegen={1,60},IntentLease={.8,2},IntentInterval={.05,.3},CityStampReward={0,10},CityStampLimit={1,2},CityStampRadius={3,8},ChallengeCleanCount={1,5},ChallengeCleanCondition={50,100},ChallengeFragileCondition={50,100},ChallengeCleanReward={0,50},ChallengeExploreReward={0,50},ChallengeFragileReward={0,50},JobFragileBonus={0,20},JobLongBonus={0,20},GripUpgradePrice1={0,1000},GripUpgradePrice2={0,1000},GripUpgradePrice3={0,1000},GripUpgradeReduction={.05,.15}}
local values=table.clone(defaults)
function T.Get()return table.clone(values)end
function T.Start()
 if game.GameId==0 then return end -- Local place uses explicit defaults, no cloud dependency.
 task.spawn(function()
  local ok,snapshot=pcall(function()return game:GetService("ConfigService"):GetConfigAsync()end)
  if not ok then return end
  local function read()
   for key,fallback in pairs(defaults)do
    local value=snapshot:GetValue("PK_"..key) local b=bounds[key]
    values[key]=type(value)=="number" and value==value and math.clamp(value,b[1],b[2])or fallback
   end
  end
  pcall(read)
  snapshot.UpdateAvailable:Connect(function()pcall(function()snapshot:Refresh();read()end)end)
 end)
end
return T

