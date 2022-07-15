---------------------------------------
-- Variables
---------------------------------------
-- Services
local RS = game:GetService("RunService")
local HTTP = game:GetService("HttpService")

local ModulesFolder = game.ServerStorage.ServerModules
local DataFolder = game.ServerStorage.ServerModules.Data

-- Tables
local Mods = {}

local UserAccounts = {}
local UserChatTags = {}

local Leaderstats = {
	[1] = "LVL",
	[2] = "Wins",
	[3] = "Ropes",
}

shared.DatastoreName = "DevelopmentBuild"
shared.KeyFormat = "UID_%s"
---------------------------------------
-- Functions
---------------------------------------

function _Init()
	---------------------------------------
	-- Load all modules
	---------------------------------------
	Mods = {
		Music = require(ModulesFolder.Music),
		Account = require(ModulesFolder.Other.Account),
		Remotes = require(ModulesFolder.Networking.Remotes),
		Purchase = require(ModulesFolder.PurchaseHandler),
		WebServer = require(ModulesFolder.Networking.WebServer),
		Leaderboards = require(ModulesFolder.Networking.Leaderboards),
		JSONBin = require(ModulesFolder.Networking.JSONBin),
		Discord = require(ModulesFolder.Networking.Discord),
		ChatTag = require(ModulesFolder.Other.ChatTag),
	}

	-- Music Player

	coroutine.wrap(function()
		local Music = Mods.Music

		while true do
			Music:Next()
			Music:Play()

			repeat
				task.wait()
			until not Music.MusicObject.Playing
			print("Finished song")
			Music:Stop()
			task.wait(0.50)
		end
	end)()

	game.Players.PlayerAdded:Connect(function(Player: Player)
		local LS = Instance.new("Folder")
		LS.Name = "leaderstats"
		LS.Parent = Player

		UserChatTags[Player] = Mods.ChatTag:GetChatTagsForPlayer(Player)
		UserAccounts[Player] = Mods.Account:get(Player)

		for _, L in Leaderstats do
			local T = Instance.new("NumberValue")
			T.Name = L
			T.Parent = LS
		end
	end)

	Mods.Remotes({
		Mods = Mods,
		UserAccounts = UserAccounts,
		ChatTags = UserChatTags,
	})
end

_Init()
