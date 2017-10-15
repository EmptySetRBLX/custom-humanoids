---
-- Pure lua events
-- @module Character 

--- Character wrapper used to trick stock animation/movement scripts in to working with custom humanoid
-- @type character
-- @field #Instance Character The real character model
-- @field PlayerWrapper#playerWrapper PlayerClass The players player wrapper
-- @field #Player RealPlayer The players real player instance
-- @field Humanoid#humanoid Humanoid The characters custom humanoid
local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})
--- Create a new character wrapper
-- @function [parent=#Character] new
-- @param #Instance char The real character model
-- @param PlayerWrapper#playerWrapper player The players player wrapper
-- @return #character the created character wrapper
Class.new = function(char, player)
	local self = {}
	self.Character = char
	self.PlayerClass = player
	self.RealPlayer = self.PlayerClass.RealPlayer
	setmetatable(self, {
		__index = function(tab, index)
			if Class[index] then
				return Class[index]
			end
			return self.Character[index]
		end
	})
	self.Humanoid = self.Classes["Humanoid"](char, char:WaitForChild("HumanoidRootPart"), self)
	
	if self.RealPlayer.PlayerGui:FindFirstChild("Animate") then
		self.RealPlayer.PlayerGui:FindFirstChild("Animate"):Destroy()
	end
	script:WaitForChild("Animate"):Clone().Parent = self.RealPlayer.PlayerGui
	return self
end

--- Always returns true
-- @function [parent=#character] IsA
-- @param #character self
-- @param #string type
-- @return #boolean always true
function Class:IsA(type)
	print("TRYING TO FIND CHARACTER TYPE " .. type)
	return true
end

--- Injects the custom humanoid in to the @{#character.Character}s children
-- @return #table Children table
function Class:GetChildren()
	local children = self.Character:GetChildren()
	children[#children+1] = self.Humanoid
	return children
end

--- Injects the custom humanoid in to the @{#character.Character}s children, will yield
-- @return #Instance
-- @return Humanoid#humanoid
function Class:WaitForChild(child)
	if child == "Humanoid" then
		return self.Humanoid
	end
	return self.Character:WaitForChild(child)
end

--- Injects the custom humanoid in to the @{#character.Character}s children, will not yield
-- @return #Instance
-- @return Humanoid#humanoid
-- @return #nil
function Class:FindFirstChild(child)
	if child == "Humanoid" then
		return self.Humanoid
	end
	return self.Character:FindFirstChild(child)
end

--- Injects the custom humanoid in to the @{#character.Character}s children, will not yield
-- @param #character self
-- @param #Instance child
-- @return #Instance
-- @return Humanoid#humanoid
-- @return #nil
Class.findFirstChild = Class.FindFirstChild

return Class