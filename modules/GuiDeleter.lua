



local cloneref = cloneref or clonereference or function(obj) return obj end
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))

local GuiDeleter = {}
local isEnabled = false
local bindKey = Enum.KeyCode.Backspace 
local inputBeganConnection = nil
local localPlayer = Players.LocalPlayer


local function deleteGuisAtPosition()
	pcall(function()
		local playerGui = localPlayer:GetGuiObjectsAtPosition(
			UserInputService:GetMouseLocation().X,
			UserInputService:GetMouseLocation().Y
		)
		for _, gui in ipairs(playerGui) do
			if gui.Visible then
				gui:Destroy()
			end
		end
	end)
end


local function onInputBegan(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == bindKey then
		deleteGuisAtPosition()
	end
end


local function start()
	if isEnabled and not inputBeganConnection then
		inputBeganConnection = UserInputService.InputBegan:Connect(onInputBegan)
	end
end


local function stop()
	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end
end



function GuiDeleter.enable()
	if isEnabled then return end
	isEnabled = true
	start()
end



function GuiDeleter.disable()
	if not isEnabled then return end
	isEnabled = false
	stop()
end



function GuiDeleter.getBindKey()
	return bindKey
end



function GuiDeleter.setBindKey(newKey)
	if typeof(newKey) ~= "EnumItem" or newKey.EnumType ~= Enum.KeyCode then
		warn("GuiDeleter.setBindKey 需要传入一个 Enum.KeyCode 类型的参数")
		return
	end

	local wasEnabled = isEnabled
	if wasEnabled then
		stop()
	end

	bindKey = newKey

	if wasEnabled then
		start()
	end
end



function GuiDeleter.unload()
	stop()
	isEnabled = false
	bindKey = Enum.KeyCode.Backspace
end

return GuiDeleter