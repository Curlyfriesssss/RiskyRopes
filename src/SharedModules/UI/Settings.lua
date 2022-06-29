local settings = {}

local function newSetting(Key: string, Name: string, Default: boolean | NumberRange)
	settings[Key] = {Name = Name:upper(), Default = Default,Value = if type(Default) == 'table' then Default[2] else Default}
end

-- im sorry if this sucks
-- i thought this was cute
-- does it suck?

-- internal name, display name, default state (default if number range)

-- Colors
newSetting('crosscolor1',		'CROSSHAIR COLOR 1',	{Color3.new(),Color3.new(0,1,0)})
newSetting('crosscolor2',		'CROSSHAIR COLOR 2',	{Color3.new(),Color3.new(1,0,0)})

-- Sliders
newSetting('mvolume',		'MUSIC VOLUME',			{NumberRange.new(0, 10),1})
newSetting('fov',			'FIELD OF VIEW',		{NumberRange.new(60,120),90})
newSetting('bubble_radius',	'BUBBLE RADIUS',		{NumberRange.new(0,25),6,'studs'})

-- Toggles
newSetting('music',			'IN-GAME MUSIC',		true)
newSetting('upsidedown',	'UPSIDE DOWN MODE',		false)
newSetting('useskins',		'HIDE ROPE PHYSICS',	true)
newSetting('colormode',		'COLOR CORRECTION', 	true)
newSetting('dof',			'DEPTH OF FIELD',		true)
newSetting('shade',			'SHADOWS',				true)
newSetting('bloom',			'BLOOM',				true)
newSetting('hideall',		'HIDE PLAYERS',			false)
newSetting('dfov',			'DYNAMIC FOV',			true)
newSetting('victory_sfx',	'VICTORY NOISE',		true)
newSetting('victory_disp',	'VICTORY SCREEN',		true)
newSetting('tips',			'HELP MESSAGES',		true)
newSetting('key_display',	'KEYSTROKE DISPLAY',	false)
newSetting('wind',			'WIND NOISE',			true)
newSetting('developer_mode','DEBUG MODE',			false)



return settings
