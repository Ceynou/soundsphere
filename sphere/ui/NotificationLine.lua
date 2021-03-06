local aquafonts			= require("aqua.assets.fonts")
local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Theme				= require("aqua.ui.Theme")
local spherefonts		= require("sphere.assets.fonts")

local NotificationLine = Class:new()

NotificationLine.backgroundColor = {31, 31, 31, 255}
NotificationLine.borderColor = {255, 255, 255, 255}
NotificationLine.textColor = {255, 255, 255, 255}
NotificationLine.maxlifetime = 1
NotificationLine.lifetime = 0

NotificationLine.construct = function(self)
	self.cs = CoordinateManager:getCS(0, 0, 0, 0, "all")
	
	self.state = 0
	
	self.button = Theme.Button:new({
		text = "",
		x = -0.1,
		y = 8 / 17,
		w = 1.2,
		h = 1 / 17,
		cs = self.cs,
		mode = "fill",
		backgroundColor = {unpack(self.backgroundColor)},
		borderColor = {unpack(self.borderColor)},
		textColor = {unpack(self.textColor)},
		textAlign = {x = "center", y = "center"},
		limit = 1.2,
		font = aquafonts.getFont(spherefonts.NotoSansRegular, 24)
	})
end

NotificationLine.load = function(self)
	self.button:reload()
	self.button.backgroundColor[4] = 0
	self.button.borderColor[4] = 0
	self.button.textColor[4] = 0
end

NotificationLine.notify = function(self, text)
	self.state = 1
	self.lifetime = 0
	self.button.backgroundColor[4] = self.backgroundColor[4]
	self.button.borderColor[4] = self.borderColor[4]
	self.button.textColor[4] = self.textColor[4]
	self.button:setText(text)
end

NotificationLine.update = function(self)
	if self.state == 1 then
		if self.lifetime < self.maxlifetime then
			self.lifetime = self.lifetime + love.timer.getDelta()
		else
			self.button.backgroundColor[4] = math.max(self.button.backgroundColor[4] - love.timer.getDelta() * 1000, 0)
			self.button.borderColor[4] = math.max(self.button.borderColor[4] - love.timer.getDelta() * 1000, 0)
			self.button.textColor[4] = math.max(self.button.textColor[4] - love.timer.getDelta() * 1000, 0)
			
			if self.button.textColor[4] == 0 then
				self.state = 0
				self.button.backgroundColor[4] = 0
				self.button.borderColor[4] = 0
				self.button.textColor[4] = 0
				self.lifetime = 0
			end
		end
	end
end

NotificationLine.draw = function(self)
	self.button:draw()
end

NotificationLine.receive = function(self, event)
	if event.name == "resize" then
		return self.button:reload()
	elseif event.name == "Notification" then
		return self:notify(event.message)
	end
end

return NotificationLine
