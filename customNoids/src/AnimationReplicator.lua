local event = require(game.ReplicatedStorage:WaitForChild("Classes"):WaitForChild("ClassGetter"):WaitForChild("Event"))
local serverAnimationController = require(script:WaitForChild("ServerAnimationController"))
local rEvent = game.ReplicatedStorage:WaitForChild("AnimationReplicator")

local animationControllers = {}

_G.authorizeAnimController = event.new()
_G.authorizeAnimController:connect(function(animationController, authorizedUser)
	local feAnimationHandler
	
	for i=1, #animationControllers do
		if animationControllers[i].animationController == animationController then
			feAnimationHandler = animationControllers[i]
			break
		end
	end
	
	if feAnimationHandler == nil then
		feAnimationHandler = serverAnimationController.new(animationController)
		animationControllers[#animationControllers + 1] = feAnimationHandler
	end
	
	feAnimationHandler:authorizePlayer(authorizedUser)
end)

rEvent.OnServerEvent:connect(function(player, data)
	local animController = data.AnimController
	if animController then
		for i=1, #animationControllers do
			if animationControllers[i].animationController == animController then
				animationControllers[i]:handleRemoteEvent(player, data)
				return
			end
		end
	else
		assert(false, "Animation replication called on a controller server cannot see or no one is authorized for")
	end
end)