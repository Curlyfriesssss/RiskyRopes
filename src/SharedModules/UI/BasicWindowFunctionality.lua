return function(Window: Frame)
	Window.TopBar.CloseButton.MouseButton1Click:Connect(function()
		Window:Destroy()
	end)
end
