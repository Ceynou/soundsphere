local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local ScoreManager		= require("sphere.database.ScoreManager")
local Screen			= require("sphere.screen.Screen")
local ScreenManager		= require("sphere.screen.ScreenManager")
local ResultGUI			= require("sphere.screen.result.ResultGUI")
local ReplayManager		= require("sphere.screen.gameplay.ReplayManager")
local ModifierManager	= require("sphere.screen.gameplay.ModifierManager")

local ResultScreen = Screen:new()

ResultScreen.init = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	
	self.gui = ResultGUI:new()
	self.gui.container = self.container
end

ResultScreen.load = function(self)
end

ResultScreen.unload = function(self)
	self.gui:unload()
end

ResultScreen.update = function(self)
	Screen.update(self)

	self.gui:update()
end

ResultScreen.draw = function(self)
	Screen.draw(self)
end

ResultScreen.receive = function(self, event)
	if event.name == "resize" then
		self.gui:reload()
	elseif event.name == "keypressed" and event.args[1] == "escape" then
		ScreenManager:set(require("sphere.screen.select.SelectScreen"))
	end
	
	if event.name == "scoreSystem" then
		local scoreSystem = event.scoreSystem
		
		self.gui.scoreSystem = scoreSystem
		self.gui.noteChart = event.noteChart
		self.gui:load("userdata/interface/result.json")
		self.gui:receive({
			action = "updateMetaData",
			noteChartEntry = event.noteChartEntry,
			noteChartDataEntry = event.noteChartDataEntry
		})
		
		if scoreSystem.scoreTable.score > 0 and ReplayManager.mode ~= "replay" and not event.autoplay then
			local modifierSequence = ModifierManager:getSequence()
			local replayHash = ReplayManager:saveReplay(event.noteChartDataEntry, modifierSequence)
			ScoreManager:insertScore(scoreSystem.scoreTable, event.noteChartDataEntry, replayHash, modifierSequence)
		end
	end
end

return ResultScreen
