local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Class.new = function(playerService)
	local self = {}
	self.RealPlayer = playerService.RealPlayer
	setmetatable(self, {
		__index = function(tab, index)
			if Class[index] then
				return Class[index]
			end
			return self.RealPlayer[index]
		end
	})
	self.PlayerService = playerService
	self:SetupEvents()
	return self
end

function Class:IsA(type)
	print("TRYING TO FIND PLAYER TYPE " .. type)
	return true
end

function Class:GetMouse()
	return self.RealPlayer:GetMouse()
end

function Class:Move(walkDir, relToCamera)
	if walkDir.X == 0 and walkDir.Z == 0 then
		return
	end
	if relToCamera == false then
		self.Character.Humanoid:Move(walkDir)
	else
		local camCF = game.Workspace.Camera.CFrame
		local right = camCF.rightVector
		local up = Vector3.new(0,1,0)
		local back = right:Cross(up)
		local adjusted = CFrame.new(camCF.p.X, camCF.p.Y, camCF.p.Z,
			right.X, up.X, back.X,
			right.Y, up.Y, back.Y,
			right.Z, up.Z, back.Z)
		print(adjusted:vectorToWorldSpace(walkDir))
		self.Character.Humanoid:Move(adjusted:vectorToWorldSpace(walkDir))
	end
end

function Class:GetChildren()
	return self.RealPlayer:GetChildren()
end

function Class:WaitForChild(child)
	return self.RealPlayer:WaitForChild(child)
end

function Class:FindFirstChild(child)
	return self.RealPlayer:FindFirstChild(child)
end

function Class:SetupEvents()
	self.SpawningEvent = game.ReplicatedStorage:WaitForChild("Spawning")
	self.CharacterAdded = self.Classes["Event"].new()
	self.CharacterRemoving = self.Classes["Event"].new()
	self.SpawningEvent.OnClientEvent:connect(function(data)
		if data.Type == "Spawn" then
			self.Character = self.Classes["Character"].new(data.Char)
			local cam = game.Workspace.Camera
			cam.CameraSubject = self.Character:WaitForChild("Head")
			cam.CameraType = Enum.CameraType.Track
			self.CharacterAdded:Fire(data.Char)
		elseif data.Type == "Despawn" then
			self.CharacterRemoving:Fire(data.Char)
		else
			assert(false, "Spawn remote call with invalid type: " .. data.Type)
		end
	end)
	self.SpawningEvent:FireServer({Type = "Spawn"})
end


return Class