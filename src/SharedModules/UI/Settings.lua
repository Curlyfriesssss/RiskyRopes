local settings = {}

local function newSetting(Key: string, Name: string, Default: boolean | NumberRange)
	settings[Key] = {Name = Name:upper(), Default = Default}
end

-- im sorry if this sucks
-- i thought this was cute
-- does it suck?

newSetting('music',			'IN-GAME MUSIC',		true)
newSetting('upsidedown',	'UPSIDE DOWN MODE',		false)
newSetting('useskins',		'HIDE ROPE PHYSICS',	true)
newSetting('colormode',		'COLOR CORRECTION', 	true)
newSetting('dof',			'DEPTH OF FIELD',		true)
newSetting('shade',			'SHADOWS',				true)
newSetting('bloom',			'BLOOM',				true)
newSetting('hideall',		'HIDE PLAYERS',			false)
newSetting('mvolume',		'MUSIC VOLUME',			NumberRange.new(0, 10))
newSetting('fov',			'FIELD OF VIEW',		NumberRange.new(20,120))
newSetting('victory_sfx',	'VICTORY NOISE',		true)
newSetting('victory_disp',	'VICTORY SCREEN',		true)
newSetting('tips',			'HELP MESSAGES',		true)
newSetting('key_display',	'KEYSTROKE DISPLAY',	false)
newSetting('wind',			'WIND NOISE',			true)
newSetting('developer_mode','DEBUG MODE',			false)


return settings