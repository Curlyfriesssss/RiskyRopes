export type Webhook = { URL: string }
export type Embed = {
	Title: string,
	Description: string,
	Color: Color3,
	URL: string,
	Author: { Name: string, URL: string, Icon_URL: string },
	Footer: { Text: string, Icon_URL: string },
}

local DiscordInfo = require(script.Parent.Parent.Data.DiscordWebhooks)

local HTTPS = game:GetService("HttpService")

local Color3ToHex = require(script.Parent.Parent.Other.Color3ToHex)

local Discord = {}

local Webhook = {}
Webhook.__index = Webhook

local Embed = {}
Embed.__index = Embed

-- Webhooks
function Discord.webhook(URL: string)
	local self = {
		URL = URL,
	}

	setmetatable(self, Webhook)

	return self
end

function Webhook:send(Content: string, Embed: Embed)
	local Data = {
		content = Content,
		embeds = {Embed:GetClean()},
	}

	Data = HTTPS:JSONEncode(Data)
	
	return HTTPS:PostAsync(DiscordInfo.Proxy .. self.URL, Data, Enum.HttpContentType.ApplicationJson, false)
end

-- Embeds
function Discord.embed() 
	local self = {
		Title = "",
		Description = "",
		Color = Color3.new(),
		URL = "",
		Author = {
			Name = "",
			URL = "",
			Icon_URL = "",
		},
		Fields = {},
		Footer = {
			Text = "",
			Icon_URL = "",
		},
	}

	setmetatable(self, Embed)

	return self
end

function Embed:AddField(Name: string, Value: any, Inline: boolean)
	table.insert(self.Fields, {
		name = Name,
		value = tostring(Value),
		inline = tostring(Inline)
	})
end

function Embed:GetClean()
	local output = {
		color = Color3ToHex.toHex(self.Color),
		title = self.Title,
		url = self.URL,
		description = self.Description,
		author = { name = self.Author.Name, icon_url = self.Author.Icon_URL, url = self.Author.URL },
		footer = { text = self.Author.Text, icon_url = self.Author.Icon_URL },
		fields = self.Fields
	}

	return output -- HTTPS:JSONEncode(output)
end

function Embed:SetFooter(Text: string, Icon_URL: string)
	self.Footer.Text = Text
	self.Icon_URL.Text = Icon_URL
end

return Discord
