local ColorPicker = {}
local Slider = require(script.Parent.Slider)

local UIS = game:GetService("UserInputService")

function ColorPicker.new(GUI: Frame, UpdateEvent:BindableEvent)
	local self = {}

	self._GUI = GUI
	self.Color = Color3.fromHSV(1,1,1)
	

	self.HueSlider = Slider.new(self._GUI.HueShift,{NumberRange.new(0,360),0})
	
	self.HueSlider:init()
	self.HueSlider:Update(nil,0)

	self.MouseDown = false

	self.UpdateEvent = UpdateEvent

	self.HueSlider.UpdateEvent.Event:Connect(function()
		self:Update()
		
	end)

	return setmetatable(self, {__index = ColorPicker})
end

function ColorPicker:init()
	self._GUI.Submit.MouseButton1Click:Connect(function()
		self._GUI:Destroy()
	end)

	self._GUI.ColorPickerFrame.MouseButton1Down:Connect(function()
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

function ColorPicker:Update(MPos: Vector2)
	local PickerSize = self._GUI.ColorPickerFrame.AbsoluteSize
	local PickerPosition = self._GUI.ColorPickerFrame.AbsolutePosition
	local Crosshair = self._GUI.ColorPickerFrame.Crosshair

	if MPos then
		local X = ((MPos.X) - PickerPosition.X) / (PickerSize.X)
		local Y = ((MPos.Y - 30) - PickerPosition.Y) / (PickerSize.Y)
		X = math.clamp(X,0,1)
		Y = math.clamp(Y,0,1)

		Crosshair.Position = UDim2.fromScale(X,Y)
	end

	local Value: UDim2 = Crosshair.Position.Y.Scale
	local Saturation: UDim2 = Crosshair.Position.X.Scale

	local HueOnly = Color3.fromHSV(self.HueSlider.Value / 360,1,1)
	self.Color = Color3.fromHSV(self.HueSlider.Value / 360,Saturation,1-Value)
	self._GUI.ColorPickerFrame.UIGradient.Color = ColorSequence.new(Color3.new(1,1,1),HueOnly)

	self._GUI.SelectedColor.BackgroundColor3 = self.Color

	self.UpdateEvent:Fire(self.Color)
end


return ColorPicker