---
-- Pure lua events
-- @module Event

--- A event
-- @type event
-- @field #table Connections internal table for holding connections
local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})


--- Create a new event
-- @function [parent=#Event] new
-- @callof #Event
-- @return #event the created event
Class.new = function()
	---A event
	-- @type event
	local self = setmetatable({}, Class)
	self.Connections = {}
	self.ConnectionClass = (self.Classes and self.Classes["Connection"]) or require(script:WaitForChild("Connection"))
	return self
end

--- Create a new connection
-- @function [parent=#event] connect
-- @param #event self
-- @param #function func
-- @return Connection#connection
function Class:connect(func)
	local ind = #self.Connections+1
	local connection = self.ConnectionClass(self, ind, func)
	self.Connections[ind] = connection
	return connection
end

--- Create a new connection
-- @function [parent=#event] Connect
-- @param #event self
-- @param #function func
-- @return Connection#connection
Class.Connect = Class.connect

--- Fire the event
-- @function [parent=#event] Fire
-- @param #event self
-- @param ... arguments
function Class:Fire(...)
	for i=1, #self.Connections do
		self.Connections[i]:Fire(...)
	end
end

--- Remove a connection from @{#event.Connections} internal use only
-- @function [parent=#event] RemoveConnection
-- @param #event self
-- @param #number index
function Class:RemoveConnection(index)
	table.remove(self.Connections, index)
	for i=index, #self.Connections do
		self.Connections[i].Index = self.Connections[i].Index - 1
	end
end


return Class