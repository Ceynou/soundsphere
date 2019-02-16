local sqlite = require("ljsqlite3")
local NoteChartFactory = require("sphere.game.NoteChartManager.NoteChartFactory")
local CacheDataFactory = require("sphere.game.NoteChartManager.CacheDataFactory")
local ThreadPool = require("aqua.thread.ThreadPool")

local isNoteChart = function(path) return NoteChartFactory:isNoteChart(path) end
local getNoteChart = function(path) return NoteChartFactory:getNoteChart(path) end

local Cache = {}

Cache.dbpath = "userdata/cache.sqlite"
Cache.chartspath = "userdata/charts"

Cache.load = function(self)
	self.db = sqlite.open(self.dbpath)
	
	self.db:exec[[
		CREATE TABLE IF NOT EXISTS `cache` (
			`path` TEXT,
			`hash` TEXT,
			`container` INTEGER,
			
			`title` TEXT,
			`artist` TEXT,
			`source` TEXT,
			`tags` TEXT,
			
			`name` TEXT,
			`level` INTEGER,
			`creator` TEXT,
			
			`audioPath` TEXT,
			`stagePath` TEXT,
			`previewTime` REAL,
			`noteCount` INTEGER,
			`length` REAL,
			`bpm` REAL,
			`inputMode` TEXT,
			PRIMARY KEY (`path`)
		);
	]]
	
	self.insertStatement = self.db:prepare([[
		INSERT INTO `cache` (
			path,
			hash,
			container,
			title,
			artist,
			source,
			tags,
			name,
			level,
			creator,
			audioPath,
			stagePath,
			previewTime,
			noteCount,
			length,
			bpm,
			inputMode
		)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
	]])
	self.setContainerStatement = self.db:prepare([[
		INSERT OR IGNORE INTO `cache` (path, container, name)
		VALUES (?, -1, '');
	]])
	self.updateContainerStatement = self.db:prepare([[
		UPDATE `cache` SET `container` = ?, `name` = ? WHERE `path` == ?;
	]])
	
	self.rowByPathStatement = self.db:prepare([[
		SELECT * FROM `cache` WHERE path == ?
	]])
end

Cache.update = function(self, path, recursive, callback)
	if not self.isUpdating then
		ThreadPool:execute(
			[[
				local path, recursive = ...
				aquapackage = require("aqua.package")
				aquapackage.add("chartbase")
				local Cache = require("sphere.game.NoteChartManager.Cache")
				if not Cache.db then Cache:load() end
				Cache:lookup(path, recursive)
			]],
			{path, recursive},
			function(result)
				callback()
				self.isUpdating = false
			end
		)
		self.isUpdating = true
	end
	-- self:lookup(path, recursive)
end

Cache.rowByPath = function(self, path)
	return self.rowByPathStatement:reset():bind(path):step()
end

Cache.lookup = function(self, directoryPath, recursive)
	if love.filesystem.isFile(directoryPath) then
		return -1
	end
	
	local items = love.filesystem.getDirectoryItems(directoryPath)
	
	local chartPaths = {}
	local containers = 0
	
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isFile(path) and NoteChartFactory:isNoteChart(path) then
			chartPaths[#chartPaths + 1] = path
		end
	end
	
	if #chartPaths > 0 then
		print("processing directory", directoryPath)
		self:processNoteChartSet(chartPaths, directoryPath)
		return 1
	end
	
	for _, itemName in ipairs(items) do
		local path = directoryPath .. "/" .. itemName
		if love.filesystem.isDirectory(path) and (recursive or not self:rowByPath(path)) then
			if self:lookup(path, true) > 0 then
				containers = containers + 1
			end
		end
	end
	
	if containers > 0 then
		self:setContainer(directoryPath, 2)
		return 2
	end
	
	return -1
end

Cache.processNoteChartSet = function(self, chartPaths, directoryPath)
	self:setContainer(directoryPath, 1, "")
	
	local cacheDatas = CacheDataFactory:getCacheDatas(chartPaths)
	
	for i = 1, #cacheDatas do
		print("processing file", cacheDatas[i].path)
		self:setContainer(cacheDatas[i].path:match("^(.+)/.-"), 1, cacheDatas[i].title)
		self:addChart(cacheDatas[i])
	end
end

Cache.select = function(self)
	local data = {}
	
	for _, cacheData in pairs(self.data) do
		table.insert(data, cacheData)
	end
	
	local cacheDataIndex = 1
	
	return function()
		local cacheData = data[cacheDataIndex]
		cacheDataIndex = cacheDataIndex + 1
		
		return cacheData
	end
end

Cache.setContainer = function(self, path, container, name)
	self.setContainerStatement:reset():bind(path):step()
	self.updateContainerStatement:reset():bind(container, name, path):step()
end

Cache.addChart = function(self, cacheData)
	self.insertStatement:reset():bind(
		cacheData.path,
		cacheData.hash,
		cacheData.container,
		cacheData.title,
		cacheData.artist,
		cacheData.source,
		cacheData.tags,
		cacheData.name,
		cacheData.level,
		cacheData.creator,
		cacheData.audioPath,
		cacheData.stagePath,
		cacheData.previewTime,
		cacheData.noteCount,
		cacheData.length,
		cacheData.bpm,
		cacheData.inputMode
	):step()
end

return Cache