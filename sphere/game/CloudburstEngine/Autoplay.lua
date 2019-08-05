local Autoplay = {}

Autoplay.processNote = function(self, note)
	if note.noteType == "ShortNote" then
		return self:processShortNote(note)
	elseif note.noteType == "SoundNote" then
		return self:processSoundNote(note)
	elseif note.noteType == "LongNote" then
		return self:processLongNote(note)
	end
end

Autoplay.processShortNote = function(self, note)
	local deltaTime = note.startNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime
	if deltaTime <= 0 then
		if note.noteType ~= "SoundNote" then
			note.noteHandler:clickKey()
			note.engine:playAudio(note.pressSounds, "fga")
		else
			note.engine:playAudio(note.pressSounds, "bga")
		end
		
		note.keyState = true
		
		note:process("exactly")
		note.score:processShortNoteState(note.state)
		
		if note.ended then
			note.score:hit(0)
		end
	end
end

Autoplay.processSoundNote = function(self, note)
	if note.pressSounds and note.pressSounds[1] then
		if note.startNoteData.timePoint:getAbsoluteTime() <= note.engine.currentTime then
			note.engine:playAudio(note.pressSounds, "bga")
		else
			return
		end
	end
	
	note.state = "skipped"
	return note:next()
end

Autoplay.processLongNote = function(self, note)
	local deltaStartTime = note.startNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime
	local deltaEndTime = note.endNoteData.timePoint:getAbsoluteTime() - note.engine.currentTime
	
	local nextNote = note:getNext()
	if deltaStartTime <= 0 and not note.keyState then
		if note.noteType ~= "SoundNote" then
			note.noteHandler:switchKey(true)
			note.engine:playAudio(note.pressSounds, "fga")
		else
			note.engine:playAudio(note.pressSounds, "bga")
		end
		
		note.keyState = true
		
		note:process("exactly", "none")
		note.score:processLongNoteState("startPassedPressed", "clear")
		
		if note.started and not note.judged then
			note.score:hit(0)
			note.judged = true
		end
	elseif deltaEndTime <= 0 and note.keyState or nextNote and nextNote:isHere() then
		if note.noteType ~= "SoundNote" then
			note.noteHandler:switchKey(false)
			note.engine:playAudio(note.releaseSounds, "fga")
		else
			note.engine:playAudio(note.releaseSounds, "bga")
		end
		
		note.keyState = false
		
		note:process("none", "exactly")
		note.score:processLongNoteState("endPassed", "startPassedPressed")
	end
end

return Autoplay
