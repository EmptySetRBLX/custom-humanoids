---
-- Hacky 3d collision detection
-- @module CollisionDetector

local Class = {}
Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

--- Create a new collision detector
-- @function [parent=#CollisionDetector] new
-- @param ... size Either X,Y,Z cooridinates or a Vector3
-- @return #collisionDetector the created collisionDetector
Class.new = function(...)
	local self = setmetatable({}, Class)
	self.Part = Instance.new("Part")
	self.Part.Anchored = false
	self.Part.CanCollide = false
	local arg = {...}
	if #arg > 1 then
		self.Part.Size = Vector3.new(arg[1], arg[2], arg[3])
	else
		self.Part.Size = arg[1]
	end
	
	self.Part.Touched:connect(function() end) --Neccessary to add a touch interest
	
	return self
end

--- Tells the players humanoid to move in a direction
-- @function [parent=#collisionDetector] GetTouchingParts
-- @param #collisionDetector self
-- @param #CFrame cframe The new position the collision detector is checking
-- @param #table ignore Instances to ignore, can either be a table of parts or a singlular part
-- @param #boolean canCollideOnly If true, removes instances where CanCollide = false
-- @retrun #table Touching list of parts that the cframe is touching with current size
function Class:GetTouchingParts(cframe, ignore, canCollideOnly)
	self.Part.CFrame = cframe
	self.Part.Parent = game.Workspace
	local touching = self.Part:GetTouchingParts()
	self.Part.Parent = nil
	
	if #touching > 0 then
		if type(ignore) ~= "nil" then
			if type(ignore) == "table" then
				for i=#touching, 1, -1 do
					for k=1, #ignore do
						if touching[i]:IsDescendantOf(ignore[k]) then
							table.remove(touching, i)
							break
						end
					end
				end
			else
				for i=#touching, 1, -1 do
					if touching[i]:IsDescendantOf(ignore) then
						table.remove(touching, i)
					end
				end
			end
		end
		
		if canCollideOnly == true then
			for i=#touching, 1, -1 do 
				if touching[i].CanCollide == false then
					table.remove(touching, i)
				end
			end
		end
		
	end
	
	return touching
end

--- Tells the players humanoid to move in a direction
-- @function [parent=#collisionDetector] SetSize
-- @param #collisionDetector self
-- @param #Vector3 size The new size of the collision detector
function Class:SetSize(size)
	self.Part.Size = size
end


return Class