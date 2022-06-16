-- this method of ui design is so dogshit
-- i am sorry

local PagesModule = {}
local self = {}

local TS = game:GetService('TweenService')
local UIS = game:GetService('UserInputService')

local Functions = require(script.Parent.Functions)

local Menu: Frame = shared.Menu
local Pages: Frame = Menu.Pages

local UITextures = require(script.Parent.UITextures)

local ModulesFolder = game.ReplicatedStorage.Modules

local MapsFolder = game.ReplicatedStorage.Models.Maps
local MapsModule = ModulesFolder.Gameplay.Maps
local MapData = require(MapsModule)
local MapLoader = require(ModulesFolder.Gameplay.MapLoader)
local SliderCreator = require(script.Parent.Slider)
local ColorPicker = require(script.Parent.ColorPicker)
local SceneLoader = require(ModulesFolder.Gameplay.SceneLoader)

local New = require(script.Parent.WindowCreator)

local UIFolder = game.ReplicatedStorage.UI

-- why yes I did hardcode this...
-- pls dont be mad im just not sure where else to put 4 colors

local DifficultyColors = {
	[1] = Color3.new(0.333333, 1, 0.498039),
	[2] = Color3.new(1, 0.666667, 0),
	[3] = Color3.new(0.333333, 0, 0.498039),
	[4] = Color3.new(1, 0, 0)
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

	Pages.Stats.Stats.Text = (StatsFormat:format(
		Functions.SecondsToClock(ExtraStats.Playtime),
		Functions.CommaValue(ExtraStats.XP),
		Functions.CommaValue(ExtraStats.Wins),
		Functions.CommaValue(ExtraStats.Networth),
		
		Functions.CommaValue(MyStats.PurchaseCount),
		Functions.CommaValue(MyStats.RobuxSpent)
	)):gsub('	','')
end

function PagesModule:loadMapList()
	for K, Diff: string in pairs(MapData.Diff) do
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
		
		for MapName, MapInfo in pairs(MapData) do
			-- Makes sure the current iteration is a map and we have the map folder for it.
			if MapName ~= 'Diff' and MapsFolder:FindFirstChild(MapName) then
				if MapInfo.Difficulty == K then
					MapCount += 1
					local Map = UIFolder.Map:Clone()
					Map.Name = (MapName:lower()):gsub('%s','')
					
					Map.MouseEnter:Connect(function()
						TS:Create(Map.MapImage,TweenInfo.new(0.5),{ImageColor3 = Color3.new(1,1,1)}):Play()
					end)
					
					Map.MouseLeave:Connect(function()
						TS:Create(Map.MapImage,TweenInfo.new(0.5),{ImageColor3 = Color3.new(0.509804, 0.509804, 0.509804)}):Play()
					end)
					
					Map.Parent = MapGroup
					
					
					local AuthorString = 'By '
					Map.Author.Text = ''
					
					coroutine.wrap(function()
						if type(MapInfo.Author) == 'table' then
							for K, ID: number in pairs(MapInfo.Author) do
								local N = game.Players:GetNameFromUserIdAsync(ID)
								AuthorString = AuthorString .. N
								if K ~= #MapInfo.Author then
									AuthorString = AuthorString .. ' & '
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
					
					Map.MapImage.Image = ('rbxassetid://%s'):format(MapInfo.Image)
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
	['boolean'] = function(UpdateEvent: BindableEvent, Button: ImageButton, CurrentValue: boolean)
		local function UpdateCheckbox()
			Button.Image = UITextures.Checkbox[if CurrentValue then 'On' else 'Off']
		end

		UpdateCheckbox()

		Button.MouseButton1Click:Connect(function()
			CurrentValue = not CurrentValue
			UpdateEvent:Fire(CurrentValue)
			UpdateCheckbox()
		end)
	end,
	['NumberRange'] = function(UpdateEvent: BindableEvent, Slider: TextButton, CurrentValue: {NumberRange})
		local ThisSlider = SliderCreator.new(Slider, CurrentValue)
		
		ThisSlider:init()
		ThisSlider:Set(CurrentValue[2])

		ThisSlider.UpdateEvent.Event:Connect(function()
			UpdateEvent:Fire(math.floor(ThisSlider.Value))
		end)
	end,
	['Color3'] = function(UpdateEvent: BindableEvent, Button: TextButton, CurrentValue)
		Button.MouseButton1Click:Connect(function()
			local Window = New "ColorPicker" {}
			local ColorPicker = ColorPicker.new(Window, UpdateEvent)

			UpdateEvent.Event:Connect(function(New: Color3)
				Button.BackgroundColor3 = New
			end)

			ColorPicker:init()
			ColorPicker:Update()
			Window.Parent = Menu
		end)
	end
}

function PagesModule:LoadSettings()
	for SettingInternalName, Setting in pairs(shared.Settings) do
		local S = game.ReplicatedStorage.UI.Setting:Clone()
		local SType = typeof(Setting.Default)
		if SType == 'table' then SType = typeof(Setting.Default[1]) end

		if not S.Types:FindFirstChild(SType) then S:Destroy(); continue end
		
		local UpdateEvent = Instance.new('BindableEvent')

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

function PagesModule:OpenCrate()
	local Scene = SceneLoader(game.ReplicatedStorage.Models.Scenes.CrateOpening)
	Scene.AnimationTrack:GetMarkerReachedSignal('Particles'):Connect(function()
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

return setmetatable(self, {__index = PagesModule})