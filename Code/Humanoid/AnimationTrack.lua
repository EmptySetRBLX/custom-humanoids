local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

local rEvent = game.ReplicatedStorage:WaitForChild("Spawning")

Class.new = function(realTrack)
	local self = {}
	self.Properties = {}
	self.realTrack = realTrack
	
	local args = {
			Type = "LoadAnimation",
			ID = self.realTrack.Animation.AnimationId,
			Name = self.realTrack.Animation.Name
	}
	rEvent:FireServer(args)
	
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
				Value = value
			}
			rEvent:FireServer(args)
		end,
	})

	return self
end

function Class:Play(fadeTime, weight, speed)
	fadeTime = fadeTime or 100000001
	weight = weight or 1
	speed = speed or 1
	self.realTrack:Play(fadeTime, weight, speed)
	
	local args = {
			Type = "PlayAnimation",
			ID = self.realTrack.Animation.AnimationId,
			Fadetime = fadeTime,
			Weight = weight,
			Speed = speed
	}
	rEvent:FireServer(args)
end


function Class:Stop(fadeTime)
	fadeTime = fadeTime or 0.100000001
	local args = {
			Type = "StopAnimation",
			ID = self.realTrack.Animation.AnimationId,
			FadeTime = fadeTime
	}
	rEvent:FireServer(args)
end

function Class:AdjustSpeed(speed)
	self.realTrack:AdjustSpeed(speed or 1)
	local args = {
			Type = "AdjustSpeed",
			ID = self.realTrack.Animation.AnimationId,
			Value = speed or 1
	}
	rEvent:FireServer(args)
end

function Class:AdjustWeight(weight, FadeTime)
	self.realTrack:AdjustWeight(weight or 1, FadeTime or 0.100000001)
	local args = {
			Type = "AdjustWeight",
			ID = self.realTrack.Animation.AnimationId,
			Weight = weight or 1,
			fadeTime = FadeTime or 0.100000001
	}
	rEvent:FireServer(args)
end


return Class