local WebServer = require(script.Parent.WebServer)

local Leaderboards = {}
Leaderboards.__index = Leaderboards

local self = {}

local JSONBin = require(script.Parent.JSONBin)
local Discord = require(script.Parent.Discord)

function Leaderboards:Get(MapName: string, Limit: number, Page: number)
	Page -= 1

	return WebServer:Get(("api/leaderboard/%s/%s?page=%s"):format(MapName, Limit, Page))
end

function Leaderboards:Set(MapName: string, UserId: number, Score: number)
	return WebServer:Post(("/api/updatescore/%s/%s?score=%s"):format(MapName, UserId, Score))
end

setmetatable(self, Leaderboards)

return self
