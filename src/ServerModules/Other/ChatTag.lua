local GroupService = game:GetService("GroupService")
local Players = game:GetService("Players")

local SharedModules = game.ReplicatedStorage.Modules
local GroupInfo = require(SharedModules.Data.GroupInfo)

local GroupCache = {}

function GetGroupRank(UserId: number)
	if GroupCache[UserId] then
		return GroupCache[UserId]
	end
	GroupCache[UserId] = false

	local suc

	repeat
		suc = pcall(function()
			local PlayerGroups = GroupService:GetGroupsAsync(UserId)
			for _, Group: { Id: number, Rank: number } in PlayerGroups do
				if Group["Id"] == GroupInfo["GroupID"] then
					GroupCache[UserId] = Group["Rank"]
				end
			end
		end)
		if not suc then
			task.wait(5.25)
		end
	until suc

	return GroupCache[UserId]
end

local ChatTag = {}
ChatTag.__index = ChatTag

local self = {}

function _new(Text: string, Color: Color3)
	local ChatTag = {
		Text = Text,
		Color = Color,
	}
	return ChatTag
end

function ChatTag:GetChatTagsForPlayer(Player: Player)
	local GroupRank = GetGroupRank(Player.UserId)
	local ChatTags = {}

	-- Is staff
	if GroupRank >= GroupInfo.StaffRank then
		table.insert(ChatTags, _new("STAFF", Color3.new(0.780392, 0.670588, 0.333333)))
	end

	-- Is developer
	if GroupRank >= GroupInfo.DeveloperRank then
		table.insert(ChatTags, _new("DEV", Color3.new(0.780392, 0.333333, 0.721568)))
	end

	return ChatTags
end

setmetatable(self, ChatTag)

return self
