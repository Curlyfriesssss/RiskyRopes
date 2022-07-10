local Music = {}
local self = {}

self.Playlist = require(script.Playlist)

self.CurrentTrack = 0

self.Status = "Stopped"

self.MusicObject = Instance.new("Sound", workspace)

self.MusicObject.Name = "Music"

self.MusicObject.SoundGroup = game.SoundService.Music

function Music:GetTrack()
	return self.Playlist[self.CurrentTrack]
end

function Music:Next()
	self.CurrentTrack += 1

	if self.CurrentTrack > #self.Playlist then
		self.CurrentTrack = 0
	end
end

function Music:Last()
	self.CurrentTrack -= 1

	if self.CurrentTrack < 0 then
		self.CurrentTrack = #self.Playlist
	end
end

function Music:Play()
	self.Status = "Playing"

	local TrackToPlay = self:GetTrack()

	if not TrackToPlay then
		return
	end

	self.MusicObject.SoundId = TrackToPlay.ID
	self.MusicObject.PlaybackSpeed = TrackToPlay.Speed or 1

	self.MusicObject.Playing = true
end

function Music:Pause()
	self.Status = "Paused"

	self.MusicObject.Playing = false
end

function Music:Stop()
	self.Status = "Paused"

	self.MusicObject:Stop()

	self.MusicObject.SoundId = ""
	self.MusicObject.PlaybackSpeed = 1
end

return setmetatable(self, { __index = Music })
