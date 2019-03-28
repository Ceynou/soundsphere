local Class = require("aqua.util.Class")

local GraphicalNote = Class:new()

GraphicalNote.init = function(self)
	self.id
		 = self.startNoteData.inputType
		.. self.startNoteData.inputIndex
		.. ":"
		.. self.noteType
		
	self.inputId
		 = self.startNoteData.inputType
		.. self.startNoteData.inputIndex
		
	self.logicalNote = self.engine.sharedLogicalNoteData[self.startNoteData]
	self.logicalNote.graphicalNote = self
end

GraphicalNote.getCS = function(self)
	return self.engine.noteSkin:getCS(self)
end

GraphicalNote.updateNext = function(self, index)
	local nextNote = self.noteDrawer.noteData[index]
	if nextNote and nextNote.activated then
		return nextNote:update()
	end
end

return GraphicalNote
