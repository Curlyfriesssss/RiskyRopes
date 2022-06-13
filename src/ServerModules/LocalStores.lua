-- This module is purely for offline testing

local StoreService = {}
local FakeDatastore = {}

function StoreService:GetDataStore(StoreName: string, Scope: string)
    -- I didn't bother with scopes because I made this in 5 seconds

    return setmetatable({
        Name = StoreName,
        Data = {}
    }, {__index = FakeDatastore})
end

function FakeDatastore:GetAsync(Key)
    return self.Data[Key]
end

function FakeDatastore:SetAsync(Key, New)
    self.Data[Key] = New
end

return setmetatable({}, {__index = StoreService})