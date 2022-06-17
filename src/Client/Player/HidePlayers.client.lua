local Players = game:GetService("Players")
local RS = game:GetService('RunService')

local Camera = workspace.CurrentCamera

local map = require(game.ReplicatedStorage.Modules.UI.Functions).Map

function HideCharacter(Character: Model, Distance: number)
	local MyRadius = shared.Settings.bubble_radius.Value
	local NewTransparency = 1 - map(Distance, MyRadius/2, MyRadius, 0, 1)

	for _, BasePart: BasePart in Character:GetDescendants() do
		if BasePart:IsA("BasePart") and BasePart.Name ~= 'HumanoidRootPart' then
			BasePart.Transparency = NewTransparency
		end
	end
end

RS.RenderStepped:Connect(function(deltaTime)
	
	local MyPosition = Camera.CFrame.Position

	for _, Player in Players:GetPlayers() do
		if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
			local PlayerPosition = Player.Character:FindFirstChild("HumanoidRootPart").Position
			local Distance = (MyPosition - PlayerPosition).Magnitude

			HideCharacter(Player.Character, Distance)
		end
	end

end)