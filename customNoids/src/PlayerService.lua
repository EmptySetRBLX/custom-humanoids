---
-- Player service wrapper
-- Player service wrapper used to trick stock scripts in to using custom noids
-- @module PlayerService

--- A player service wrapper
-- @type playerService
-- @field RealPlayerService The real player service object
-- @field RealPlayer 
-- @field PlayerWrapper#playerWrapper LocalPlayer Local player wrapper
local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})
--- Create a new player service wrapper
-- @function [parent=#PlayerService] new
-- @callof #PlayerService
-- @return #playerService the created player service wrapper
Class.new = function()
	local self = {}
	self.RealPlayerService = game:GetService('Players')
	setmetatable(self, {
		__index = function(tab, index)
			if Class[index] then
				return Class[index]
			end
			local __, realResult = pcall(function() return self.RealPlayerService[index] end)
			if type(realResult) ~= "function" then
				return realResult
			else
				return function(self, ...)
					return self.RealPlayerService[index](self.RealPlayerService, ...)
				end
			end
		end
	})
	return self
end

--- PostLoad function performed by ClassGetter
-- @function [parent=#playerService] PostLoad
function Class:PostLoad()
	self.RealPlayer = self.RealPlayerService.LocalPlayer
	while self.RealPlayer == nil do
		wait()
		self.RealPlayer = self.RealPlayerService.LocalPlayer
	end
	self.LocalPlayer = self.Classes["Player"].new(self)
end


return Class