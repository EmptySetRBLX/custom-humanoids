local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Class.new = function()
	local self = setmetatable({}, Class)
	self.Connections = {}
	return self
end

function Class:connect(func)
	local ind = #self.Connections+1
	local connection = self.Classes["Connection"](self, ind, func)
	self.Connections[ind] = connection
	return connection
end

Class.Connect = Class.connect

function Class:Fire(...)
	for i=1, #self.Connections do
		self.Connections[i]:Fire(...)
	end
end

function Class:RemoveConnection(index)
	table.remove(self.Connections, index)
	for i=index, #self.Connections do
		self.Connections[i].Index = self.Connections[i].Index - 1
	end
end


return Class