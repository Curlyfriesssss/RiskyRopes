export type WSInfo = { URL: string, Authorization: { U: string, P: string } }

local HTTPS = game:GetService("HttpService")

local Base64 = require(script.Parent.Parent.Other.Base64)
local WSInfo: WSInfo = require(script.Parent.WebServerInfo) -- Not included in GitHub for obvious reasons

local Connection = {}
local self = {}

Connection.__index = Connection

local BaseURL
local Authorization

local function dprint(msg: string)
	warn("[WEB-SERVER] " .. msg)
end

-- Load authorization
local success, err = pcall(function()
	BaseURL = WSInfo.URL
	Authorization = Base64.Encode(WSInfo.Authorization.U .. ":" .. WSInfo.Authorization.P)
end)

if not success then
	dprint("Authorization failed to load")
	return "failed"
end

local function generateRequest(page: string, method: string, body: table)
	method = method or "GET"
	local Body = HTTPS:JSONEncode(body or {})

	if not body or method == "GET" then
		Body = nil
	end

	return {
		Url = BaseURL .. page,
		Method = method,
		Body = Body,
		Headers = {
			["Authorization"] = "Basic " .. Authorization,
			["Content-Type"] = "application/json",
		},
	}
end

function DoRequest(Request: table)
	local Success, Result = pcall(function()
		return HTTPS:RequestAsync(Request)
	end)

	return Result
end

function Connection:Get(Page: string)
	local Request = generateRequest(Page, "GET")

	return DoRequest(Request)
end

function Connection:Post(Page: string, Body: any)
	local Request = generateRequest(Page, "POST")

	return DoRequest(Request)
end

self = { URL = BaseURL, Authorization = Authorization }

setmetatable(self, Connection)

return self
