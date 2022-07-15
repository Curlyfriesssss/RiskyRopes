local HTTPS = game:GetService("HttpService")
local GroupService = game:GetService("GroupService")

local DiscordInfo = require(script.Parent.Parent.Data.DiscordWebhooks)

local SharedModules = game.ReplicatedStorage.Modules
local ExtraFunctions = require(SharedModules.UI.Functions)

return function(ImportantData)
	local LoadedModules = ImportantData.Mods
	local UserAccounts = ImportantData.UserAccounts

	local Remotes = game.ReplicatedStorage.Remotes

	local StatCache = {}

	local Leaderboards = LoadedModules.Leaderboards
	local JSONBin = LoadedModules.JSONBin
	local Discord = LoadedModules.Discord

	local LeaderboardSize = 100

	local RemotesToFunctions = {
		[Remotes.GetSelfData] = function(Player: Player)
			local TO = tick() + 3

			-- This wait is here to insure the players data has loaded, might be shit idk
			-- who the fuck said i was a good programmer lmao

			repeat
				task.wait()
			until tick() > TO or UserAccounts[Player]
			return UserAccounts[Player]
		end,

		[Remotes.GetSelfStats] = function(Player: Player)
			if StatCache[Player] and StatCache[Player].FetchTime + 60 > os.time() then
				return StatCache[Player]
			end

			local RobuxSpent, PurchaseCount = LoadedModules.Purchase:GetRobuxSpent(Player.UserId)

			local Stats = {
				RobuxSpent = RobuxSpent,
				PurchaseCount = PurchaseCount,
				FetchTime = os.time(),
			}

			StatCache[Player] = Stats

			return Stats
		end,
		[Remotes.GetLeaderboard] = function(Player: Player, MapName: string, Page: number)
			local FetchedData = Leaderboards:Get(MapName:lower():gsub("%s", "_"), LeaderboardSize, Page or 0)

			return HTTPS:JSONDecode(FetchedData.Body)
		end,
		[Remotes.SetScore] = function(Player: Player, MapName: string, Score: number)
			-- TODO: Implement some security here
			local Result = Leaderboards:Set(MapName, Player.UserId, Score)

			if Result.StatusCode == 200 then
				local Embed = Discord.embed()

				Embed.Title = "__New Time Achieved__"

				Embed:AddField("Username", ("`@%s`"):format(Player.Name), true)
				Embed:AddField("User ID", ("`%s`"):format(Player.UserId), true)

				Embed:AddField("Map", ("`%s`"):format(MapName), false)
				Embed:AddField("New Time", ("`%s`"):format(ExtraFunctions.ScoreToReadable(Score)), false)

				Embed.Color = Color3.new(0, 1, 0.517647)

				local Webhook = Discord.webhook(DiscordInfo.Webhooks[MapName:lower():gsub("%s", "_")])
				Webhook:send("", Embed)
			end
		end,
		[Remotes.GetChatTags] = function(_, Player: Player)
			return ImportantData.ChatTags[Player]
		end,
	}

	for Remote, FunctionToRun in RemotesToFunctions do
		if Remote:IsA("RemoteEvent") then
			Remote.OnServerEvent:Connect(FunctionToRun)
		elseif Remote:IsA("RemoteFunction") then
			Remote.OnServerInvoke = FunctionToRun
		end
	end
end
