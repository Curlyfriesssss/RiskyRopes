---------------------------------------
-- Variables
---------------------------------------
-- Services 
local RS = game:GetService('RunService')
local HTTP = game:GetService('HttpService')

local ModulesFolder = game.ServerStorage.ServerModules

-- Tables
local Mods = {}

local UserAccounts = {}

local Leaderstats = {
	[1] = 'LVL',
	[2] = 'Wins',
	[3] = 'Ropes'
}

shared.DatastoreName = 'DevelopmentBuild'
shared.KeyFormat = 'UID_%s'
---------------------------------------
-- Functions
---------------------------------------

function _Init()

	---------------------------------------
	-- Load all modules
	---------------------------------------
	Mods = {
		Music = require(ModulesFolder.Music),
		Account = require(ModulesFolder.Data.Account),
		Remotes = require(ModulesFolder.Networking.Remotes),
		Purchase = require(ModulesFolder.PurchaseHandler),
		WebServer = require(ModulesFolder.Networking.WebServer)
	}

	-- Music Player
	
	coroutine.wrap(function()
		local Music = Mods.Music
		
		while true do

			Music:Next()
			Music:Play()

			repeat wait() until not Music.MusicObject.Playing
		end
	end)()
	
	game.Players.PlayerAdded:Connect(function(Player: Player)
		local LS = Instance.new('Folder')
		LS.Name = 'leaderstats'
		LS.Parent = Player
		
		UserAccounts[Player] = Mods.Account.get(Player)
		
		for _, L in ipairs(Leaderstats) do
			local T = Instance.new('NumberValue')
			T.Name = L
			T.Parent = LS
		end

		
	end)
	
	Mods.Remotes({
		Mods = Mods,
		UserAccounts = UserAccounts
	})
end


_Init()