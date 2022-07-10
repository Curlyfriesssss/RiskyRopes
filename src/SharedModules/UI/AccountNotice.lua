export type Notice = { Title: string, Content: string }

local New = require(script.Parent.WindowCreator)
local Notice = {}

function Notice:Display(Notices: { Notice })
	for _, Notice: Notice in Notices do
		local NoticeFrame = New("AccountNotice")({
			Title = Notice.Title,
			Content = Notice.Content,
		})

		NoticeFrame.Parent = shared.Menu
	end
end

return setmetatable({}, { __index = Notice })
