--[[
	Side: Skeleton
--]]
local Class = {}
Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Class.new = function()
	local self = setmetatable({}, Class)
	return self
end

function Class:PostLoad()
end

return Class