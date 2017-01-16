local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Class.new = function()
	local self = {}
	self.RealPlayerService = game:GetService('Players')
	setmetatable(self, {
		__index = function(tab, index)
			if Class[index] then
				return Class[index]
			end
			return self.RealPlayerService[index]
		end
	})
	return self
end

function Class:GetPlayers()
	return self.RealPlayerService:GetPlayers()
end

function Class:PostLoad()
	self.RealPlayer = self.RealPlayerService.LocalPlayer
	while self.RealPlayer == nil do
		wait()
		self.RealPlayer = self.RealPlayerService.LocalPlayer
	end
	self.LocalPlayer = self.Classes["Player"].new(self)
end


return Class