-- Persistent courier progression. Only completed server-validated orders reach Advance.
local Career = {}
local WEEK_SECONDS = 7 * 24 * 60 * 60
local MONDAY_OFFSET = 3 * 24 * 60 * 60
local WEEK_BONUS = 90
local COMPLETE_MASK = 7
local EXPRESS_UNLOCK = 12

local ranks = {
	{count = 0, name = "Kurir Pemula", bonus = 0},
	{count = 3, name = "Kurir Kampung", bonus = 30},
	{count = EXPRESS_UNLOCK, name = "Kurir Kota", bonus = 60},
	{count = 30, name = "Kurir Lintas Distrik", bonus = 120},
	{count = 60, name = "Kurir Andalan", bonus = 200},
}
local circuits = {
	{
		name = "Rute Kota",
		goals = {
			{label = "Antar ke Menara Kilat", destination = "CBD01"},
			{label = "Antar ke Kantor Arsitek", destination = "BQ10"},
			{label = "Antar ke Galeri Tepi Air", destination = "BQ16"},
		},
	},
	{
		name = "Kurir Serba Bisa",
		goals = {
			{label = "Antar paket rapuh", packageType = "Rapuh"},
			{label = "Tuntaskan syarat kontrak", contract = true},
			{label = "Antar kiriman terakhir borongan", batch = true},
		},
	},
}

local function currentRank(count)
	for i = #ranks, 1, -1 do
		if count >= ranks[i].count then return ranks[i], ranks[i + 1] end
	end
end

local function currentWeek(saved, now)
	local week = math.floor((now + MONDAY_OFFSET) / WEEK_SECONDS)
	local mask = saved.week == week and saved.mask or 0
	return week, mask, circuits[week % #circuits + 1]
end

local function matches(goal, result)
	if goal.destination then return result.destinationId == goal.destination end
	if goal.packageType then return result.packageType == goal.packageType end
	if goal.contract then return result.contractSucceeded == true end
	return result.isBatch and result.batchIndex == result.batchTotal and result.batchBonusEligible
end

function Career.HasExpress(deliveryCount)
	return deliveryCount >= EXPRESS_UNLOCK
end

function Career.Snapshot(profile, now)
	local rank, nextRank = currentRank(profile.deliveryCount)
	local week, mask, circuit = currentWeek(profile.careerWeek, now)
	local goals, completed = {}, 0
	for i, goal in ipairs(circuit.goals) do
		local done = bit32.btest(mask, bit32.lshift(1, i - 1))
		goals[i] = {label = goal.label, done = done, destination = goal.destination,
			packageType = goal.packageType, contract = goal.contract, batch = goal.batch}
		if done then completed += 1 end
	end
	return {
		rank = rank.name,
		expressUnlocked = Career.HasExpress(profile.deliveryCount),
		expressRemaining = math.max(0, EXPRESS_UNLOCK - profile.deliveryCount),
		nextRank = nextRank and nextRank.name,
		nextRemaining = nextRank and nextRank.count - profile.deliveryCount,
		nextRankBonus = nextRank and nextRank.bonus,
		weeklyName = circuit.name,
		goals = goals,
		completed = completed,
		weeklyBonus = WEEK_BONUS,
		resetAt = (week + 1) * WEEK_SECONDS - MONDAY_OFFSET,
	}
end

function Career.Advance(profile, result, now)
	local _, nextRank = currentRank(profile.deliveryCount)
	local promotion = nextRank and profile.deliveryCount + 1 == nextRank.count and nextRank or nil
	local week, mask, circuit = currentWeek(profile.careerWeek, now)
	local newMask = mask
	if mask ~= COMPLETE_MASK and result.condition >= 90 and result.recoveryCount == 0 then
		for i, goal in ipairs(circuit.goals) do
			if matches(goal, result) then newMask = bit32.bor(newMask, bit32.lshift(1, i - 1)) end
		end
	end
	local bonus = mask ~= COMPLETE_MASK and newMask == COMPLETE_MASK and WEEK_BONUS or 0
	local progress
 if newMask ~= mask then
  progress = 0
  for i = 1, #circuit.goals do
   if bit32.btest(newMask, bit32.lshift(1, i - 1)) then progress += 1 end
  end
 end
 return {week = week, mask = newMask}, bonus, promotion and promotion.name, promotion and promotion.bonus or 0, progress
end

return Career
