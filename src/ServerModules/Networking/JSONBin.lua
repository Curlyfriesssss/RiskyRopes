--[[
	This script is a module to easily use https://jsonbin.io
	It's primary function for Risky Ropes is to save runs in a readable json
	format and upload it as a URL to Discord

]]

local HTTPS = game:GetService("HttpService")

local Info = require(script.Parent.Parent.Data.JSONBinInfo)

local JSONBin = {}
JSONBin.__index = JSONBin

local self = {}

function JSONBin:GetURL(Response: any)
	return Info.Public_URL .. Response.metadata.id
end

function JSONBin:CreateBin(JSON: string)
	local Request = HTTPS:PostAsync(Info.URL, JSON, Enum.HttpContentType.ApplicationJson, false, Info.Headers)

	Request = HTTPS:JSONDecode(Request)

	return self:GetURL(Request)
end

setmetatable(self, JSONBin)

return self
