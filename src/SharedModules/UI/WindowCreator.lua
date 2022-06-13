function ApplyProperty(Object: GuiObject, PropertyValue: string)
	local KeyToEdit
	
	local PossibleKeys = {'Text','Image'}
	
	for _, Key in pairs(PossibleKeys) do
		if Object[Key] then
			KeyToEdit = Key
			break
		end
	end
	
	if not KeyToEdit then return end
	
	-- Apply
	Object[KeyToEdit] = PropertyValue
end

return function(ClassName: string)
	local Window: Frame = game.ReplicatedStorage.UI[ClassName]:Clone()
	
	return function(Properties: {})
		for _, Object: GuiObject in pairs(Window:GetDescendants()) do
			if Properties[Object.Name] then
				ApplyProperty(Object,Properties[Object.Name])
			end
		end
		
		
		return Window
	end
end