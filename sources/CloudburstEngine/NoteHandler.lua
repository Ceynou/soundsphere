CloudburstEngine.NoteHandler = createClass()
local NoteHandler = CloudburstEngine.NoteHandler

local getClassForNote = function(noteData)
	if noteData.noteType == "ShortNote" then
		return CloudburstEngine.ShortLogicalNote
	elseif noteData.noteType == "LongNote" then
		return CloudburstEngine.LongLogicalNote
	elseif noteData.noteType == "SoundNote" then
		return CloudburstEngine.SoundNote
	end
end

NoteHandler.loadNoteData = function(self)
	self.noteData = {}
	
	for layerDataIndex in self.engine.noteChart:getLayerDataIndexIterator() do
		local layerData = self.engine.noteChart.layerDataSequence:getLayerData(layerDataIndex)
		for noteDataIndex = 1, layerData:getNoteDataCount() do
			local noteData = layerData:getNoteData(noteDataIndex)
			
			if noteData.columnIndex == self.columnIndex then
				local logicalNote = getClassForNote(noteData):new({
					noteData = noteData,
					noteHandler = self,
					engine = self.engine
				})
				
				if noteData.soundFileName then
					local soundFilePath = self.engine.fileManager:findFile(noteData.soundFileName, "audio")
					if soundFilePath then
						logicalNote.soundFilePath = soundFilePath
						audioManager:loadChunk(soundFilePath, "engine")
					end
				end
				
				table.insert(self.noteData, logicalNote)
				
				self.engine.sharedLogicalNoteData[noteData] = logicalNote
			end
		end
	end
	
	table.sort(self.noteData, function(a, b) return a.noteData.startTimePoint < b.noteData.startTimePoint end)

	for index, logicalNote in ipairs(self.noteData) do
		logicalNote.index = index
	end
	
	self.startNoteIndex = 1
	self.currentNote = self.noteData[1]
end

NoteHandler.setKeyState = function(self)
	self.keyBind = KeyBind[self.columnIndex] or tonumber(self.columnIndex)
	self.keyState = love.keyboard.isDown(self.keyBind)
end

NoteHandler.setCallbacks = function(self)
	if self.keyBind then
		soul.setCallback("keypressed", self, function(key)
			if key == self.keyBind then
				self.keyState = true
				self.currentNote.keyState = true
				
				if self.currentNote.soundFilePath then
					audioManager:playSound(self.currentNote.soundFilePath, "engine")
				end
			end
		end)
		soul.setCallback("keyreleased", self, function(key)
			if key == self.keyBind then
				self.keyState = false
				self.currentNote.keyState = false
			end
		end)
	end
end

NoteHandler.unsetCallbacks = function(self)
	soul.unsetCallback("keypressed", self)
	soul.unsetCallback("keyreleased", self)
end

NoteHandler.load = function(self)
	self:loadNoteData()
	self:setKeyState()
	self:setCallbacks()
end

NoteHandler.update = function(self)
	self.currentNote:update()
end

NoteHandler.unload = function(self)
	self:unsetCallbacks()
end