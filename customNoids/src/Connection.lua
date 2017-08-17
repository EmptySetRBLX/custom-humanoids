---
-- Pure lua events
-- @module Connection

--- A connection
-- @type connection
-- @field Event#event Event The connected event
-- @field #number index Internal, do not use
-- @field #function func Function to execute when @{#connection.Fire} is called
local Class = {Event=nil, index=nil, func=nil}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

--- Create a new connection
-- @function [parent=#Connection] new
-- @callof #Connection
-- @return #connection the created connection
Class.new = function(event, index, func)
	local self = setmetatable({}, Class)
	self.Event = event
	self.Index = index
	self.Func = func
	return self
end

--- Fire the connection
-- @function [parent=#connection] Fire
-- @param #connection self
-- @param ... arguments
function Class:Fire(...)
	self.Func(...)
end

--- Removes this connection from its event
-- @function [parent=#connection] Disconnect
-- @param #connection self
function Class:Disconnect()
	self.Event:RemoveConnection(self.Index)
end

--- Removes this connection from its event
-- @function [parent=#connection] disconnect
-- @param #connection self
Class.disconnect = Class.Disconnect

return Class