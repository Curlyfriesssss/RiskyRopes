local RS = game:GetService("RunService")

local Timer = {}

local RUNNING, PAUSED, STOPPED = 1, 2, 3

Timer.StartTick = 0
Timer.CurrentTime = 0

Timer.State = STOPPED

Timer.Loop = RS.RenderStepped:Connect(function()
	if Timer.State == RUNNING then
		Timer.CurrentTime = tick() - Timer.StartTick
	elseif Timer.State == STOPPED then
		Timer.CurrentTime = 0
	end
end)

function Timer:Start()
	Timer.State = RUNNING

	Timer.StartTick = tick()
end

function Timer:Stop()
	Timer.State = STOPPED
end

function Timer:Pause()
	Timer.State = PAUSED
end

return setmetatable({}, { __index = Timer })
