local Camera = workspace.CurrentCamera
local MapLoader = require(script.Parent.MapLoader)

return function(Scene: Folder)
	local Scene = Scene:Clone()

	local SceneInfo = require(Scene.SceneInfo)

	local AC: AnimationController = SceneInfo.SceneObject:FindFirstChildOfClass("AnimationController")
	local Animator: Animator = AC.Animator

	Scene.Parent = workspace

	local Track: AnimationTrack = Animator:LoadAnimation(SceneInfo.Animation)
	Track.Looped = false

	local Sound = 1

	Track:GetMarkerReachedSignal("Sound"):Connect(function()
		local SoundFile = SceneInfo.SceneObject.Sound:FindFirstChild(tostring(Sound))
		game.SoundService:PlayLocalSound(SoundFile)

		Sound += 1
	end)

	local LoadedScene = {
		SceneObject = Scene,
		SceneInfo = SceneInfo,
		AnimationTrack = Track,
		CameraCF = Scene.CameraPart.CFrame,
	}

	MapLoader:LoadLighting(Scene.Lighting)

	function LoadedScene:ApplyCamera()
		Camera.CameraType = Enum.CameraType.Scriptable
		Camera.CFrame = LoadedScene.CameraCF
	end

	function LoadedScene:ResetCamera()
		Camera.CameraType = Enum.CameraType.Custom
	end

	function LoadedScene:Play()
		LoadedScene.AnimationTrack:Play()
		LoadedScene.AnimationTrack.Stopped:Wait()
	end

	function LoadedScene:Destroy()
		LoadedScene.SceneObject:Destroy()
	end

	return setmetatable({}, { __index = LoadedScene })
end
