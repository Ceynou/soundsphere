local Class				= require("aqua.util.Class")
local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local Image				= require("aqua.graphics.Image")

local InputImage = Class:new()

InputImage.loadGui = function(self)
	self.cs = CoordinateManager:getCS(unpack(self.data.cs))
	self.x = self.data.x
	self.y = self.data.y
	self.w = self.data.w
	self.h = self.data.h
	self.layer = self.data.layer
	self.pressed = self.data.pressed
	self.released = self.data.released
	self.inputType = self.data.inputType
	self.inputIndex = self.data.inputIndex
	self.blendMode = self.data.blendMode
	self.blendAlphaMode = self.data.blendAlphaMode

	self.keyBind = self.inputType .. self.inputIndex

	self.container = self.gui.container
	
	self:load()
end

InputImage.load = function(self)
	self.imageReleased = love.graphics.newImage(self.gui.root .. "/" .. self.released)
	self.imagePressed = love.graphics.newImage(self.gui.root .. "/" .. (self.pressed or self.released))
	self.drawable = Image:new({
		image = self.imageReleased,
		layer = self.layer,
		cs = self.cs,
		x = self.x,
		y = self.y,
		sx = 1,
		sy = 1,
		blendMode = self.blendMode,
		blendAlphaMode = self.blendAlphaMode,
		color = {255, 255, 255, 255}
	})
	self.drawable:reload()
	self.container:add(self.drawable)
end

InputImage.update = function(self)
	self.drawable.sx = self.cs:X(1) / self.drawable.image:getWidth() * self.w
	self.drawable.sy = self.cs:Y(1) / self.drawable.image:getHeight() * self.h
	self.drawable:reload()
end

InputImage.unload = function(self)
	self.container:remove(self.drawable)
end

InputImage.reload = function(self)
	self.drawable:reload()
end

InputImage.receive = function(self, event)
	local key = event.args and event.args[1]
	if key == self.keyBind then
		if event.name == "keypressed" then
			self.drawable.image = self.imagePressed
		elseif event.name == "keyreleased" then
			self.drawable.image = self.imageReleased
		end
	end
end

return InputImage
