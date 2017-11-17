---
-- AnimationTrack wrapper used to replicate over AnimationControllers
-- @module AnimationTrack

--- A AnimationTrack wrapper
-- @type animationTrack
-- @field #table Properties Internal table used so _newindex fires in order to replicate property changes
-- @field #RemoteEvent rEvent 
-- {Type = "LoadAnimation", ID = AnimationId, Name = AnimationName, AnimController = AnimController}              
-- {Type = "SetProperty", ID = AnimationId, Property = PropertyName, Value = value, AnimController = AnimController}                      
-- {Type = "PlayAnimation", ID = AnimationId, Fadetime = fadeTime, Weight = weight, Speed = speed, AnimController = AnimController}                 
-- {Type = "StopAnimation", ID = AnimationId, FadeTime = fadeTime, AnimController = AnimController}                    
-- {Type = "AdjustSpeed", ID = AnimationId, Value = speed, AnimController = AnimController}            
-- {Type = "AdjustWeight", ID = AnimationId,	Weight = weight, fadeTime = FadeTime, AnimController = AnimController}
local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Class.new = function(realCont, realTrack)
	local self = {}
	self.Properties = {}
	self.realCont = realCont
	self.realTrack = realTrack
	
	local args = {
			Type = "LoadAnimation",
			ID = self.realTrack.Animation.AnimationId,
			Name = self.realTrack.Animation.Name,
			AnimController = self.realCont
	}
	self.rEvent = game.ReplicatedStorage:WaitForChild("AnimationReplicator")
	self.rEvent:FireServer(args)
	
	setmetatable(self, {
		__index = function (tab, index)
			if self.Properties[index] then
				return self.Properties[index]
			elseif Class[index] ~= nil then
				return Class[index]
			else
				local __, realTrackResult = pcall(function() return self.realTrack[index] end)
				if realTrackResult ~= nil and type(realTrackResult) ~= "function" then
					return realTrackResult
				else
					local a = function(self, ...)
						print("emulated function called: " .. index)
						return self.realTrack[index](self.realTrack, ...)
					end
					return a
				end
			end
		end,
		__newindex = function(table, index, value)
			print("property " .. index .. " set to " .. value)
			self.Properties[index] = value
			self.realTrack[index] = value

			local args = {
				Type = "SetProperty",
				ID = self.realTrack.Animation.AnimationId,
				Property = index,
				Value = value,
				AnimController = self.realCont
			}
			self.rEvent:FireServer(args)
		end,
	})

	return self
end

function Class:Play(fadeTime, weight, speed)
	fadeTime = fadeTime or .100000001
	weight = weight or 1
	speed = speed or 1
	self.realTrack:Play(fadeTime, weight, speed)
	
	local args = {
			Type = "PlayAnimation",
			ID = self.realTrack.Animation.AnimationId,
			Fadetime = fadeTime,
			Weight = weight,
			Speed = speed,
			AnimController = self.realCont
	}
	self.rEvent:FireServer(args)
end


function Class:Stop(fadeTime)
	fadeTime = fadeTime or 0.100000001
	local args = {
			Type = "StopAnimation",
			ID = self.realTrack.Animation.AnimationId,
			FadeTime = fadeTime,
			AnimController = self.realCont
	}
	self.rEvent:FireServer(args)
end

function Class:AdjustSpeed(speed)
	self.realTrack:AdjustSpeed(speed or 1)
	local args = {
			Type = "AdjustSpeed",
			ID = self.realTrack.Animation.AnimationId,
			Value = speed or 1,
			AnimController = self.realCont
	}
	self.rEvent:FireServer(args)
end

function Class:AdjustWeight(weight, FadeTime)
	self.realTrack:AdjustWeight(weight or 1, FadeTime or 0.100000001)
	local args = {
			Type = "AdjustWeight",
			ID = self.realTrack.Animation.AnimationId,
			Weight = weight or 1,
			fadeTime = FadeTime or 0.100000001,
			AnimController = self.realCont
	}
	self.rEvent:FireServer(args)
end


return Class