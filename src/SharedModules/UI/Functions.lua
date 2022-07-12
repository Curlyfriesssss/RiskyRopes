local XPDropOff = 2

return {
	CommaValue = function(Amount: number)
		local formatted = Amount
		while true do
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
			if k == 0 then
				break
			end
		end
		return formatted
	end,
	XPToLVL = function(XP: number)
		return math.floor(math.sqrt(XP) / XPDropOff)
	end,
	LVLToXP = function(LVL: number)
		return math.floor((LVL ^ 2) * (XPDropOff * 2))
	end,
	ScoreToReadable = function(Score: number)
		local MS = Score
		local TotalSeconds = math.floor(MS / 1000)
		
		MS = MS % 1000

		local Seconds = TotalSeconds % 60
		local Minutes = math.floor(TotalSeconds / 60)

		return ("%02d:%02d.%03d"):format(Minutes, Seconds, MS)
	end,
	SecondsToClock = function(seconds)
		local seconds = tonumber(seconds)

		if seconds <= 0 then
			return "00:00:00"
		else
			local hours, mins, secs
			hours = string.format("%02.f", math.floor(seconds / 3600))
			mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
			secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
			return hours .. ":" .. mins .. ":" .. secs
		end
	end,
	Map = function(x, in_min, in_max, out_min, out_max)
		return out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min)
	end,
	QuickAvatar = function(UserID: number)
		return ("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png"):format(
			UserID
		)
	end,
}
