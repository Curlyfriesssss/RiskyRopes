local DSS: DataStoreService = game:GetService("DataStoreService")

export type Account = {
	XP: number,
	Wins: number,
	Cash: number,
	Playtime: number,
	AccountNotice: { Title: string, Message: string, State: boolean },
}

local account = {}
local MT = { __index = account }

local DSSEnabled = pcall(function()
	DSS:GetDataStore("RandomStore")
end)

local KeyFormat: string = shared.KeyFormat

if not DSSEnabled then
	DSS = require(script.Parent.LocalStores)
end

local Datastores = {
	Accounts = DSS:GetDataStore(shared.DatastoreName, "Accounts"),
}

local LoadedAccounts = {}

function account:getData()
	return {
		XP = self.XP,
		Wins = self.Wins,
		Cash = self.Cash,
		Ranking = self.Ranking,
		Playtime = self.Playtime,
		Ropes = self.Ropes,
		Networth = 0,
		AccountNotice = self.AccountNotice,
	}
end

function new()
	local self = {
		XP = 0,
		Ranking = 0,
		Wins = 0,
		Networth = 0,
		Ropes = 0,

		Cash = 0, -- Starting Money
		Playtime = 0,
		AccountNotice = { {
			Title = "test",
			Content = "hello boogle man",
		} },
		Notifications = {},
	}

	return setmetatable(self, MT)
end

function account.get(Player: Player)
	local Key = KeyFormat:format(Player.UserId)

	local PossibleData = Datastores.Accounts:GetAsync(Key) or new()

	LoadedAccounts[account] = PossibleData

	return PossibleData
end

function account:save() end

return account
