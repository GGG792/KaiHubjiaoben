
local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))

local DeleteTool = {}
local enabled = false
local bindKey = Enum.KeyCode.Delete 
local inputBeganConnection = nil
local localPlayer = nil


local function getLocalPlayer()
	if localPlayer then
		return localPlayer
	end
	localPlayer = Players.LocalPlayer
	return localPlayer
end


local function getCharacter()
	local player = getLocalPlayer()
	if player then
		return player.Character
	end
	return nil
end


local function getTargetPart()
	local character = getCharacter()
	if not character then
		return nil
	end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return nil
	end
	
	
	local camera = workspace.CurrentCamera
	local direction
	
	if camera then
		
		direction = camera.CFrame.LookVector
	else
		
		direction = rootPart.CFrame.LookVector
	end
	
	
	local rayOrigin = rootPart.Position
	local rayDirection = direction * 50 
	
	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {character}
	
	
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
	
	if raycastResult then
		local instance = raycastResult.Instance
		
		
		local targetPlayer = Players:GetPlayerFromCharacter(instance.Parent)
		if targetPlayer then
			return nil
		end
		
		
		if instance.Parent and instance.Parent:IsA("Model") then
			local parentPlayer = Players:GetPlayerFromCharacter(instance.Parent)
			if parentPlayer then
				return nil
			end
		end
		
		return instance
	end
	
	return nil
end


local function onInputBegan(input, gameProcessed)
	if gameProcessed then
		return 
	end
	
	if input.KeyCode == bindKey then
		local targetPart = getTargetPart()
		if targetPart then
			
			local success, err = pcall(function()
				
				if targetPart:IsA("BasePart") then
					
					if targetPart.Parent and targetPart.Parent ~= workspace then
						local parentModel = targetPart:FindFirstAncestorOfClass("Model")
						if parentModel then
							parentModel:Destroy()
						else
							targetPart:Destroy()
						end
					end
				elseif targetPart:IsA("Model") then
					targetPart:Destroy()
				end
			end)
			
			if not success then

			end
		end
	end
end


function DeleteTool.enable()
	if enabled then
		return 
	end
	
	enabled = true
	
	
	getLocalPlayer()
	
	
	if not inputBeganConnection then
		inputBeganConnection = UserInputService.InputBegan:Connect(onInputBegan)
	end
end


function DeleteTool.disable()
	if not enabled then
		return 
	end
	
	enabled = false
	
	
	if inputBeganConnection then
		inputBeganConnection:Disconnect()
		inputBeganConnection = nil
	end
end


function DeleteTool.getbindkey()
	return bindKey
end


function DeleteTool.setbindkey(newKey)
	if typeof(newKey) ~= "EnumItem" or newKey.EnumType ~= Enum.KeyCode then
		return
	end
	
	bindKey = newKey
end


function DeleteTool.unload()
	
	DeleteTool.disable()
	
	
	localPlayer = nil
end


DeleteTool.__add = nil 

return DeleteTool