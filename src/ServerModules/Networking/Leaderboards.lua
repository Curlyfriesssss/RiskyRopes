local WebServer = require(script.Parent.WebServer)

local Leaderboards = {}

function Leaderboards:Get(MapName: string, Limit: number)
	return WebServer:Get(("api/leaderboard/%s/%s"):format(MapName, Limit))
end

return Leaderboards