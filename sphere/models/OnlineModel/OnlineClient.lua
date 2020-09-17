local enet = require("enet")
local json = require("json")
local http = require("aqua.http")
local Observable = require("aqua.util.Observable")
local Class = require("aqua.util.Class")

local OnlineClient = Class:new()

OnlineClient.path = "userdata/online.json"

OnlineClient.construct = function(self)
	self.observable = Observable:new()
	self.data = {}
end

OnlineClient.load = function(self)
	-- self.host = enet.host_create()
	-- self.server = self.host:connect(self.data.host)
end

OnlineClient.unload = function(self)
	-- self.server:disconnect()
	-- self.host:flush()
end

OnlineClient.update = function(self)
	-- local host = self.host
	-- local event = host:service()
	-- while event do
	-- 	self:internalReceive(event)
	-- 	event = host:service()
	-- end
end

OnlineClient.internalReceive = function(self, event)
	print(event.type)
end

OnlineClient.receive = function(self, event)

end

OnlineClient.send = function(self, event)
	return self.observable:send(event)
end

-- OnlineClient.login = function(self)
-- 	http.post()
-- end

return OnlineClient
