local Class				= require("aqua.util.Class")
local ScreenManager		= require("sphere.screen.ScreenManager")
local ResultView		= require("sphere.views.ResultView")
local ModifierModel		= require("sphere.models.ModifierModel")

local ResultController = Class:new()

ResultController.load = function(self)
	local modifierModel = ModifierModel:new()
	local view = ResultView:new()

	self.view = view

	view.modifierModel = modifierModel

	view.scoreSystem = self.scoreSystem
	view.noteChart = self.noteChart
	view.noteChartEntry = self.noteChartEntry
	view.noteChartDataEntry = self.noteChartDataEntry

	modifierModel:load()
	view:load()
end

ResultController.unload = function(self)
	self.view:unload()
end

ResultController.update = function(self, dt)
	self.view:update(dt)
end

ResultController.draw = function(self)
	self.view:draw()
end

ResultController.receive = function(self, event)
	self.controller:receive(event)
end

ResultController.receive = function(self, event)
	if event.name == "keypressed" and event.args[1] == "escape" then
		local SelectController = require("sphere.controllers.SelectController")
		return ScreenManager:set(SelectController:new())
	end
end

return ResultController
