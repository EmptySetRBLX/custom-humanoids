local Class = {}

Class.__index = Class

setmetatable(Class, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Class.new = function(char, primaryPart, fakedChar)
	local self = setmetatable({}, Class)
	self.Character = char
	self.PrimaryPart = primaryPart
	self.Torso = primaryPart
	self.Parent = fakedChar
	self.AnimationCont = self.Character:WaitForChild("AnimationController")--Instance.new("AnimationController")
	--self.AnimationCont.Parent = self.Character
	self:InitProperties()
	self:InitFunctions()
	self:InitCustomEvents()
	self.WalkToPoint = nil
	self.Move = Vector3.new(0,0,0)
	self.FrontVector = Vector3.new(1,0,0)
	self.State = "Idle"
	return self
end

function Class:IsA(type)
	return type == "Humanoid" or type == "Instance"
end

Class.calcAngleBetween = function(a,b)
	return math.deg(math.acos(a.unit:Dot(b.unit)))
end

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
		
		cPos = self.PrimaryPart.CFrame.p - Vector3.new(0, self.Height-1.5, 0) --foward check from feet
		colRay = Ray.new(cPos, movementVec*self.WalkSpeed*step*2)
		iList = {self.Character}
		partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
		while partHit do
			if partHit.CanCollide == true then
				if(calcAngleBetween(Vector3.new(0,1,0), surfaceNorm) > self.MaxSlopeAngle) then
					return
				end
			end
			iList[#iList+1] = partHit
			partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
		end
		
		--[[cPos = self.PrimaryPart.CFrame.p + Vector3.new(0, self.Height+0.1, 0) --foward check from head
		colRay = Ray.new(cPos, self.Move*self.WalkSpeed*step*2)
		iList = {self.Character}
		partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
		while partHit do
			if partHit.CanCollide == true then
				if(calcAngleBetween(Vector3.new(0,1,0), surfaceNorm) > self.MaxSlopeAngle) then
					return
				end
			end
			iList[#iList+1] = partHit
			partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
		end--]]

		
		local attemptCF = self.PrimaryPart.CFrame + (movementVec*step*self.WalkSpeed)
		local projectedHit = self:getProjectedPosition(attemptCF)
		if projectedHit then
			colRay = Ray.new(projectedHit, Vector3.new(0, self.Height, 0)) --upwards check
			iList = {self.Character}
			partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
			while partHit do
				if partHit.CanCollide == true then
					local p1 = Instance.new("Part")
					p1.Anchored = true
					p1.Size = Vector3.new(0.2,0.2,0.2)
					p1.CanCollide = false
					local p2 = p1:Clone()
					p1.CFrame = CFrame.new(projectedHit)
					p2.CFrame = CFrame.new(posHit)
					p1.Parent = game.Workspace
					--p2.Parent = game.Workspace
					game:GetService("Debris"):AddItem(p1,3)
					--game:GetService("Debris"):AddItem(p2,3)
					return
				end
				iList[#iList+1] = partHit
				partHit, posHit, surfaceNorm = game.Workspace:FindPartOnRayWithIgnoreList(colRay, iList)
			end
		end
		
		
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
		self.PrimaryPart.CFrame = CFrame.new(newPos.X, goY, newPos.Z, 
			-rightVec.X, 0, backVec.X,
			-rightVec.Y, 1, backVec.Y,
			-rightVec.Z, 0, backVec.Z)
	else
		self.State = "Falling"
		local newPos = Vector3.new(cPos.X, (cPos.Y - (192.8*step*.3)), cPos.Z)
		local backVec = -self.FrontVector
		local upVec = Vector3.new(0,1,0)
		local rightVec = backVec:Cross(upVec)
		if newPos.Y < -100 then
			newPos = Vector3.new(cPos.X, 5, cPos.Z)
		end
		self.PrimaryPart.CFrame = CFrame.new(newPos.X, newPos.Y, newPos.Z, 
			-rightVec.X, 0, backVec.X,
			-rightVec.Y, 1, backVec.Y,
			-rightVec.Z, 0, backVec.Z)
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

function Class:InitFunctions()
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