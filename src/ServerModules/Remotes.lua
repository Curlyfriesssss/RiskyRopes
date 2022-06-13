return function(ImportantData)
	local LoadedModules = ImportantData.Mods
	local UserAccounts = ImportantData.UserAccounts
	
	local Remotes = game.ReplicatedStorage.Remotes
	
	local StatCache = {}
	
	local RemotesToFunctions = {
		[Remotes.GetSelfData] = function(Player: Player)
			local TO = tick() + 3
			repeat wait() until tick() > TO or UserAccounts[Player]
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
	}
	
	for Remote, FunctionToRun in pairs(RemotesToFunctions) do
		if Remote:IsA('RemoteEvent') then
			Remote.OnServerEvent:Connect(FunctionToRun)
		elseif Remote:IsA('RemoteFunction') then
			Remote.OnServerInvoke = FunctionToRun
		end
	end
end