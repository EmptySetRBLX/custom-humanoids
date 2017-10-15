local eventModule = require("Event")
local testEvent = eventModule.new()
local connection = testEvent:connect(function() print("james is a faggot") end)
connection:disconnect()