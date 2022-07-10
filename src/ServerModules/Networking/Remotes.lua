local HTTPS = game:GetService("HttpService")

return function(ImportantData)
	local LoadedModules = ImportantData.Mods
	local UserAccounts = ImportantData.UserAccounts
	
	local Remotes = game.ReplicatedStorage.Remotes
	
	local StatCache = {}
	
	local RemotesToFunctions = {
		[Remotes.GetSelfData] = function(Player: Player)
			local TO = tick() + 3

			-- This wait is here to insure the players data has loaded, might be shit idk
			-- who the fuck said i was a good programmer lmao

			repeat task.wait() until tick() > TO or UserAccounts[Player]
			return UserAccounts[Player]:getData()
		end,
		
		[Remotes.GetSelfStats] = function(Player: Player)
			if StatCache[Player] and StatCache[Player].FetchTime  + 60 > os.time() then return StatCache[Player] end
			
			local RobuxSpent, PurchaseCount = LoadedModules.Purchase:GetRobuxSpent(Player.UserId)
			
			local Stats = {
				RobuxSpent = RobuxSpent,
				PurchaseCount = PurchaseCount,
				FetchTime = os.time()
			}
			
			StatCache[Player] = Stats
			
			return Stats
		end,
		[Remotes.GetLeaderboard] = function(Player: Player, MapName: string)
			local Leaderboards = LoadedModules.Leaderboards
			
			local LeaderboardSize = 100

			local FetchedData = Leaderboards:Get(MapName:lower():gsub("%s","_"), LeaderboardSize)

			return HTTPS:JSONDecode(FetchedData.Body)
		end
	}
	
	for Remote, FunctionToRun in RemotesToFunctions do
		if Remote:IsA('RemoteEvent') then
			Remote.OnServerEvent:Connect(FunctionToRun)
		elseif Remote:IsA('RemoteFunction') then
			Remote.OnServerInvoke = FunctionToRun
		end
	end
end