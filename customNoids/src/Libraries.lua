local Class = {}


	local children = script:GetChildren()
	
	for i=1, #children do
		Class[children[i].Name] = require(children[i])
	end

return Class
