---
-- Server side animation controller replicator
-- @module ServerAnimationController

--- A ServerAnimationController
-- @type serverAnimationController
-- @field #AnimationController animationController the real animation controller object
-- @field #table authorizedPlayers players which the server will accept requests from
-- @field #table loadedAnimations animationTracks loaded in to controller
local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})


--- Create a new serverAnimationController
-- @function [parent=#ServerAnimationController] new
-- @param #AnimationController animationController The animation controller
-- @callof #ServerAnimationController
-- @return #serverAnimationController the created serverAnimationController
Class.new = function(animationController)
	---A serverAnimationController
	-- @type serverAnimationController
	local self = setmetatable({}, Class)
	self.animationController = animationController
	self.authorizedPlayers = {}
	self.loadedAnimations = {}
	return self
end

function Class:handleRemoteEvent(player, data)
	if not self:isPlayerAuthorized(player) then
		return
	end
	if data.Type == "LoadAnimation" then
		if data.ID and data.Name then
			local animation = Instance.new("Animation")
			animation.Name = data.Name
			animation.AnimationId = data.ID
			self.loadedAnimations[string.match(data.ID, "%d+")] = self.animationController:LoadAnimation(animation)
		else
			assert(false, data.Type .. " replication request called with invalid arguements")
		end
	elseif data.ID then
		local animationTrack = self.loadedAnimations[string.match(data.ID, "%d+")]
		if animationTrack then
			if data.Type == "SetProperty" then
				if data.Property then --data.Value can technically be nil
					animationTrack[data.Property] = data.Value
				else
					assert(false, data.Type .. " replication request called with invalid arguements")
				end
			elseif data.Type == "PlayAnimation" then
				if data.Fadetime and data.Weight and data.Speed then
					animationTrack:Play(data.Fadetime, data.Weight, data.Speed)
				else
					assert(false, data.Type .. " replication request called with invalid arguements")
				end
			elseif data.Type == "StopAnimation" then
				if data.FadeTime then
					animationTrack:Stop(data.Fadetime)
				else
					assert(false, data.Type .. " replication request called with invalid arguements")
				end
			elseif data.Type == "AdjustSpeed" then
				if data.Value then
					animationTrack:AdjustSpeed(data.Value)
				else
					assert(false, data.Type .. " replication request called with invalid arguements")
				end
			elseif data.Type == "AdjustWeight" then
				if data.Weight and data.fadeTime then
					animationTrack:AdjustWeight(data.Weight, data.fadeTime)
				else
					assert(false, data.Type .. " replication request called with invalid arguements")
				end
			end
		else
			assert(false, "Attempt to replicate an animation ID that has not been loaded")
		end
	else
		assert(false, "Invalid animation request type: " .. data.Type)
	end
end

function Class:authorizePlayer(player)
	for i=1, #self.authorizedPlayers do
		if self.authorizedPlayers[i] == player then
			return
		end
	end
	self.authorizedPlayers[#self.authorizedPlayers+1] = player
end

function Class:deauthorizePlayer(player)
	for i=1, #self.authorizedPlayers do
		if self.authorizedPlayers[i] == player then
			table.remove(self.authorizedPlayers,i)
			return true
		end
	end
	return false
end

function Class:isPlayerAuthorized(player)
	for i=1, #self.authorizedPlayers do
		if self.authorizedPlayers[i] == player then
			return true
		end
	end
	return false
end


return Class