function createTrack(ID: number, PlaybackSpeed: number)
	return {
		ID = ("rbxassetid://%s"):format(ID),
		Speed = PlaybackSpeed,
	}
end

return {
	createTrack(10186199663, 1),
}
