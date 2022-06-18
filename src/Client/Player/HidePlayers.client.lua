local Players = game:GetService("Players")
local RS = game:GetService('RunService')

local Camera = workspace.CurrentCamera

local map = require(game.ReplicatedStorage.Modules.UI.Functions).Map

function HideCharacter(Character: Model, Distance: number)
	local MyRadius = shared.Settings.bubble_radius.Value
	local NewTransparency = 1 - map(Distance, MyRadius, MyRadius*2, 0, 1)

	coroutine.wrap(function()
		for _, BasePart: BasePart in ipairs(Character:GetDescendants()) do
			if (BasePart:IsA("BasePart") or BasePart:IsA("Decal")) and BasePart.Name ~= 'HumanoidRootPart' then
				BasePart.Transparency = NewTransparency
			end
		end
	end)()
end

Camera:GetPropertyChangedSignal("CFrame"):Connect(function()
	
	local Players = Players:GetPlayers()

	if #Players == 0 then return end
	local MyPosition = Camera.CFrame.Position

	for _, Player in ipairs(Players) do
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
			local PlayerPosition = Player.Character:FindFirstChild("HumanoidRootPart").Position
			local Distance = (MyPosition - PlayerPosition).Magnitude

			if Distance >= shared.Settings.bubble_radius.Default[1].Max then continue end

			HideCharacter(Player.Character, Distance)
		end
	end

end)