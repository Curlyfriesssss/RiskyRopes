local TradeCreator = {}
local Trade = {}

function TradeCreator.new()
	local self = {}

	self.Users = {}
	self.Items = { {}, {} }

	self.Date = os.time()

	return setmetatable(self, { __index = Trade })
end

function Trade:AssignUser(UserIndex: number, UserId: number)
	-- Adds a user
end

function Trade:RemoveUser(UserIndex: number)
	-- Removes a user
end

function Trade:CompleteTrade()
	-- Send the items/money to the correct users
end

function Trade:GenerateReport()
	local Report = ""

	return Report
end

return TradeCreator
