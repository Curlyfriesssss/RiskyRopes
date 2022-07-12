local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
local RStorage = game:GetService("ReplicatedStorage")


local Remotes = RStorage.Remotes

function GenerateChatTag(Message: string, Color: Color3)
	local Output = [[<font color="rgb(%s,%s,%s)">[%s]</font> ]]

	local R = math.ceil(Color.R * 255)
	local G = math.ceil(Color.G * 255)
	local B = math.ceil(Color.B * 255)

	return Output:format(R, G, B, Message)
end

TextChatService.OnIncomingMessage = function(Message: TextChatMessage)
	local Props = Instance.new("TextChatMessageProperties")

	if Message.TextSource then
		local Player = Players:GetPlayerByUserId(Message.TextSource.UserId)
		local PlayerTags = Remotes.GetChatTags:InvokeServer(Player)

		for _, ChatTag in PlayerTags do
			local ChatTagText = ChatTag.Text
			local ChatTagColor = ChatTag.Color

			if ChatTagText then
				Props.PrefixText = GenerateChatTag(ChatTagText, ChatTagColor) .. Message.PrefixText
			end
		end
	end

	return Props
end
