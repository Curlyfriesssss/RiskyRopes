local RS = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

repeat
	task.wait()
until shared.Settings

local Settings = shared.Settings

SoundService.Music.Volume = 0

RS.RenderStepped:Connect(function()
	local MusicVolume = Settings.mvolume.Value / 100

	SoundService.Music.Volume = MusicVolume

	Lighting.Bloom.Enabled = Settings.bloom.Value
	Lighting.ColorCorrection.Enabled = Settings.colormode.Value
	Lighting.GlobalShadows = Settings.shade.Value
end)
