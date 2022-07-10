export type Account = {
	ID: number,
	Balance: number,
	XP: number,
	Wins: number,
	Inventory: string | table,
	Ropes: number,
	Networth: number,
	Playtime: number,
}

local HTTPS = game:GetService("HttpService")

local Networking = script.Parent.Parent.Networking
local WebServer = require(Networking.WebServer)

local KickMessage = "\n" .. "It appears the web server for Risky Ropes is currently down, please check back later."

local Account = {}
local self = {
	LoadedAccounts = {},
}

Account.__index = Account

function Account:get(Player: Player, KickIfFail: boolean)
	local PossibleData: Account = WebServer:Get(("/api/profile/%s"):format(Player.UserId))

	if PossibleData == "HttpError: ConnectFail" then -- HTTP failed, indicating the server is down
		Player:Kick(KickMessage)
		return
	end

	if PossibleData.StatusCode == 404 then -- Player does not have an account.
		if KickIfFail then
			Player:Kick(KickMessage)
		end

		return self:create(Player)
	end

	PossibleData = HTTPS:JSONDecode(PossibleData.Body)

	self.LoadedAccounts[Player] = PossibleData

	return PossibleData
end

function Account:create(Player: Player)
	local Result = WebServer:Post(("/api/profile/%s"):format(Player.UserId))

	return self:get(Player, true)
end

setmetatable(self, Account)

return self
