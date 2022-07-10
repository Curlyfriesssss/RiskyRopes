local MPS = game:GetService('MarketplaceService')
local DSS = game:GetService('DataStoreService')
local HTTPS = game:GetService('HttpService')

local purchase = {}
local MT = {__index = purchase}
local self = {}

export type ReceiptInfo = {PlayerId: number, PlaceIdWherePurchased: number, PurchaseId: string, ProductId: number, CurrencyType: Enum.CurrencyType, CurrencySpent: number}
export type ShortReceipt = {Spent: number, ProductId: number, PurchaseId: number}

local DSSEnabled = pcall(function()
	DSS:GetDataStore('RandomStore')
end)

if not DSSEnabled then DSS = require(script.Parent.Other.LocalStores) end

local PurchaseHistoryStore = DSS:GetDataStore(shared.DatastoreName, 'Purchases')


local KeyFormat = shared.KeyFormat

function logPurchase(Receipt: ReceiptInfo)
	coroutine.wrap(function()
		PurchaseHistoryStore:UpdateAsync(KeyFormat:format(Receipt.PlayerId),function(OldPurchase: {})
			OldPurchase = HTTPS:JSONDecode(OldPurchase or '[]')
			
			table.insert(OldPurchase, {
				Spent = Receipt.CurrencySpent,
				ProductId = Receipt.ProductId,
				PurchaseId = Receipt.PurchaseId
			})

			return HTTPS:JSONEncode(OldPurchase), {Receipt.PlayerId}
		end)
	end)()
end

MPS.ProcessReceipt = function(Receipt: ReceiptInfo)
	logPurchase(Receipt)
end

function purchase:GetRobuxSpent(UserId: number)
	local PurchaseHistory = HTTPS:JSONDecode(PurchaseHistoryStore:GetAsync(KeyFormat:format(UserId)) or '[]')
	
	local RobuxSpent = 0
	local PurchaseCount = #PurchaseHistory
	
	for _, Purchase: ShortReceipt in PurchaseHistory or {} do
		RobuxSpent += Purchase.Spent or 0
	end
	
	return RobuxSpent, PurchaseCount
end

function purchase:ProductPurchase(Player: Player, ProductId: number)
	MPS:PromptProductPurchase(Player,ProductId)
end

return setmetatable(self, MT)