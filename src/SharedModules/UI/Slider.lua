local Slider = {}

local UIS = game:GetService('UserInputService')

function Slider.new(SliderGUI: TextButton, CurrentValue: {NumberRange})
	local self = {}

	self._GUI = SliderGUI
	self._progress = 0
	self.Value = 0
	self.Max = CurrentValue[1].Max
	self.Min = CurrentValue[1].Min
	self.MouseDown = false

	return setmetatable(self, {__index = Slider})
end

function Slider:init()
	self._GUI.MouseButton1Down:Connect(function()
		self.MouseDown = true
		
		repeat
			local MPos = UIS:GetMouseLocation()
			self:Update(MPos)
			task.wait()
		until not self.MouseDown
	end)

	UIS.InputEnded:Connect(function(IO: InputObject)
		if IO.UserInputType == Enum.UserInputType.MouseButton1 and self.MouseDown then self.MouseDown = false end
	end)
end

function map(x, in_min, in_max, out_min, out_max)
	return out_min + (x - in_min)*(out_max - out_min)/(in_max - in_min)
end

function Slider:_Step()
	local Multiple = 1 / self.Max
	self._progress = math.floor(self._progress / Multiple + 0.5) * Multiple
end

function Slider:Update(MPos: Vector2, ForceProgress: number)
	local SliderSize = self._GUI.AbsoluteSize
	local SliderPosition = self._GUI.AbsolutePosition

	self._progress = ForceProgress or 0.50
	local MinProgress = self.Min/self.Max

	if MPos then
		self._progress = ((MPos.X) - SliderPosition.X) / (SliderSize.X)
	end

	self._progress = math.clamp(self._progress,0,1)
	self:_Step()

	self.Value = map(self._progress, 0, 1, self.Min, self.Max)

	local ValueText = math.floor(self.Value)

	self._GUI.Value.Text = ValueText

	self._GUI.fill.Size = UDim2.fromScale(self._progress,1)
	self._GUI.point.Position = UDim2.fromScale(self._progress,0.5)
end

function Slider:Set(NewValue: number)
	local ForceAmount = map(NewValue, self.Min, self.Max, 0, 1)

	self:Update(nil, ForceAmount)
end

return Slider