local CAS = game:GetService("ContextActionService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")

local Character: Model = script.Parent
local Camera: Camera = workspace.CurrentCamera

local CAST_DISTANCE = 125
local ROPE_FORCE = 2600
local FORCE_TYPE = "BodyForce"
local MOUSE_DOWN = false

local Objects: { Instance } = {}

local ObjectFolder = Instance.new("Folder", workspace)
ObjectFolder.Name = "OBJECTS"
local Attach0: Attachment = Character.HumanoidRootPart:FindFirstChildOfClass("Attachment")
local SkinAttach = Attach0:Clone()
SkinAttach.Parent = Attach0.Parent
SkinAttach.Position = Vector3.new(0.30, 0, -0.50)

local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Whitelist

--------------------------------------------------------------------------------------------------

-- This was used before in the original Risky Ropes
-- cant remember why I used it but I'll keep it here anyway

-- function sleep(l)
-- 	if not l then return true end

-- 	local startTime = tick()

-- 	while tick() - startTime < l do RS.Heartbeat:Wait() end

-- 	return true

-- end

function WipeObjects()
	for _, Obj: Instance in Objects do
		if Obj:IsA(FORCE_TYPE) then
			task.spawn(
				function() -- Crappy method to insure the force is deleted .25 seconds after we let go of our rope
					task.wait(0.250)
					Obj:Destroy()
				end
			)
		else
			Obj:Destroy()
		end
	end
end

function CreateAttachment(Part: BasePart, Position: Vector3)
	local A = Instance.new("Attachment")
	A.Parent = Part
	A.WorldPosition = Position

	return A
end

function CreateForce()
	local F = Instance.new(FORCE_TYPE)
	F.Parent = Character.HumanoidRootPart
	--F.Attachment0 = Attach0

	return F
end

function CreateSkin()
	local S = game.ReplicatedStorage.Skins.Lightning:Clone()
	S.Parent = ObjectFolder
	S.Attachment0 = SkinAttach

	return S
end

function CreateRope()
	local R = Instance.new("RopeConstraint")
	R.Parent = ObjectFolder
	R.Visible = false
	R.Attachment0 = Attach0

	return R
end

function updateParams()
	RayParams.FilterDescendantsInstances = {
		workspace.Map.Parts,
		workspace.Map.Orbs,
	}
end

function EyeTrace()
	pcall(updateParams) -- Update raycast filter without errors, just incase map doesn't exist

	local Result = workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * CAST_DISTANCE, RayParams)

	return Result
end

function Rope(_, State: Enum.UserInputState)
	WipeObjects()

	MOUSE_DOWN = State == Enum.UserInputState.Begin

	if State ~= Enum.UserInputState.Begin then
		return
	end

	local EyeHit = EyeTrace()

	repeat
		EyeHit = EyeTrace()
		RS.RenderStepped:Wait()
	until EyeHit or not MOUSE_DOWN

	if not EyeHit then
		return
	end

	if Objects.Force then
		Objects.Force:Destroy()
	end

	Objects.Attachment1 = CreateAttachment(EyeHit.Instance, EyeHit.Position)
	Objects.Force = CreateForce()

	Objects.Rope = CreateRope()
	Objects.Skin = CreateSkin()

	Objects.Rope.Length = EyeHit.Distance + 1

	Objects.Skin.Attachment1 = Objects.Attachment1
	Objects.Rope.Attachment1 = Objects.Attachment1
end

CAS:BindAction("Rope", Rope, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.Q)

local RootPart = Character.HumanoidRootPart

-- Dynamic FOV
RS.RenderStepped:Connect(function()
	local dfov = shared.Settings.dfov.Value
	local fov = shared.Settings.fov.Value

	if dfov then
		TS:Create(Camera, TweenInfo.new(0.75), { FieldOfView = math.clamp(RootPart.Velocity.Magnitude, fov, fov + 30) }):Play()
	else
		Camera.FieldOfView = fov
	end
end)

-- Apply a force so the player is faster when rope swinging
RS.Heartbeat:Connect(function()
	if Objects.Force and Character.HumanoidRootPart then
		Objects.Force.Force = Camera.CFrame.LookVector
			* Vector3.new(ROPE_FORCE, RootPart:GetMass() * game.Workspace.Gravity, ROPE_FORCE)
	end
end)
