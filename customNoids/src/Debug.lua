local enabled = true
local Class = {}

if enabled == true then
	local testservice = game:GetService("TestService")
	
	Class["Warn"] = function (...)
		testservice:Warn(...)
	end
	
	Class["TimeToExecute"] = function(func, ...)
		local starttime = tick()
		local result = {func(...)}
		print("Function took " .. tick()-starttime .. " seconds to execute")
		return unpack(result)
	end
else
	setmetatable(Class, {
		__index = function (...)
			return function () return nil end
		end,
	})
end
		
return Class
