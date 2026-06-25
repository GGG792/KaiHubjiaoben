


local FreeCam = {}


local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))


local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera


local freecamEnabled = false      
local moduleEnabled = false        
local cameraRotation = Vector2.new()
local freecamConnection = nil
local charLock = nil
local moveVector = Vector3.new()


local currentKeybind = Enum.KeyCode.F


local eventConnections = {}


local DEFAULT_SPEED = 1.0
local cameraSpeed = DEFAULT_SPEED
local lookSensitivity = 50
local WHEEL_SENSITIVITY = 0.1



local function getRootPart()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end



local function lockCharacter()
    local root = getRootPart()
    if not root or charLock then return end
    
    charLock = Instance.new("BodyPosition")
    charLock.Name = "FreeCamLock"
    charLock.Position = root.Position
    charLock.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    charLock.D = 100
    charLock.P = 5000
    charLock.Parent = root
end

local function unlockCharacter()
    if charLock then
        charLock:Destroy()
        charLock = nil
    end
end



local function adjustSpeedWithMouseWheel(delta)
    if not freecamEnabled then return end
    
    if delta > 0 then
        cameraSpeed = cameraSpeed * (1 + WHEEL_SENSITIVITY)
    else
        cameraSpeed = cameraSpeed * (1 - WHEEL_SENSITIVITY)
    end
    
    cameraSpeed = math.max(0, cameraSpeed)
end



local function updateFreecam(dt)
    if not freecamEnabled then return end
    
    local moveSpeed = cameraSpeed * 50
    local currentMoveVector = moveVector
    
    if UserInputService:IsKeyDown(Enum.KeyCode.E) then
        currentMoveVector += Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
        currentMoveVector += Vector3.new(0, -1, 0)
    end
    
    local mouseDelta = UserInputService:GetMouseDelta()
    local sensitivity = lookSensitivity * 0.004
    
    cameraRotation += Vector2.new(
        -math.rad(mouseDelta.Y * sensitivity),
        -math.rad(mouseDelta.X * sensitivity)
    )
    
    cameraRotation = Vector2.new(
        math.clamp(cameraRotation.X, -math.pi/2, math.pi/2),
        cameraRotation.Y
    )
    
    local rotation = CFrame.fromEulerAnglesYXZ(cameraRotation.X, cameraRotation.Y, 0)
    local position = Camera.CFrame.Position
    
    if currentMoveVector.Magnitude > 0.01 and cameraSpeed > 0 then
        position += rotation:VectorToWorldSpace(currentMoveVector.Unit) * moveSpeed * dt
    end
    
    Camera.CFrame = CFrame.new(position) * rotation
end



local function internalEnable()
    if freecamEnabled then return end
    
    freecamEnabled = true
    cameraSpeed = DEFAULT_SPEED
    
    lockCharacter()
    
    local _, yaw, pitch = Camera.CFrame:ToEulerAnglesYXZ()
    cameraRotation = Vector2.new(pitch, yaw)
    
    Camera.CameraType = Enum.CameraType.Scriptable
    UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    
    freecamConnection = RunService.RenderStepped:Connect(updateFreecam)
    
    return true
end

local function internalDisable()
    if not freecamEnabled then return end
    
    freecamEnabled = false
    
    if freecamConnection then
        freecamConnection:Disconnect()
        freecamConnection = nil
    end
    
    unlockCharacter()
    
    Camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    
    moveVector = Vector3.new()
    
    return true
end



local function setModuleEnabled(value)
    if moduleEnabled == value then return end
    
    moduleEnabled = value
    
    if value then
    else
        
        if freecamEnabled then
            internalDisable()
        end
    end
end



local function onKeyPress(input, gameProcessed)
    
    if not moduleEnabled then return end
    if gameProcessed or UserInputService:GetFocusedTextBox() then return end
    
    
    if input.KeyCode == currentKeybind then
        if freecamEnabled then
            internalDisable()
        else
            internalEnable()
        end
        return
    end
    
    
    if not freecamEnabled then return end
    
    local key = input.KeyCode
    if key == Enum.KeyCode.W then
        moveVector += Vector3.new(0, 0, -1)
    elseif key == Enum.KeyCode.S then
        moveVector += Vector3.new(0, 0, 1)
    elseif key == Enum.KeyCode.A then
        moveVector += Vector3.new(-1, 0, 0)
    elseif key == Enum.KeyCode.D then
        moveVector += Vector3.new(1, 0, 0)
    end
end

local function onKeyRelease(input, gameProcessed)
    
    if not moduleEnabled or not freecamEnabled then return end
    if gameProcessed then return end
    
    local key = input.KeyCode
    if key == Enum.KeyCode.W then
        moveVector -= Vector3.new(0, 0, -1)
    elseif key == Enum.KeyCode.S then
        moveVector -= Vector3.new(0, 0, 1)
    elseif key == Enum.KeyCode.A then
        moveVector -= Vector3.new(-1, 0, 0)
    elseif key == Enum.KeyCode.D then
        moveVector -= Vector3.new(1, 0, 0)
    end
end

local function onMouseWheel(input, gameProcessed)
    
    if not moduleEnabled or not freecamEnabled then return end
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        adjustSpeedWithMouseWheel(input.Position.Z)
    end
end

local function onCharacterAdded(character)
    task.wait(0.5)
    
    if freecamEnabled then
        internalDisable()  
    else
        unlockCharacter()
    end
    
    local humanoid = character:WaitForChild("Humanoid", 2)
    if humanoid then
        Camera.CameraSubject = humanoid
        Camera.CameraType = Enum.CameraType.Custom
    end
end

local function onCharacterRemoving()
    if freecamEnabled then
        internalDisable()  
    else
        unlockCharacter()
    end
end




setmetatable(FreeCam, {
    __newindex = function(self, key, value)
        if key == "enable" then
            
            if not moduleEnabled then
                
                return
            end
            if value then
                internalEnable()
            else
                internalDisable()
            end
        elseif key == "freecamenable" then
            setModuleEnabled(value)
        else
            rawset(self, key, value)
        end
    end,
    
    __index = function(self, key)
        if key == "enable" then
            return freecamEnabled
        elseif key == "freecamenable" then
            return moduleEnabled
        end
        return rawget(self, key)
    end
})


function FreeCam.getKeybind()
    return currentKeybind
end


function FreeCam.setKeybind(newKeybind)
    
    if not moduleEnabled then
        
        return false
    end
    
    if not newKeybind or typeof(newKeybind) ~= "EnumItem" or newKeybind.EnumType ~= Enum.KeyCode then
        
        return false
    end
    
    local oldKeybind = currentKeybind
    currentKeybind = newKeybind
    
    return true
end


function FreeCam.getSpeed()
    return cameraSpeed
end


function FreeCam.unload()
    
    internalDisable()
    
    
    for _, connection in pairs(eventConnections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    table.clear(eventConnections)
    
    
    unlockCharacter()
    
    
    freecamEnabled = false
    moduleEnabled = false  
    cameraRotation = Vector2.new()
    moveVector = Vector3.new()
    cameraSpeed = DEFAULT_SPEED
    
    
    currentKeybind = Enum.KeyCode.F
    
    
    if Camera then
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                Camera.CameraSubject = humanoid
            end
        end
    end
    
    
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    
    return true
end




table.insert(eventConnections, UserInputService.InputBegan:Connect(onKeyPress))
table.insert(eventConnections, UserInputService.InputEnded:Connect(onKeyRelease))
table.insert(eventConnections, UserInputService.InputChanged:Connect(onMouseWheel))
table.insert(eventConnections, LocalPlayer.CharacterAdded:Connect(onCharacterAdded))
table.insert(eventConnections, LocalPlayer.CharacterRemoving:Connect(onCharacterRemoving))


FreeCam.version = "1.3.1"
FreeCam.author = "FreeCam Module"
FreeCam.description = "优化函数定义顺序，解决调用顺序问题"

return FreeCam