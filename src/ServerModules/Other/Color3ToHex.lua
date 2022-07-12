local Module = {}

-- https://devforum.roblox.com/t/converting-a-color-to-a-hex-string/793018

local hexChar = {
	"A", "B", "C", "D", "E", "F"
}

function Module.toInteger(color)
	return math.floor(color.r*255)*256^2+math.floor(color.g*255)*256+math.floor(color.b*255)
end

function Module.toHex(color)
	local int = Module.toInteger(color)
	
	local current = int
	local final = ""

	repeat local remainder = current % 16
		local char = tostring(remainder)
		
		if remainder >= 10 then
			char = hexChar[1 + remainder - 10]
		end
		
		current = math.floor(current/16)
		final = final..char
	until current <= 0
	
	return string.reverse(final)
end

return Module