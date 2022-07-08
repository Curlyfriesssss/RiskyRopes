export type WSInfo = {
	URL: string,
	Authorization: {U: string, P:string}
}

local Connection = {}

local Base64 = require(script.Parent.Parent.Other.Base64)
local HTTPS = game:GetService('HttpService')
local WSInfo: WSInfo = require(script.Parent.WebServerInfo) -- Not included in GitHub for obvious reasons

local BaseURL, Authorization

local function dprint(msg: string)
	warn('[WEB-SERVER] ' .. msg)
end

-- Load authorization
local success,err = pcall(function()
	BaseURL = WSInfo.URL
	Authorization = Base64.Encode(WSInfo.Authorization.U .. ':' .. WSInfo.Authorization.P)
end)

if not success then dprint('Authorization failed to load') return 'failed' end

local function generateRequest(page: string, method: string, body: table)
	method = method or 'GET'
	local Body = HTTPS:JSONEncode(body or {}) 

	if not body or method == 'GET' then
		Body = nil
	end

	return {
		Url = BaseURL .. page,
		Method = method,
		Body = Body,
		Headers = {
			['Authorization'] = 'Basic ' .. Authorization,
			['Content-Type'] = 'application/json'
		}
	}
end

function Connection:test()
	
end

return setmetatable({URL = BaseURL, Authorization = Authorization}, {__index = Connection})