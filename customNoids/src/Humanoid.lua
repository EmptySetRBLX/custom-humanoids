---
-- Custom humanoids
-- @module Humanoid

--- A humanoid
-- @type humanoid
-- @field #Instance Character The character model
-- @field #Instance PrimaryPart The character models primary part
-- @field #Instance Parent Used for fakedChar, nil if not a players humanoid
-- @field #Instance AnimationCont The humanoids animation controller (must be called "AnimationController" in the root of the character)
-- @field #Instance CollisionChecker Internal part used to check collision. Kind of hacky, but rook would kill me if I built a full 3d collision engine
-- @field #Vector3 WalkToPoint The point the humanoid is walking towards (Used for NPCs only)
-- @field #Vector3 Move The direction the humanoid is moving in (Used for player characters only, overrides @{#humanoid.WalkToPoint}
-- @field #Vector3 FrontVector Internal vector used to keep track of what the lookVector of the primaryPart is
-- @field #String State The humanoids current state
local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

--- Create a new humanoid
-- @function [parent=#Humanoid] new
-- @param #Instance char The character model
-- @param #Instance primaryPart The primary part of the humanoid
-- @param Character#character fakedChar The faked character, only relevant if humanoid is the local players humanoid, otherwise set to nil
Class.new = function(char, primaryPart, fakedChar)
	local self = setmetatable({}, Class)
	self.Character = char
	self.PrimaryPart = primaryPart
	self.CollisionChecker = Instance.new("Part")
	self.CollisionChecker.Anchored = false
	self.CollisionChecker.CanCollide = false
	self.CollisionChecker.Touched:connect(function() end)--hacky af, adds a touch interest
	self.CollisionChecker.Size = self.PrimaryPart.Size
	self.Parent = fakedChar
	self.AnimationCont = self.Character:WaitForChild("AnimationController")--Instance.new("AnimationController")
	--self.AnimationCont.Parent = self.Character
	self:InitProperties()
	self:InitCustomEvents()
	self.WalkToPoint = nil
	self.Move = Vector3.new(0,0,0)
	self.FrontVector = Vector3.new(1,0,0)
	self.State = "Idle"
	return self
end

--- Returns true if type=="Humanoid" or "Instance"
-- @function [parent=#humanoid] IsA
-- @param #humanoid self
-- @param #string type
-- @return #boolean
function Class:IsA(type)
	return type == "Humanoid" or type == "Instance"
end

--- Function for internal use only, returns the angle between 2 vectors
-- @param #Vector3 a
-- @param #Vector3 b
-- @return #number
Class.calcAngleBetween = function(a,b)
	return math.deg(math.acos(a.unit:Dot(b.unit)))
end

--- Function for internal use estimates a what the final cframe of cf would be after falling
function Class:getProjectedPosition(cf)
	local colRay = Ray.new(cf.p, Vector3.new(0,-self.Height*4, 0))
	local iList = {self.Character}
	local partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
	while partHit do
		if partHit.CanCollide == true then
			return posHit+Vector3.new(0, self.Height, 0)
		end
		iList[#iList+1] = partHit
		partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
	end
end

function Class:AttemptMovement(step)
	local calcAngleBetween = self.calcAngleBetween
	local movementVec = self.Move or Vector3.new()
	if movementVec == Vector3.new() then
		print("movementVec being set to MoveTo")
		
		movementVec = (self.WalkToPoint - self.PrimaryPart.CFrame.p)
		movementVec = Vector3.new(movementVec.X, 0, movementVec.Z)
		if (movementVec).magnitude < 0.2 then
			self.WalkToPoint = nil
			return
		end
		movementVec = movementVec.unit
	else
		self.WalkToPoint = nil
	end
	if movementVec ~= Vector3.new() then
		self.State = "Running"
		self.FrontVector = movementVec
		
		local cPos = self.PrimaryPart.CFrame.p --foward check from torso
		local colRay = Ray.new(cPos, movementVec*self.WalkSpeed*step*2)
		local iList = {self.Character}
		local partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
		while partHit do
			if partHit.CanCollide == true then
				if(calcAngleBetween(Vector3.new(0,1,0), surfaceNorm) > self.MaxSlopeAngle) then
					return
				end
			end
			iList[#iList+1] = partHit
			partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
		end
		
		local cPos = self.PrimaryPart.CFrame.p - Vector3.new(0, self.Height-1.5, 0) --foward check from feet
		local colRay = Ray.new(cPos, movementVec*self.WalkSpeed*step*2)
		local iList = {self.Character}
		local partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
		while partHit do
			if partHit.CanCollide == true then
				if(calcAngleBetween(Vector3.new(0,1,0), surfaceNorm) > self.MaxSlopeAngle) then
					return
				end
			end
			iList[#iList+1] = partHit
			partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
		end
		
		local attemptCF = self.PrimaryPart.CFrame + (movementVec*step*self.WalkSpeed)
		local projectedHit = self:getProjectedPosition(attemptCF)
		--if projectedHit then
			self.CollisionChecker.CFrame = attemptCF
			self.CollisionChecker.Parent = game.Workspace
			local touching = self.CollisionChecker:GetTouchingParts()
			self.CollisionChecker.Parent = nil
			
			local hitParts = {}
			
			for i=1, #touching do
				if touching[i].CanCollide == true then
					hitParts[#hitParts+1] = touching[i]
				end
			end
			
			if #hitParts ~= 0 then
				for i=1, #hitParts do
					local currentDistance = (hitParts[i].CFrame.p-self.PrimaryPart.CFrame.p).magnitude
					local newDistance = (hitParts[i].CFrame.p-attemptCF.p).magnitude
					if newDistance < currentDistance then --if player is heading closer to colliding part, return
						return
					end
				end
			end
		--end
		
		
		self.PrimaryPart.CFrame = attemptCF
	else
		assert(false, "AttemptMovement() somehow called with no valid move direction")
	end
end

function Class:Fall(step)
	local cPos = self.PrimaryPart.CFrame.p
	local downRay = Ray.new(cPos, Vector3.new(0,-self.Height*2,0))
	local iList = {self.Character}
	local partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(downRay, iList)
	while partHit and partHit.CanCollide == false do
		iList[#iList+1] = partHit
		partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(downRay, iList)
	end
	
	if partHit then
		local minY = posHit.Y + self.Height 
		local attemptY = cPos.Y - (192.8*step*.3)
		local goY = attemptY
		if minY > goY then
			goY = minY
		else
			self.State = "Falling"
		end
		
		local newPos = Vector3.new(cPos.X, goY, cPos.Z)
		local backVec = -self.FrontVector
		local upVec = Vector3.new(0,1,0)
		local rightVec = backVec:Cross(upVec)
		local toMove = CFrame.new(newPos.X, goY, newPos.Z, 
			-rightVec.X, 0, backVec.X,
			-rightVec.Y, 1, backVec.Y,
			-rightVec.Z, 0, backVec.Z)
			
		--[[self.CollisionChecker.CFrame = toMove
		self.CollisionChecker.Parent = game.Workspace
		local touching = self.CollisionChecker:GetTouchingParts()
		self.CollisionChecker.Parent = nil
		
		for i=1, #touching do
			if touching[i].CanCollide == true then
				return
			end
		end--]]
		
		self.PrimaryPart.CFrame = toMove
	else
		self.State = "Falling"
		local newPos = Vector3.new(cPos.X, (cPos.Y - (192.8*step*.3)), cPos.Z)
		local backVec = -self.FrontVector
		local upVec = Vector3.new(0,1,0)
		local rightVec = backVec:Cross(upVec)
		if newPos.Y < -100 then
			newPos = Vector3.new(cPos.X, 5, cPos.Z)
		end
		local toMove = CFrame.new(newPos.X, newPos.Y, newPos.Z, 
			-rightVec.X, 0, backVec.X,
			-rightVec.Y, 1, backVec.Y,
			-rightVec.Z, 0, backVec.Z)
		
		--[[self.CollisionChecker.CFrame = toMove
		self.CollisionChecker.Parent = game.Workspace
		local touching = self.CollisionChecker:GetTouchingParts()
		self.CollisionChecker.Parent = nil
		
		for i=1, #touching do
			if touching[i].CanCollide == true then
				return
			end
		end--]]
		
		self.PrimaryPart.CFrame = toMove
	end
end

function Class:HeartBeat(step)
	assert(self.PrimaryPart, "No primary part defined, humanoid likely dead")
	self.PrimaryPart.Velocity = Vector3.new()
	local oldState = self.State
	self.State = "Idle"
	if self.Move ~= Vector3.new() or self.WalkToPoint ~= nil then
		self:AttemptMovement(step)
	end
	self:Fall(step)
	if oldState ~= self.State then
		if self.State == "Running" then
			self.Running:Fire(self.WalkSpeed)
		elseif self.State == "Falling" then
			self.FreeFalling:Fire()
		elseif self.State == "Idle" then
			self.Running:Fire(0)
		end
	end
	if self.Jump then
		print("JUMP")
		self.Jump = false
	end
end

function Class:SetMove(dir)
	assert(typeof(dir) == "Vector3", "Move() expects a Vector3 value")
	if dir == Vector3.new() then
		self.Move = Vector3.new()
	else
		self.Move = dir.unit
	end
end

function Class:MoveTo(point)
	assert(typeof(point) == "Vector3", "MoveTo() expects a Vector3 value")
	self.WalkToPoint = point
end

function Class:TakeDamage(damage)
	assert(typeof(damage) == "number", "TakeDamage() expects a number value")
	self.Health = self.Health - damage
	if self.Health > self.MaxHealth then
		self.Health = self.MaxHealth
		return
	elseif self.Health <= 0 then
		self.Health = 0
		self.Died:Fire()
		if self.Health <= 0 then
			self.Character:BreakJoints()
			game.Debris:AddItem(self.Character, 2.5)
		end
	end
end

function Class:GetPlayingAnimationTracks(...)
	return self.AnimationCont:GetPlayingAnimationTracks(...)
end

function Class:LoadAnimation(anim)
	local animTrack = self.AnimationCont:LoadAnimation(anim)
	return self.Classes.AnimationTrack.new(animTrack)
end

function Class:InitProperties()
	self.Health = 100
	self.MaxHealth = 100
	self.Jump = false
	self.JumpPower = 50
	self.WalkSpeed = 16
	self.MaxSlopeAngle = 45
	self.Height = 3
	self.WalkToPoint = nil
end

function Class:InitCustomEvents()
	local newe = self.Classes["Event"].new
	self.AnimationPlayed = self.AnimationCont.AnimationPlayed
	self.Climbing = newe()
	self.Died = newe()
	self.FreeFalling = newe()
	self.HealthChanged = newe()
	self.Jumping = newe()
	self.MovedToFinished = newe()
	self.Running = newe()
	self.Seated = newe()
	
	local RunService = game:GetService('RunService')
	self.HeartConnection = RunService.Heartbeat:connect(function(step)
		self:HeartBeat(step)
	end)
end


return Class