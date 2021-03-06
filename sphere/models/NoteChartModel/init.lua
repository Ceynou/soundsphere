local Class = require("aqua.util.Class")
local json = require("json")
local NoteChartFactory			= require("notechart.NoteChartFactory")

local NoteChartModel = Class:new()

NoteChartModel.path = "userdata/selected.json"

NoteChartModel.construct = function(self)
	self.selected = {1, 1}
end

NoteChartModel.load = function(self)
	local info = love.filesystem.getInfo(self.path)
	if info and info.size ~= 0 then
		local file = io.open(self.path, "r")
		self.selected = json.decode(file:read("*all"))
		file:close()

		self.noteChartSetEntry = self.cacheModel.cacheManager:getNoteChartSetEntryById(self.selected[1])
		self.noteChartEntry = self.cacheModel.cacheManager:getNoteChartEntryById(self.selected[2])
		if not self.noteChartEntry then
			return
		end
		self.noteChartDataEntry = self.cacheModel.cacheManager:getNoteChartDataEntry(self.noteChartEntry.hash, 1)
			or self.cacheModel.cacheManager:getEmptyNoteChartDataEntry(self.noteChartEntry.path)
	end
end

NoteChartModel.unload = function(self)
	local file = io.open(self.path, "w")
	file:write(json.encode(self.selected))
	return file:close()
end

NoteChartModel.selectNoteChartSet = function(self, id)
	self.selected[1] = id
	self.noteChartSetEntry = self.cacheModel.cacheManager:getNoteChartSetEntryById(id)

	if self.noteChartEntry and self.noteChartEntry.setId == id then
		return
	end

	self.noteChartEntry = self.cacheModel.cacheManager:getNoteChartsAtSet(id)[1]
	self.noteChartDataEntry = self.cacheModel.cacheManager:getNoteChartDataEntry(self.noteChartEntry.hash, 1)
		or self.cacheModel.cacheManager:getEmptyNoteChartDataEntry(self.noteChartEntry.path)
end

NoteChartModel.selectNoteChart = function(self, id)
	self.selected[2] = id
	self.noteChartEntry = self.cacheModel.cacheManager:getNoteChartEntryById(id)
	self.noteChartDataEntry = self.cacheModel.cacheManager:getNoteChartDataEntry(self.noteChartEntry.hash, 1)
	self.noteChartSetEntry = self.cacheModel.cacheManager:getNoteChartSetEntryById(self.noteChartEntry.setId)
		or self.cacheModel.cacheManager:getEmptyNoteChartDataEntry(self.noteChartEntry.path)
end

NoteChartModel.loadNoteChart = function(self, settings)
	local noteChartEntry = self.noteChartEntry

	if not noteChartEntry then
		return
	end

	local file = love.filesystem.newFile(noteChartEntry.path)
	file:open("r")
	local content = file:read()
	file:close()

	local status, noteCharts = NoteChartFactory:getNoteCharts(
		noteChartEntry.path,
		content,
		noteChartEntry.index,
		settings
	)
	if not status then
		error(noteCharts)
	end

	self.noteChart = noteCharts[1]

	return self.noteChart
end

NoteChartModel.unloadNoteChart = function(self)
	self.noteChart = nil
end

return NoteChartModel
