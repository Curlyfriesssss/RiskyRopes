type Account = {
	XP: number,
	Wins: number,
	Cash: number,
	Playtime: number,
	AccountNotice: { Title: string, Message: string, State: boolean },
}

local Menu = shared.Menu

local TopBar = Menu.TopBar.PlayerInfo
local self = {}

local Remotes = game.ReplicatedStorage.Remotes

local MyData: Account

return setmetatable(self, {
	__index = {
		UpdateTopBar = function()
			MyData = Remotes.GetSelfData:InvokeServer()

			TopBar.LVL.Text = ('LVL %03d <font color="rgb(85,0,127)">(%s XP)</font>'):format(
				shared.Functions.XPToLVL(MyData.XP),
				shared.Functions.CommaValue(MyData.XP)
			)
			TopBar.Money.Text = ("$%s"):format(shared.Functions.CommaValue(MyData.Balance))
			TopBar.Username.Text = ("@%s"):format(game.Players.LocalPlayer.Name)
		end,
	},
})
