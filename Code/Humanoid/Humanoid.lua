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
	self.AnimationCont = Instance.new("AnimationController")
	self.AnimationCont.Parent = self.Character
	self:InitProperties()
	self:InitFunctions()
	self:InitCustomEvents()
	self.WalkToPoint = Vector3.new(-53, 1, -92)--self.PrimaryPart.CFrame.p
	return self
end

function Class:IsA(type)
	return type == "Humanoid" or type == "Instance"
	--return true
end

function Class:AttemptMovement(step)
	local distance = (Vector2.new(self.WalkToPoint.X, self.WalkToPoint.Z) - Vector2.new(self.PrimaryPart.Position.X, self.PrimaryPart.Position.Z)).magnitude
	local Vec2Unit = (Vector2.new(self.WalkToPoint.X, self.WalkToPoint.Z) - Vector2.new(self.PrimaryPart.Position.X, self.PrimaryPart.Position.Z)).unit
	
	if distance<0.1 then
		self.WalkToPoint = nil
		self.MovedToFinished:Fire()
		return
	end
	print(self.WalkToPoint)
	local function calcAngleBetween(a,b)
		return math.deg(math.acos(a.unit:Dot(b.unit)))
	end
	
	local distanceToMove = step*self.WalkSpeed
	local wallCheckRay = Ray.new(self.PrimaryPart.Position, Vector3.new(Vec2Unit.X, 0, Vec2Unit.Y))
	local wallHit, __, surfaceNorm = game.Workspace:FindPartOnRay(wallCheckRay, self.Character)
	
	if wallHit then
		if wallHit.CanCollide == false then
			local partsHit = {self.Character, wallHit}
			while true do
				local newPHit = game.Workspace:FindPartOnRayWithIgnoreList(wallCheckRay, partsHit)
				if newPHit then
					if newPHit.CanCollide == false then
						partsHit[#partsHit+1] = newPHit
					else
						if(calcAngleBetween(Vector3.new(0,1,0), surfaceNorm) > self.MaxSlopeAngle) then
							return
						else
							break
						end
					end
				else
					break
				end
			end
		else
			if(calcAngleBetween(Vector3.new(0,1,0), surfaceNorm) > self.MaxSlopeAngle) then
				return
			end
		end
	end
	self.PrimaryPart.CFrame = self.PrimaryPart.CFrame + (Vector3.new(Vec2Unit.X, 0, Vec2Unit.Y)*distanceToMove)
	local downRay = Ray.new(self.PrimaryPart.Position, Vector3.new(0,-99.1*step,0)*3)
	local ignoreL = {self.Character}
	local partHit, posHit = game.Workspace:FindPartOnRayWithIgnoreList(downRay, ignoreL)
	while partHit and partHit.CanCollide == false do
		ignoreL[#ignoreL + 1] = partHit
		partHit, posHit = game.Workspace:FindPartOnRayWithIgnoreList(downRay, ignoreL)
	end
	local attemptToGo = self.PrimaryPart.CFrame - Vector3.new(0, 99.1*step,0)
	if posHit then
		local col = (posHit.Y + self.Height)
		if attemptToGo.p.Y > col then
			self.PrimaryPart.CFrame = self.PrimaryPart.CFrame - Vector3.new(0, 99.1*step,0)
		else
			self.PrimaryPart.CFrame = self.PrimaryPart.CFrame + Vector3.new(0, (col - self.PrimaryPart.Position.Y), 0)
			local forwardVec = (self.PrimaryPart.CFrame.p - self.WalkToPoint).unit
			local upVec = Vector3.new(0,1,0)
			local rightVec = upVec:Cross(forwardVec)
			local pos = self.PrimaryPart.CFrame.p
			self.PrimaryPart.CFrame = CFrame.new(pos.X, pos.Y, pos.Z, 
												 rightVec.X, upVec.X, forwardVec.X,
												 rightVec.Y, upVec.Y, forwardVec.Y,
												 rightVec.Z, upVec.Z, forwardVec.Z)
		end
		--self.PrimaryPart.CFrame = self.PrimaryPart.CFrame + Vector3.new(0, (posHit.Y + self.Height - self.PrimaryPart.Position.Y), 0)
	else
		self.PrimaryPart.CFrame = self.PrimaryPart.CFrame - Vector3.new(0, 99.1*step,0)
	end
	
	--print("Y SET TO: " .. self.PrimaryPart.Position.Y)
end

function Class:HeartBeat(step)
	assert(self.PrimaryPart, "No primary part defined, humanoid likely dead")
	if self.WalkToPoint ~= nil then
		self:AttemptMovement(step)
	end
end

function Class:Move(dir)
	self.WalkToPoint = self.PrimaryPart.CFrame.p+dir
end

function Class:MoveTo(point)
	assert(typeof(point) == "Vector3", "Move to expects a Vector3 value")
	self.WalkToPoint = point
end

function Class:TakeDamage(damage)
	assert(typeof(damage) == "number", "Take damage expects a number value")
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
	self.GetPlayingAnimationTracks = self.AnimationCont.GetPlayingAnimationTracks
	self.LoadAnimation = self.AnimationCont.LoadAnimation
end

function Class:InitProperties()
	self.Health = 100
	self.MaxHealth = 100
	self.Jump = false
	self.JumpPower = 50
	self.WalkSpeed = 16
	self.MaxSlopeAngle = 89
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