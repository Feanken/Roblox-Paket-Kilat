-- Pure presentation scoring. Does not grant currency or change delivery records.
local R = {}
function R.New()
	return {current = 0, best = 0}
end
function R.Evaluate(result, targetSeconds, tuning)
	local clean = result.recoveryCount == 0 and result.condition >= tuning.RatingCleanCondition
	local excellent = clean and result.condition >= math.max(tuning.RatingCleanCondition, tuning.RatingExcellentCondition)
		and result.duration <= targetSeconds
	local stars = excellent and 3 or clean and 2 or 1
	return {stars = stars, name = stars == 3 and "ISTIMEWA" or stars == 2 and "RAPI" or "TUNTAS",
		clean = clean, onTime = result.duration <= targetSeconds}
end
function R.Advance(run, rating)
	local current = rating.clean and math.min(9999, run.current + 1) or 0
	return {current = current, best = math.max(run.best, current)}
end
return R
