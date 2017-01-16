local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Class.new = function(char)
	local self = {}
	self.Character = char
	setmetatable(self, {
		__index = function(tab, index)
			if Class[index] then
				return Class[index]
			end
			return self.Character[index]
		end
	})
	self.Humanoid = self.Classes["Humanoid"](char, char:WaitForChild("HumanoidRootPart"), self)
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


return Class