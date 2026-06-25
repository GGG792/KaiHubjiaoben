


local LandingEffect = {}


local enabled = false
local connections = {}
local cloneref = cloneref or clonereference or function(obj) return obj end
local tweenService = cloneref(game:GetService("TweenService"))
local debrisService = cloneref(game:GetService("Debris"))
local runService = cloneref(game:GetService("RunService"))
local userInputService = cloneref(game:GetService("UserInputService"))
local Workspace = cloneref(game:GetService("Workspace"))


local PARTICLE_SETTINGS = {
    Color = Color3.fromRGB(100, 150, 255),
    Material = Enum.Material.Neon,
    Transparency = 0.3,
    CanCollide = false,
    Anchored = true,
    CastShadow = false
}


local ANIMATION_SETTINGS = {
    StartRadius = 1,
    EndRadius = 6,
    Duration = 1.0
}


local Players = cloneref(game:GetService("Players"))
local player = Players.LocalPlayer
local character = nil
local humanoid = nil
local humanoidRootPart = nil
local wasJumping = false
local jumpStartTime = 0


local function initCharacter()
    
    character = player.Character
    
    if character then
        
        humanoid = character:WaitForChild("Humanoid")
        humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        return true
    else
        
        return false
    end
end


local function createLandingEffect(position)
    
    local ring = Instance.new("Part")
    ring.Name = "LandingRing"
    
    
    for prop, value in pairs(PARTICLE_SETTINGS) do
        ring[prop] = value
    end
    
    
    ring.Shape = Enum.PartType.Cylinder
    local startSize = ANIMATION_SETTINGS.StartRadius * 2
    ring.Size = Vector3.new(0.1, startSize, startSize)
    
    
    ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring.Parent = Workspace
    
    
    local pointLight = Instance.new("PointLight")
    pointLight.Color = PARTICLE_SETTINGS.Color
    pointLight.Brightness = 1.5
    pointLight.Range = 8
    pointLight.Parent = ring
    
    
    local tweenInfo = TweenInfo.new(
        ANIMATION_SETTINGS.Duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    
    local endSize = ANIMATION_SETTINGS.EndRadius * 2
    local sizeGoal = {Size = Vector3.new(0.1, endSize, endSize)}
    
    
    local transparencyGoal = {Transparency = 1}
    
    
    local lightGoal = {Brightness = 0}
    
    
    local sizeTween = tweenService:Create(ring, tweenInfo, sizeGoal)
    local transparencyTween = tweenService:Create(ring, tweenInfo, transparencyGoal)
    local lightTween = tweenService:Create(pointLight, tweenInfo, lightGoal)
    
    sizeTween:Play()
    transparencyTween:Play()
    lightTween:Play()
    
    
    debrisService:AddItem(ring, ANIMATION_SETTINGS.Duration + 0.5)
end


local function setupJumpDetection()
    if not character or not humanoid then
        return false
    end
    
    
    wasJumping = false
    jumpStartTime = 0
    
    
    local heartbeatConnection = runService.Heartbeat:Connect(function()
        if not humanoid or not humanoidRootPart then 
            
            if character and character.Parent then
                humanoid = character:FindFirstChild("Humanoid")
                humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            end
            if not humanoid or not humanoidRootPart then
                return
            end
        end
        
        local state = humanoid:GetState()
        
        
        if state == Enum.HumanoidStateType.Jumping and not wasJumping then
            wasJumping = true
            jumpStartTime = tick()
            
        
        elseif wasJumping and state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall then
            local jumpDuration = tick() - jumpStartTime
            
            
            if jumpDuration > 0.2 and jumpDuration < 2 then
                createLandingEffect(humanoidRootPart.Position - Vector3.new(0, 3, 0))
            end
            
            wasJumping = false
        end
    end)
    
    table.insert(connections, heartbeatConnection)
    
    
    local stateChangedConnection = humanoid.StateChanged:Connect(function(oldState, newState)
        
        if oldState == Enum.HumanoidStateType.Jumping and 
           (newState == Enum.HumanoidStateType.Running or 
            newState == Enum.HumanoidStateType.RunningNoPhysics or
            newState == Enum.HumanoidStateType.Climbing or
            newState == Enum.HumanoidStateType.Seated or
            newState == Enum.HumanoidStateType.Landed) then
            
            local jumpDuration = tick() - jumpStartTime
            
            if jumpDuration > 0.2 and jumpDuration < 2 then
                createLandingEffect(humanoidRootPart.Position - Vector3.new(0, 3, 0))
            end
        end
        
        
        if newState == Enum.HumanoidStateType.Jumping then
            wasJumping = true
            jumpStartTime = tick()
        end
    end)
    
    table.insert(connections, stateChangedConnection)
    
    
    local diedConnection = humanoid.Died:Connect(function()
        wasJumping = false
        
        
        character = nil
        humanoid = nil
        humanoidRootPart = nil
        
        
        local charAddedConnection
        charAddedConnection = player.CharacterAdded:Connect(function(newCharacter)
            
            task.wait(0.5)
            
            character = newCharacter
            humanoid = character:WaitForChild("Humanoid")
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            
            
            if enabled then
                
                for _, conn in ipairs(connections) do
                    if conn.Connected then
                        conn:Disconnect()
                    end
                end
                connections = {}
                
                
                setupJumpDetection()
            end
            
            
            if charAddedConnection then
                charAddedConnection:Disconnect()
            end
        end)
    end)
    
    table.insert(connections, diedConnection)
    
    return true
end


function LandingEffect.enable()
    if enabled then
        return
    end
    
    
    local charInitialized = initCharacter()
    
    if not charInitialized then
        
        local charAddedConnection
        charAddedConnection = player.CharacterAdded:Connect(function(newCharacter)
            character = newCharacter
            humanoid = character:WaitForChild("Humanoid")
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            
            
            setupJumpDetection()
            
            
            if charAddedConnection then
                charAddedConnection:Disconnect()
            end
        end)
        
        
        table.insert(connections, charAddedConnection)
    else
        
        setupJumpDetection()
    end
    
    enabled = true
end


function LandingEffect.disable()
    if not enabled then
        return
    end
    
    
    
    for _, connection in ipairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    
    
    connections = {}
    
    
    wasJumping = false
    enabled = false
    
end


function LandingEffect.unload()
    
    
    LandingEffect.disable()
    
    
    character = nil
    humanoid = nil
    humanoidRootPart = nil
    
    
    for key in pairs(LandingEffect) do
        LandingEffect[key] = nil
    end
    
    
    setmetatable(LandingEffect, {
        __index = function()
            error("LandingEffect模块已被卸载")
        end
    })

end


function LandingEffect.isEnabled()
    return enabled
end


function LandingEffect.test()
    if character and humanoidRootPart then
        createLandingEffect(humanoidRootPart.Position - Vector3.new(0, 3, 0))
    else
    end
end

return LandingEffect