local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Class.new = function(realTrack)
	local self = {}
	self.Properties = {}
	self.realTrack = realTrack
	
	setmetatable(self, {
		__index = function (tab, index)
			if self.Properties[index] then
				return self.Properties[index]
			elseif Class[index] ~= nil then
				return Class[index]
			else
				local __, realTrackResult = pcall(function() return self.realTrack[index] end)
				if realTrackResult and type(realTrackResult) ~= "function" then
					return realTrackResult
				else
					a = function(self, ...)
						print("emulated function called: " .. index)
						return self.realTrack[index](self.realTrack, ...)
					end
					return a
				end
			end
		end,
		__newindex = function(table, index, value)
			self.Properties[index] = value
			self.realTrack[index] = value
		end,
	})

	return self
end


return Class