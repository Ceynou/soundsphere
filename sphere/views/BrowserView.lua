local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")

local BackgroundManager	= require("sphere.ui.BackgroundManager")

local GUI = require("sphere.ui.GUI")

local BrowserList		= require("sphere.ui.BrowserList")

local BrowserView = Class:new()

BrowserView.construct = function(self)
    self.container = Container:new()
	self.gui = GUI:new()
end

BrowserView.load = function(self)
    local container = self.container
	local gui = self.gui

    gui.cacheModel = self.cacheModel
    gui.collectionModel = self.collectionModel
    gui.container = container

	gui:load("userdata/interface/browser.json")
    gui.observable:add(self)

    BrowserList.collectionModel = self.collectionModel

	BrowserList:init()
	BrowserList.observable:add(self)
	BrowserList:load()

	BackgroundManager:setColor({127, 127, 127})
end

BrowserView.unload = function(self)
	BrowserList:unload()
end

BrowserView.receive = function(self, event)
	BrowserList:receive(event)
	self.gui:receive(event)
end

BrowserView.update = function(self, dt)
    self.container:update()

	BrowserList:update()

	self.gui:update()
end

BrowserView.draw = function(self)
	self.container:draw()

	BrowserList:draw()
end

return BrowserView