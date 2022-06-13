local XPDropOff = 2

return {
	CommaValue = function(Amount: number)
		local formatted = Amount
		while true do
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if (k==0) then
				break
			end
		end
		return formatted
	end,
	XPToLVL = function(XP: number)
		return math.floor(math.sqrt(XP) / XPDropOff)
	end,
	LVLToXP = function(LVL: number)
		return math.floor((LVL ^ 2) * (XPDropOff*2))
	end,
	SecondsToClock = function(seconds)
		local seconds = tonumber(seconds)

		if seconds <= 0 then
			return "00:00:00";
		else
			local hours,mins,secs
			hours = string.format("%02.f", math.floor(seconds/3600));
			mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
			secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
			return hours..":"..mins..":"..secs
		end
	end
}