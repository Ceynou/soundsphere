local CoordinateManager	= require("aqua.graphics.CoordinateManager")
local CustomList		= require("sphere.ui.CustomList")

local NoteChartMenuList = CustomList:new()

NoteChartMenuList.x = 0
NoteChartMenuList.y = 0
NoteChartMenuList.w = 1
NoteChartMenuList.h = 1

NoteChartMenuList.textAlign = {x = "center", y = "center"}

NoteChartMenuList.sender = "NoteChartMenuList"
NoteChartMenuList.needFocusToInteract = false

NoteChartMenuList.buttonCount = 17
NoteChartMenuList.middleOffset = 9
NoteChartMenuList.startOffset = 9
NoteChartMenuList.endOffset = 9

NoteChartMenuList.init = function(self)
	self.cs = CoordinateManager:getCS(0.5, 0.5, 0.5, 0.5, "min")
end

NoteChartMenuList.load = function(self)
	self:addItems()
	self:reload()
end

NoteChartMenuList.addItems = function(self)
	local NoteChartMenu	= require("sphere.ui.NoteChartMenu")
	local NoteChartSetList	= require("sphere.ui.NoteChartSetList")

	local entry = NoteChartSetList.items[NoteChartSetList.focusedItemIndex].noteChartSetEntry

	local items = {
		{
			name = "open " .. entry.path,
			onClick = function()
				local mountPath = self.menu.mountModel:getRealPath(entry.path)
				local realPath =
					mountPath or
					love.filesystem.getSource() .. "/" .. entry.path
				love.system.openURL("file://" .. realPath)
				NoteChartMenu:hide()
			end
		},
		{
			name = "open " .. entry.path:match("^(.+)/.-$"),
			onClick = function()
				local mountPath = self.menu.mountModel:getRealPath(entry.path)
				local realPath =
					(mountPath and mountPath:match("^(.+)/.-$")) or
					love.filesystem.getSource() .. "/" .. entry.path:match("^(.+)/.-$")
				love.system.openURL("file://" .. realPath)
				NoteChartMenu:hide()
			end
		},
		{
			name = "recache new",
			onClick = function()
				self.menu.cacheModel:startUpdate(entry.path)
				NoteChartMenu:hide()
			end
		},
		{
			name = "recache all",
			onClick = function()
				self.menu.cacheModel:startUpdate(entry.path, true)
				NoteChartMenu:hide()
			end
		}
	}
	
	return self:setItems(items)
end

return NoteChartMenuList
