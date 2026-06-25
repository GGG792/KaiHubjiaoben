





























local SpinModule = {}


local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = Players.LocalPlayer


local isActive = false
local currentSpinBody = nil
local currentSpeed = 20
local currentCharacter = nil
local characterAddedConn = nil


local connections = {}


local function getRoot(char)
    if char and char:FindFirstChildOfClass("Humanoid") then
        return char:FindFirstChildOfClass("Humanoid").RootPart
    end
    return nil
end


local function cleanupSpinBody()
    if currentSpinBody and currentSpinBody.Parent then
        pcall(function()
            currentSpinBody:Destroy()
        end)
    end
    currentSpinBody = nil
end


local function stopSpin()
    isActive = false
    cleanupSpinBody()
    
    
    if characterAddedConn then
        characterAddedConn:Disconnect()
        characterAddedConn = nil
    end
    
    currentCharacter = nil
end


local function startSpin(speed)
    
    stopSpin()
    
    
    if speed and type(speed) == "number" and speed > 0 then
        currentSpeed = speed
    end
    
    local char = LocalPlayer.Character
    if not char then
        
        characterAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
            characterAddedConn:Disconnect()
            characterAddedConn = nil
            startSpin(currentSpeed)
        end)
        return false
    end
    
    local root = getRoot(char)
    if not root then
        return false
    end
    
    currentCharacter = char
    isActive = true
    
    
    
    currentSpinBody = Instance.new("BodyAngularVelocity")
    currentSpinBody.Name = "__SpinVelocity"
    currentSpinBody.Parent = root
    currentSpinBody.MaxTorque = Vector3.new(0, math.huge, 0)  
    currentSpinBody.AngularVelocity = Vector3.new(0, currentSpeed, 0)  
    
    
    characterAddedConn = LocalPlayer.CharacterAdded:Connect(function(newChar)
        currentCharacter = newChar
        local newRoot = getRoot(newChar)
        if newRoot and isActive then
            
            local newSpinBody = Instance.new("BodyAngularVelocity")
            newSpinBody.Name = "__SpinVelocity"
            newSpinBody.Parent = newRoot
            newSpinBody.MaxTorque = Vector3.new(0, math.huge, 0)
            newSpinBody.AngularVelocity = Vector3.new(0, currentSpeed, 0)
            
            
            cleanupSpinBody()
            currentSpinBody = newSpinBody
        end
    end)
    
    table.insert(connections, characterAddedConn)
    
    return true
end


local function updateSpinSpeed(speed)
    if currentSpinBody and currentSpinBody.Parent then
        currentSpinBody.AngularVelocity = Vector3.new(0, speed, 0)
    end
end


local function cleanupAll()
    stopSpin()
    
    for _, conn in ipairs(connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    connections = {}
end


function SpinModule.enable(speed)
    if isActive then
        
        if speed and type(speed) == "number" and speed > 0 then
            currentSpeed = speed
            updateSpinSpeed(currentSpeed)
        end
        return true
    end
    return startSpin(speed)
end


function SpinModule.disable()
    if not isActive then
        return false
    end
    stopSpin()
    return true
end


function SpinModule.isEnabled()
    return isActive
end


function SpinModule.getSpeed()
    return currentSpeed
end


function SpinModule.setSpeed(speed)
    if type(speed) ~= "number" or speed <= 0 then
        return false
    end
    
    currentSpeed = speed
    
    if isActive then
        updateSpinSpeed(currentSpeed)
    end
    
    return true
end


function SpinModule.unload()
    cleanupAll()
    
    
    SpinModule.enable = nil
    SpinModule.disable = nil
    SpinModule.isEnabled = nil
    SpinModule.getSpeed = nil
    SpinModule.setSpeed = nil
    SpinModule.unload = nil
    
    
    isActive = false
    currentSpinBody = nil
    currentSpeed = 20
    currentCharacter = nil
    characterAddedConn = nil
    connections = {}
end

return SpinModule