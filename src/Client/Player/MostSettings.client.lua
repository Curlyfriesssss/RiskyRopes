local RS = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

repeat
	task.wait()
until shared.Settings

local Settings = shared.Settings

SoundService.Music.Volume = 0

RS.RenderStepped:Connect(function()
	local MusicVolume = Settings.mvolume.Value / 100

	SoundService.Music.Volume = MusicVolume
end)
