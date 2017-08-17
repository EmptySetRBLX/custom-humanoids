--[[
	Side: Skeleton
	
	Returns a table with all classes, initializes services
--]]
if _G.Classes then
	return _G.Classes
end
local ClassGetter = {}

local libraries = require(script.Parent.Libraries)
ClassGetter["Services"] = {}

local IsAFunc = function(self, class)
	for i=1, #self.Type do
		if self.Type[i] == class then
			return true
		end
	end
	return false
end

local GetService = function(self, service)
	return assert(self.Services[service], "Attempt to get service \"" .. service .. "\" failed, service DNE")
end

ClassGetter.GetService = GetService

function getclasses(ctable)
	for i=1, #ctable do
		if ctable[i]:IsA("ModuleScript") then
			ClassGetter[ctable[i].Name] = require(ctable[i])
			ClassGetter[ctable[i].Name]["Libraries"] = libraries
			ClassGetter[ctable[i].Name]["Classes"] = ClassGetter
			ClassGetter[ctable[i].Name]["Type"] = {ctable[i].Name}
			--ClassGetter[ctable[i].Name]["IsA"] = IsAFunc
			ClassGetter[ctable[i].Name]["GetService"] = GetService
			ClassGetter[ctable[i].Name]["Services"] = ClassGetter["Services"]
		end
		getclasses(ctable[i]:GetChildren())
	end
end

local children = script:GetChildren()
getclasses(children)

--for key,value in pairs(t) do print(key,value) end


--ClassGetter["Settings"]()

function getservices(service) --im so happpy, haha
	if service:IsA("ModuleScript") then --happy go lucky me
		local services = ClassGetter["Services"] --things that bother you
		local servicetable = require(service) --never bother me :D
		servicetable["Libraries"] = libraries
		servicetable["Classes"] = ClassGetter
		local finalservice = servicetable()
		services[service.Name] = finalservice
	end
	local children = service:GetChildren()
	for i=1, #children do
		getservices(children[i])
	end
end

children = script.Parent.Services:GetChildren()
for k=1, #children do
	getservices(children[k])
end

for k,v in pairs(ClassGetter["Services"]) do
	if ClassGetter["Services"][k].PostLoad ~= nil then
		ClassGetter["Services"][k]:PostLoad()
	end
end
_G.Classes = ClassGetter
return ClassGetter
