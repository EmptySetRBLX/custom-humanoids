local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

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

function Class:IsA(type)
	print("TRYING TO FIND CHARACTER TYPE " .. type)
	return true
end

function Class:GetChildren()
	local children = self.Character:GetChildren()
	children[#children+1] = self.Humanoid
	return children
end

function Class:WaitForChild(child)
	if child == "Humanoid" then
		return self.Humanoid
	end
	return self.Character:WaitForChild(child)
end

function Class:FindFirstChild(child)
	if child == "Humanoid" then
		return self.Humanoid
	end
	return self.Character:FindFirstChild(child)
end

Class.findFirstChild = Class.FindFirstChild

return Class