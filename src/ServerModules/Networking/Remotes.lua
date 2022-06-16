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
			local FakeResult = {}

			for i = 1, 100 do
				table.insert(FakeResult, {
					User = if math.random(1,2) == 1 then 1551878098 else 41372847,
					Score = math.random(7100,20000)
				}
			)
			end

			return FakeResult
		end
	}
	
	for Remote, FunctionToRun in pairs(RemotesToFunctions) do
		if Remote:IsA('RemoteEvent') then
			Remote.OnServerEvent:Connect(FunctionToRun)
		elseif Remote:IsA('RemoteFunction') then
			Remote.OnServerInvoke = FunctionToRun
		end
	end
end