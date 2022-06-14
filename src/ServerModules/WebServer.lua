local Base64 = require(script.Parent.Base64)

local Connection = {}

local WSInfo = require(script.Parent.WebServerInfo)

local HTTPS = game:GetService('HttpService')

local BaseURL, Authorization

local function dprint(msg: string)
	warn('[WEB-SERVER] ' .. msg)
end

-- Load authorization
local failed,_ = pcall(function()
	BaseURL = WSInfo.URL
	Authorization = Base64.Encode(WSInfo.Authorization.U .. ':' .. WSInfo.Authorization.P)
end)

if failed then dprint('Authorization failed to load') return end

local function generateRequest(page, method, body)
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

return setmetatable({URL = BaseURL, Authorization = Authorization}, {__index = Connection})