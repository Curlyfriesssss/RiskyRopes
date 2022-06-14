-- someone one day is gonna ask, why did boogle make the capitalization on the functions in this game so
-- fucking horrible, well my good man, purely because I am a fucking idiot
-- take the L loser
-- smh my head

local mapLoader = {}
local self = {}

if not game.ReplicatedStorage.Models:FindFirstChild('Maps') then
	Instance.new('Folder', game.ReplicatedStorage.Models).Name = 'Maps'
end

self.MapFolder = game.ReplicatedStorage.Models.Maps
self.MapLoadedEvent = Instance.new('BindableEvent')

function mapLoader:ClearLighting()
	pcall(function()
		workspace.Terrain.Clouds:Destroy()
	end)
	
	for _, Object in pairs(game.Lighting:GetChildren()) do
		if Object:IsA('Sky') or Object:IsA('Atmosphere') then
			Object:Destroy()
		end
	end
end

function mapLoader:LoadLighting(LightingFolder: Folder)
	for _, Object in pairs(LightingFolder:GetChildren()) do
		if Object:IsA('ValueBase') then
			game.Lighting[Object.Name] = Object.Value
		elseif Object:IsA('Clouds') then
			Object.Parent = workspace.Terrain
		else
			Object:Clone().Parent = game.Lighting
		end
	end
end

function mapLoader.delete()
	if self.CurrentMap then self.CurrentMap:Destroy() end
end

function mapLoader:load(MapName: string)
	if not self.MapFolder:FindFirstChild(MapName) then warn('Invalid Map') return end
	
	self:delete()
	
	local MapObject = self.MapFolder:FindFirstChild(MapName):Clone()
	
	self:ClearLighting()
	self:LoadLighting(MapObject:FindFirstChild('Lighting'))
	
	
	
	
	MapObject.Parent = workspace
	MapObject.Name = 'Map'
	
	
	self.CurrentMapName = MapName
	self.CurrentMap = MapObject
	
	self.LoadedModules = {}
	
	-- Load Modules
	for _, Mod: ModuleScript in pairs(MapObject:GetDescendants()) do
		if Mod:IsA('ModuleScript') then
			table.insert(self.LoadedModules, require(Mod))
		end
	end
	
	for _, v: BasePart | SpawnLocation in pairs(MapObject:GetDescendants()) do
		if v:IsA('SpawnLocation') then
			self.CurrentSpawn = v
			break
		-- dyrex mode one day
		
		-- elseif v:IsA("BasePart") then 
		-- 	v.Material = Enum.Material.Foil
		-- 	v.MaterialVariant = 'Dyrex'
		end
	end
	
	self.MapLoadedEvent:Fire()
	
end

return setmetatable(self, {__index = mapLoader})