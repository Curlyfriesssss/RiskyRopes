shared.UI = script.Parent

-- Clone UI from UI model in storage
local UIFolder = game.ReplicatedStorage.UI.Init

for _, Frame: Frame in UIFolder:GetChildren() do
	local C = Frame:Clone()
	C.Parent = shared.UI
end

shared.Menu = shared.UI.Menu
shared.PlayerList = shared.UI.PlayerList
shared.HUD = shared.UI.HUD
shared.Settings = require(game.ReplicatedStorage.Modules.UI.Settings)
---------------------------------------
-- Variables
---------------------------------------
-- Services
local StarterGui = game:GetService("StarterGui")
local UIS = game:GetService("UserInputService")
local CAS = game:GetService("ContextActionService")
local TS = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RS = game:GetService("RunService")

-- Other
local MouseLocked = false

-- Constants
local PatternMoveTime = 2

-- Instances
local UI: Frame = script.Parent
local HUD: Frame = UI.HUD
local Menu: Frame = UI.Menu

local Modules = game.ReplicatedStorage.Modules
local UIFolder = game.ReplicatedStorage.UI

local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Remotes = ReplicatedStorage.Remotes

-- Requires
local New = require(Modules.UI.WindowCreator)
local ApplyFunctionality = require(Modules.UI.BasicWindowFunctionality)

local DataHandler = require(Modules.UI.DataHandler)

local Mods = {
	RankIcons = require(Modules.UI.RankIcons),
	Functions = require(Modules.UI.Functions),
	MapLoader = require(Modules.Gameplay.MapLoader),
	Pages = require(Modules.UI.Pages),
	Timer = require(Modules.Gameplay.Timer),
	Notice = require(Modules.UI.AccountNotice),
}

local CurrentMap = ""

---------------------------------------
-- Functions
---------------------------------------

function MoveToSpawn(C: Model)
	repeat
		task.wait()
	until C.PrimaryPart

	C.HumanoidRootPart.Velocity = Vector3.zero

	C:SetPrimaryPartCFrame(Mods.MapLoader.CurrentSpawn.CFrame * CFrame.new(0, 2, 0))
	task.spawn(function()
		task.wait(1 / 30)
		pcall(function()
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, workspace.Map.Rays.LookPart.Position)
		end)
	end)
end

function RandomizeWelcomeMessage() end

function WaitForMove()
	-- Definitely need to improve upon this method eventually.

	local Character = Player.Character

	repeat
		task.wait()
	until (Character.HumanoidRootPart.Velocity * Vector3.new(1, 0, 1)).Magnitude > 5
end

function Init()
	shared.Functions = Mods.Functions

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

	RS.RenderStepped:Connect(function()
		HUD.Timer.Text = ("%0.3f"):format(Mods.Timer.CurrentTime)

		UIS.MouseBehavior = if MouseLocked then Enum.MouseBehavior.LockCenter else Enum.MouseBehavior.Default
		UIS.MouseIconEnabled = not MouseLocked

		pcall(function()
			game.Players.LocalPlayer.Character.PrimaryPart.Anchored = not MouseLocked
			if not MouseLocked then
				game.Players.LocalPlayer.Character.PrimaryPart.CFrame = CFrame.new(0, 10000, 0)
			end
		end)
	end)

	Mods.Pages:loadMapList()
	Mods.Pages:UpdateStats()
	Mods.Pages:LoadSettings()
	Mods.Pages:LoadLeaderboards()

	for _, Button: GuiButton in Menu.TopBar.Selection:GetChildren() do
		if Button:IsA("GuiButton") then
			Button.MouseButton1Click:Connect(function()
				Menu.Pages.UIPageLayout:JumpTo(Menu.Pages:FindFirstChild(Button.Name))
			end)
		end
	end

	Mods.MapLoader.MapLoadedEvent.Event:Connect(function(MapName)
		CurrentMap = MapName

		MouseLocked = true
		Menu.Visible = false

		MoveToSpawn(game.Players.LocalPlayer.Character)

		WaitForMove()
		Mods.Timer:Start()

		-- Temporary timer pause
		workspace.Map.Orbs:GetChildren()[1].Touched:Connect(function(P)
			if game.Players:GetPlayerFromCharacter(P.Parent) == Player and Mods.Timer.State == 1 then
				Mods.Timer:Pause()

				Remotes.SetScore:FireServer(CurrentMap, math.floor(Mods.Timer.CurrentTime * 1000))
			end
		end)
	end)

	Player.CharacterAdded:Connect(function(C)
		MoveToSpawn(C)

		WaitForMove()

		Mods.Timer:Start()
	end)

	coroutine.wrap(function()
		while true do
			TS:Create(
				Menu.Pattern,
				TweenInfo.new(PatternMoveTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{ Position = UDim2.fromOffset(100, 100) }
			):Play()
			task.wait(PatternMoveTime)
			Menu.Pattern.Position = UDim2.new(0, 0, 0, 0)
		end
	end)()
end

---------------------------------------
-- Init
---------------------------------------

Init()

DataHandler:UpdateTopBar()

-- CAS:BindAction('TestCrate', function(_,b)
-- 	if b == Enum.UserInputState.Begin then
-- 		Mods.Pages:OpenCrate()
-- 	end

-- end, false, Enum.KeyCode.K)

CAS:BindAction("Reset", function(_, b)
	if b == Enum.UserInputState.Begin then
		MoveToSpawn(Player.Character)

		Mods.Timer:Stop()

		WaitForMove()

		Mods.Timer:Start()
	end
end, false, Enum.KeyCode.R)

CAS:BindAction("OpenMenu", function()
	MouseLocked = false
	Menu.Visible = true
end, false, Enum.KeyCode.M)
