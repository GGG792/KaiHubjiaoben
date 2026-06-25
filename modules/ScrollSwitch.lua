


local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local ContextActionService = cloneref(game:GetService("ContextActionService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))

local ScrollSwitch = {}
local player = Players.LocalPlayer
local character = nil


local enabled = false
local modifierKey = Enum.KeyCode.V  
local validSlots = {}
local currentSlotIndex = 1
local lastScrollTime = 0
local modifierHeld = false


local connections = {}


local numberToKeyCode = {
	[0] = Enum.KeyCode.Zero,
	[1] = Enum.KeyCode.One,
	[2] = Enum.KeyCode.Two,
	[3] = Enum.KeyCode.Three,
	[4] = Enum.KeyCode.Four,
	[5] = Enum.KeyCode.Five,
	[6] = Enum.KeyCode.Six,
	[7] = Enum.KeyCode.Seven,
	[8] = Enum.KeyCode.Eight,
	[9] = Enum.KeyCode.Nine,
}


local function pressNumberKey(num: number)
	local keyCode = numberToKeyCode[num]
	if keyCode then
		VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
		VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
	end
end


local function hasToolEquipped()
	if not character then return false end
	return character:FindFirstChildOfClass("Tool") ~= nil
end


local function scanAllSlots()
	validSlots = {}
	
	if not character then return end
	
	for i = 1, 9 do
		pressNumberKey(i)
		task.wait(0.05)
		
		if hasToolEquipped() then
			table.insert(validSlots, i)
			
			pressNumberKey(i)
			task.wait(0.05)
		end
	end
	
	pressNumberKey(0)
	task.wait(0.05)
	if hasToolEquipped() then
		table.insert(validSlots, 0)
		pressNumberKey(0)
		task.wait(0.05)
	end
	
	if #validSlots > 0 then
		currentSlotIndex = 1
		pressNumberKey(validSlots[1])
	end
end


local function switchToPrev()
	if #validSlots == 0 then return end
	currentSlotIndex = currentSlotIndex - 1
	if currentSlotIndex < 1 then
		currentSlotIndex = #validSlots
	end
	pressNumberKey(validSlots[currentSlotIndex])
end


local function switchToNext()
	if #validSlots == 0 then return end
	currentSlotIndex = currentSlotIndex + 1
	if currentSlotIndex > #validSlots then
		currentSlotIndex = 1
	end
	pressNumberKey(validSlots[currentSlotIndex])
end


local function bindEvents()
	
	ContextActionService:UnbindAction("ScrollSwitch")
	
	
	ContextActionService:BindAction(
		"ScrollSwitch",
		function(actionName, inputState, inputObject)
			if inputState == Enum.UserInputState.Change then
				if modifierHeld then
					local now = tick()
					if now - lastScrollTime < 0.1 then
						return Enum.ContextActionResult.Sink
					end
					lastScrollTime = now

					local delta = inputObject.Position.Z
					if delta > 0 then
						switchToPrev()
					elseif delta < 0 then
						switchToNext()
					end
					return Enum.ContextActionResult.Sink
				else
					return Enum.ContextActionResult.Pass
				end
			end
			return Enum.ContextActionResult.Pass
		end,
		false,
		Enum.UserInputType.MouseWheel
	)

	
	local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == modifierKey then
			modifierHeld = true
		else
			
			local pressedSlot = nil
			for i = 1, 9 do
				if input.KeyCode == numberToKeyCode[i] then
					pressedSlot = i
					break
				end
			end
			if not pressedSlot and input.KeyCode == Enum.KeyCode.Zero then
				pressedSlot = 0
			end
		
			
			if pressedSlot then
				for idx, slot in ipairs(validSlots) do
					if slot == pressedSlot then
						currentSlotIndex = idx
						break
					end
				end
			end
		end
	end)
	table.insert(connections, inputBeganConn)

	
	local inputEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.KeyCode == modifierKey then
			modifierHeld = false
		end
	end)
	table.insert(connections, inputEndedConn)

	
	local charAddedConn = player.CharacterAdded:Connect(function(newChar)
		character = newChar
		task.wait(0.2)
		if enabled then
			scanAllSlots()
		end
	end)
	table.insert(connections, charAddedConn)
end


local function unbindEvents()
	ContextActionService:UnbindAction("ScrollSwitch")

	for _, conn in ipairs(connections) do
		conn:Disconnect()
	end
	connections = {}

	modifierHeld = false
end




function ScrollSwitch:enable()
	if enabled then return end
	enabled = true

	
	character = player.Character
	if character then
		task.wait(0.2)
		scanAllSlots()
	end

	
	bindEvents()
end


function ScrollSwitch:disable()
	if not enabled then return end
	enabled = false
	unbindEvents()
end


function ScrollSwitch:unload()
	self:disable()
end


function ScrollSwitch:getbind()
	return modifierKey
end


function ScrollSwitch:setbind(newKey: Enum.KeyCode)
	if typeof(newKey) ~= "EnumItem" then
		warn("setbind 需要传入 Enum.KeyCode 类型的值")
		return
	end
	modifierKey = newKey
	print("修饰键已设置为:", modifierKey.Name)

	
	if enabled then
		
		for i = #connections, 1, -1 do
			local conn = connections[i]
			conn:Disconnect()
			table.remove(connections, i)
		end

		
		local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.KeyCode == modifierKey then
				modifierHeld = true
			end
		end)
		table.insert(connections, inputBeganConn)

		local inputEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if input.KeyCode == modifierKey then
				modifierHeld = false
			end
		end)
		table.insert(connections, inputEndedConn)
		
		modifierHeld = false
	end
end

return ScrollSwitch