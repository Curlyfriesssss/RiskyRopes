local WebServer = require(script.Parent.WebServer)

local Leaderboards = {}

function Leaderboards:Get(MapName: string, Limit: number, Page: number)
	Page -= 1
	
	return WebServer:Get(("api/leaderboard/%s/%s?page=%s"):format(MapName, Limit, Page))
end

return Leaderboards
