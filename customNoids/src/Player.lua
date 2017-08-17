---
-- Custom player wrapper
-- Custom player wrapper used to trick stock animation/camera/movement scripts in to working with custom humanoid
-- @module PlayerWrapper

--- A player wrapper
-- @type playerWrapper
-- @field RealPlayer Real player object
-- @field PlayerService#playerService PlayerService Emulated player service
-- @field #RemoteEvent SpawningEvent To server {Type = "Spawn"} from server {Type = "Spawn", Char = Instance}, {Type = "Despawn"}
-- @field Event#event CharacterAdded fired when character added
-- @field Event#event CharacterRemoving fired when character removing
-- @field Character#character Character Character wrapper
local Class = {}
Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

--- Create a new wrapper
-- @function [parent=#PlayerWrapper] new
-- @param PlayerService#playerService playerService Emulated player service
-- @return #playerWrapper the created playerWrapper
Class.new = function(playerService)
	local self = {}
	self.RealPlayer = playerService.RealPlayer
	setmetatable(self, {
		__index = function(tab, index)
			if Class[index] then
				return Class[index]
			end
			local __, realResult = pcall(function() return self.RealPlayer[index] end)
			if type(realResult) ~= "function" then
				return realResult
			else
				return function(self, ...)
					return self.RealPlayer[index](self.RealPlayer, ...)
				end
			end
		end
	})
	self.PlayerService = playerService
	self:SetupEvents()
	return self
end

--- Tells the players humanoid to move in a direction
-- @function [parent=#playerWrapper] Move
-- @param #playerWrapper self
-- @param #Vector3 walkDir Direction to walk in
-- @param #boolean relToCamera Is the movement relative to the players camera?
function Class:Move(walkDir, relToCamera)
	if walkDir.X == 0 and walkDir.Z == 0 then
		self.Character.Humanoid:SetMove(Vector3.new(0))
		return
	end
	if relToCamera == false then
		self.Character.Humanoid:SetMove(walkDir)
	else
		local camCF = game.Workspace.Camera.CFrame
		local right = camCF.rightVector
		local up = Vector3.new(0,1,0)
		local back = right:Cross(up)
		local adjusted = CFrame.new(camCF.p.X, camCF.p.Y, camCF.p.Z,
			right.X, up.X, back.X,
			right.Y, up.Y, back.Y,
			right.Z, up.Z, back.Z)
		self.Character.Humanoid:SetMove(adjusted:vectorToWorldSpace(walkDir))
	end
end

--- Internal function, sets up remoteEvent and CharacterAdded/Removing events
-- @function [parent=#playerWrapper] Fire
-- @param #playerWrapper self
function Class:SetupEvents()
	self.SpawningEvent = game.ReplicatedStorage:WaitForChild("Spawning")
	self.CharacterAdded = self.Classes["Event"].new()
	self.CharacterRemoving = self.Classes["Event"].new()
	self.SpawningEvent.OnClientEvent:connect(function(data)
		if data.Type == "Spawn" then
			self.Character = self.Classes["Character"].new(data.Char, self)
			local cam = game.Workspace.Camera
			cam.CameraSubject = self.Character:WaitForChild("Head")
			cam.CameraType = Enum.CameraType.Custom
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