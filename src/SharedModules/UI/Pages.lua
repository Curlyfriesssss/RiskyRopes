-- this method of ui design is so dogshit
-- i am sorry

local PagesModule = {}
local self = {}

local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Player = game.Players.LocalPlayer

local Functions = require(script.Parent.Functions)
local Remotes = game.ReplicatedStorage.Remotes

local Menu: Frame = shared.Menu
local Pages: Frame = Menu.Pages

local UITextures = require(script.Parent.UITextures)

local ModulesFolder = game.ReplicatedStorage.Modules

local MapsFolder = game.ReplicatedStorage.Maps
local MapsModule = ModulesFolder.Data.Maps
local MapData = require(MapsModule)
local MapLoader = require(ModulesFolder.Gameplay.MapLoader)
local SliderCreator = require(script.Parent.Slider)
local ColorPicker = require(script.Parent.ColorPicker)
local SceneLoader = require(ModulesFolder.Gameplay.SceneLoader)
local AccountNotice = require(script.Parent.AccountNotice)

local GroupInfo = require(ModulesFolder.Data.GroupInfo)

local New = require(script.Parent.WindowCreator)

local UIFolder = game.ReplicatedStorage.UI

-- why yes I did hardcode this...
-- pls dont be mad im just not sure where else to put 4 colors

local DifficultyColors = {
	[1] = Color3.new(0.333333, 1, 0.498039),
	[2] = Color3.new(1, 0.666667, 0),
	[3] = Color3.new(0.333333, 0, 0.498039),
	[4] = Color3.new(1, 0, 0),
}

-- and this...

local StatsFormat = [[ 
Playtime: %s
XP: %s
Wins %s
Networth: $%s

Purchases: %s
Robux Spent: R$%s]]

function PagesModule:UpdateStats()
	local MyStats = game.ReplicatedStorage.Remotes.GetSelfStats:InvokeServer()
	local ExtraStats = game.ReplicatedStorage.Remotes.GetSelfData:InvokeServer()

	-- AccountNotice:Display(ExtraStats.AccountNotice)

	Pages.Stats.Stats.Text = (StatsFormat:format(
		Functions.SecondsToClock(ExtraStats.Playtime),
		Functions.CommaValue(ExtraStats.XP),
		Functions.CommaValue(ExtraStats.Wins),
		Functions.CommaValue(ExtraStats.Networth),

		Functions.CommaValue(MyStats.PurchaseCount),
		Functions.CommaValue(MyStats.RobuxSpent)
	)):gsub("	", "")
end

function PagesModule:loadMapList()
	for K, Diff: string in MapData.Diff do
		local MapLabel = UIFolder.MapLabel:Clone()
		MapLabel.Parent = Pages.Play.MapMenu
		MapLabel.Text = Diff
		MapLabel.LayoutOrder = K

		MapLabel.TextColor3 = DifficultyColors[K]
		MapLabel.Border.BackgroundColor3 = DifficultyColors[K]

		local MapGroup = UIFolder.MapGroup:Clone()
		MapGroup.LayoutOrder = K + 1
		MapGroup.Parent = Pages.Play.MapMenu

		local MapCount = 0

		for MapName, MapInfo in MapData do
			-- Makes sure the current iteration is a map and we have the map folder for it.
			if MapName ~= "Diff" and MapsFolder:FindFirstChild(MapName) then
				if MapInfo.Difficulty == K then
					MapCount += 1
					local Map = UIFolder.Map:Clone()
					Map.Name = (MapName:lower()):gsub("%s", "")

					Map.MouseEnter:Connect(function()
						TS:Create(Map.MapImage, TweenInfo.new(0.5), { ImageColor3 = Color3.new(1, 1, 1) }):Play()
					end)

					Map.MouseLeave:Connect(function()
						TS:Create(
							Map.MapImage,
							TweenInfo.new(0.5),
							{ ImageColor3 = Color3.new(0.509804, 0.509804, 0.509804) }
						):Play()
					end)

					Map.Parent = MapGroup

					local AuthorString = "By "
					Map.Author.Text = ""

					coroutine.wrap(function()
						if type(MapInfo.Author) == "table" then
							for K, ID: number in MapInfo.Author do
								local N = game.Players:GetNameFromUserIdAsync(ID)
								AuthorString = AuthorString .. N
								if K ~= #MapInfo.Author then
									AuthorString = AuthorString .. " & "
								end
							end
						else
							local N = game.Players:GetNameFromUserIdAsync(MapInfo.Author)
							AuthorString = AuthorString .. N
						end

						Map.Author.Text = AuthorString
					end)()

					Map.MapImage.MouseButton1Click:Connect(function()
						MapLoader:load(MapName)
					end)

					Map.MapImage.Image = ("rbxassetid://%s"):format(MapInfo.Image)
					Map.MapName.Text = MapName
				end
			end
		end
		if MapCount == 0 then
			MapGroup:Destroy()
			MapLabel:Destroy()
		end
	end
end

local SettingTypesFunc = {
	["boolean"] = function(UpdateEvent: BindableEvent, Button: ImageButton, CurrentValue: boolean)
		local function UpdateCheckbox()
			Button.Image = UITextures.Checkbox[if CurrentValue then "On" else "Off"]
		end

		UpdateCheckbox()

		Button.MouseButton1Click:Connect(function()
			CurrentValue = not CurrentValue
			UpdateEvent:Fire(CurrentValue)
			UpdateCheckbox()
		end)
	end,
	["NumberRange"] = function(UpdateEvent: BindableEvent, Slider: TextButton, CurrentValue: { NumberRange })
		local ThisSlider = SliderCreator.new(Slider, CurrentValue)

		ThisSlider:init()
		ThisSlider:Set(CurrentValue[2])

		ThisSlider.UpdateEvent.Event:Connect(function()
			UpdateEvent:Fire(math.floor(ThisSlider.Value))
		end)
	end,
	["Color3"] = function(UpdateEvent: BindableEvent, Button: TextButton, CurrentValue)
		local Color = CurrentValue[2]
		Button.BackgroundColor3 = Color

		Button.MouseButton1Click:Connect(function()
			local Window = New("ColorPicker")({})
			local ColorPicker = ColorPicker.new(Window, UpdateEvent)

			ColorPicker:Set(Color)

			UpdateEvent.Event:Connect(function(New: Color3)
				Button.BackgroundColor3 = New
				Color = New
			end)

			ColorPicker:init()
			ColorPicker:Update()
			Window.Parent = Menu
		end)
	end,
}

function PagesModule:LoadSettings()
	for SettingInternalName, Setting in shared.Settings do
		local S = game.ReplicatedStorage.UI.Setting:Clone()
		local SType = typeof(Setting.Default)
		if SType == "table" then
			SType = typeof(Setting.Default[1])
		end

		if not S.Types:FindFirstChild(SType) then
			S:Destroy()
			continue
		end

		local UpdateEvent = Instance.new("BindableEvent")

		UpdateEvent.Event:Connect(function(New: any)
			shared.Settings[SettingInternalName].Value = New
		end)

		S.Name = Setting.Name:lower()
		S.Title.Text = Setting.Name
		S.Parent = Pages.Settings.Settings
		S.Types[SType].Visible = true
		SettingTypesFunc[SType](UpdateEvent, S.Types[SType], Setting.Default)
	end
end

function ClearLeaderboard()
	for _, Object in Pages.Leaderboards.Leaderboard:GetChildren() do
		if Object:IsA("Frame") then
			Object:Destroy()
		end
	end
end

local NameCache = {}
local PendingNames = 0

function GetUsername(UserId: number)
	if NameCache[UserId] then
		return NameCache[UserId]
	end
	NameCache[UserId] = "Still Pending"

	local suc
	PendingNames += 1
	repeat
		suc = pcall(function()
			NameCache[UserId] = Players:GetNameFromUserIdAsync(UserId)
		end)
		if not suc then
			task.wait(5.25)
		end
	until suc
	PendingNames -= 1

	return NameCache[UserId]
end

local VerifyCache = {}
local PendingVerify = 0

function IsVerified(UserId: number)
	if VerifyCache[UserId] then
		return VerifyCache[UserId]
	end
	VerifyCache[UserId] = false

	local suc
	PendingVerify += 1
	repeat
		suc = pcall(function()
			local PlayerGroups = GroupService:GetGroupsAsync(UserId)
			for _, Group: { Id: number, Rank: number } in PlayerGroups do
				if Group["Id"] == GroupInfo["GroupID"] and Group["Rank"] >= GroupInfo["VerifyRank"] then
					VerifyCache[UserId] = true
				end
			end
		end)
		if not suc then
			task.wait(5.25)
		end
	until suc
	PendingVerify -= 1

	return VerifyCache[UserId]
end

local PageNumber = 1
local LeaderboardCooldown = false
local CooldownTime = 0.50
local PageCount = 1

function LoadLeaderboard(MapName: string)
	if LeaderboardCooldown then
		return
	end
	LeaderboardCooldown = true

	ClearLeaderboard()

	local Result = Remotes.GetLeaderboard:InvokeServer(MapName, PageNumber)

	for Index, ThisResult in Result do
		if ThisResult.userid then
			local LUser = New("LUser")({
				Username = "?",
				Score = ("%0.3f"):format(ThisResult.score / 1000),
				Headshot = Functions.QuickAvatar(ThisResult.userid),
				Position = ("#%01d"):format(Index + if PageNumber > 1 then PageNumber * 100 else 0),
			})
			LUser.LayoutOrder = ThisResult.score

			if Index == 1 and PageNumber == 1 then -- First score in leaderboard
				local C
				C = RunService.RenderStepped:Connect(function()
					LUser.BackgroundColor3 = Color3.fromHSV(tick() % 10 / 10, 1, 1)
				end)

				LUser.Destroying:Connect(function() -- Not sure this is needed or not, but just incase.
					C:Disconnect()
				end)
			elseif ThisResult.userid == Player.UserId then
				LUser.BackgroundColor3 = Color3.new(0.584313, 0.082352, 0.768627)
			end

			LUser.Parent = Pages.Leaderboards.Leaderboard

			task.spawn(function()
				LUser.Main.RealMain.Username.Text = GetUsername(ThisResult.userid)
			end)

			task.spawn(function()
				LUser.Main.RealMain:FindFirstChild("Position").Verified.Visible = IsVerified(ThisResult.userid)
			end)
		else
			PageCount = math.ceil(ThisResult.Count / 100)
		end
	end

	task.spawn(function()
		task.wait(CooldownTime)
		LeaderboardCooldown = false
	end)
end

function PagesModule:LoadLeaderboards()
	local PBar = Pages.Leaderboards.PageBar

	local Next = PBar.Next
	local Last = PBar.Previous
	local Counter: TextBox = PBar.PageNumber

	local CurrentMap = "roomchan"

	-- Load map buttons
	for MapName, MapInfo in MapData do
		if MapName ~= "Diff" then
			local Button = New("LeaderboardMap")({ MapName = MapName })
			Button.Parent = Pages.Leaderboards.TopBar
			Button.Image = ("rbxassetid://%s"):format(MapInfo.Image)
			Button.Name = MapName:lower()

			Button.MapName.MouseButton1Click:Connect(function()
				PageNumber = 1
				Counter.Text = "1"
				CurrentMap = MapName
				LoadLeaderboard(MapName)
			end)
		end
	end

	local function UpdatePageNumber(Amount: number)
		if LeaderboardCooldown then
			return
		end

		local OldPNumber = PageNumber

		PageNumber += Amount

		PageNumber = math.clamp(PageNumber, 1, PageCount)

		Counter.Text = PageNumber

		if PageNumber ~= OldPNumber or Amount == 0 then
			LoadLeaderboard(CurrentMap)
		end
	end

	Pages.Leaderboards.Refresh.MouseButton1Click:Connect(function()
		LoadLeaderboard(CurrentMap)
	end)

	Counter.FocusLost:Connect(function(enterPressed)
		local New = tonumber(Counter.Text)

		if New == nil then
			New = 1
		end

		Counter.Text = New

		PageNumber = tonumber(Counter.Text)
		UpdatePageNumber(0)
	end)

	Next.MouseButton1Click:Connect(function()
		UpdatePageNumber(1)
	end)

	Last.MouseButton1Click:Connect(function()
		UpdatePageNumber(-1)
	end)

	RunService.RenderStepped:Connect(function()
		if PendingNames == 0 then
			Menu.NameTip.Text = ""
		else
			Menu.NameTip.Text = ("Fetching %s names..."):format(PendingNames)
		end
	end)

	LoadLeaderboard("roomchan")
end

function PagesModule:OpenCrate()
	local Scene = SceneLoader(game.ReplicatedStorage.Scenes.CrateOpening)
	Scene.AnimationTrack:GetMarkerReachedSignal("Particles"):Connect(function()
		Scene.SceneObject.LootCrate.Neon.ParticleEmitter.Enabled = true
	end)
	task.wait(1)
	Scene:ApplyCamera()
	Menu.Visible = false
	Scene:Play()

	Scene:ResetCamera()
	Scene:Destroy()

	Menu.Visible = true
end

return setmetatable(self, { __index = PagesModule })
