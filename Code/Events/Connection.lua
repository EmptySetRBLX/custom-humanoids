local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Class.new = function(event, index, func)
	local self = setmetatable({}, Class)
	self.Event = event
	self.Index = index
	self.Func = func
	return self
end

function Class:Fire(...)
	self.Func(...)
end

function Class:Disconnect()
	self.Event:RemoveConnection(self.Index)
end

Class.disconnect = Class.Disconnect

return Class