load = function()
	scoreTable.score = 0
end

local maxScore = 1000000
local scale = 3.6
local unit = 1/60

local noteCount
getNoteCount = function(event)
	if noteCount then
		return noteCount
	end

	noteCount = 0
	noteCount = noteCount + (event.scoreNotesCount["ShortScoreNote"] or 0)
	noteCount = noteCount + (event.scoreNotesCount["LongScoreNote"] or 0)

	return noteCount
end

receive = function(event)
	if event.name ~= "ScoreNoteState" then
		return
	end

	local oldState, newState = event.oldState, event.newState
	if event.noteType == "ShortScoreNote" then
		local deltaTime = (event.currentTime - event.noteTime) / event.timeRate
		if newState == "passed" then
			scoreTable.score = scoreTable.score
				+ math.exp(-(deltaTime / unit / scale) ^ 2)
				/ getNoteCount(event)
				* maxScore
		elseif newState == "missed" then
		end
	elseif event.noteType == "LongScoreNote" then
		local deltaTime = (event.currentTime - event.noteStartTime) / event.timeRate
		if oldState == "clear" then
			if newState == "startPassedPressed" then
				scoreTable.score = scoreTable.score
					+ math.exp(-(deltaTime / unit / scale) ^ 2)
					/ getNoteCount(event)
					* maxScore
			elseif newState == "startMissed" then
			elseif newState == "startMissedPressed" then
			end
		elseif oldState == "startPassedPressed" then
			if newState == "startMissed" then
			elseif newState == "endMissed" then
			elseif newState == "endPassed" then
			end
		elseif oldState == "startMissedPressed" then
			if newState == "endMissedPassed" then
			elseif newState == "startMissed" then
			elseif newState == "endMissed" then
			end
		elseif oldState == "startMissed" then
			if newState == "startMissedPressed" then
			elseif newState == "endMissed" then
			end
		end
	end
end
