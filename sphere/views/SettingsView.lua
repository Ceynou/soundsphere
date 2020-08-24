local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local BackgroundManager	= require("sphere.ui.BackgroundManager")

local GUI = require("sphere.ui.GUI")

local SettingsList		= require("sphere.ui.SettingsList")
local CategoriesList	= require("sphere.ui.CategoriesList")
local SelectFrame		= require("sphere.ui.SelectFrame")

local SettingsView = Class:new()

SettingsView.construct = function(self)
    self.container = Container:new()
	self.gui = GUI:new()
end

SettingsView.load = function(self)
    local container = self.container
	local gui = self.gui

	gui.container = container
	gui:load("userdata/interface/settings.json")
	gui.observable:add(self)

	SettingsList.configModel = self.configModel

	SettingsList:init()
	CategoriesList:init()
	SettingsList.observable:add(self)
    CategoriesList.observable:add(self)

	gui:reload()

	SettingsList:load()
	CategoriesList:load()
	SelectFrame:reload()

	BackgroundManager:setColor({63, 63, 63})
end

SettingsView.unload = function(self)
	self.configModel:write()
end

SettingsView.receive = function(self, event)
    if event.name == "resize" then
		SettingsList:reload()
		CategoriesList:reload()
		SelectFrame:reload()
		return
	end

	SettingsList:receive(event)
	CategoriesList:receive(event)
	self.gui:receive(event)
end

SettingsView.update = function(self, dt)
    self.container:update()

	SettingsList:update()
	CategoriesList:update()

	self.gui:update()
end

SettingsView.draw = function(self)
	self.container:draw()

	SettingsList:draw()
	CategoriesList:draw()
	SelectFrame:draw()
end

return SettingsView