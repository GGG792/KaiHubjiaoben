
local StandRecovery = {}


function StandRecovery:init()
    local cloneref = cloneref or clonereference or function(obj) return obj end
    
    self.Players = cloneref(game:GetService("Players"))
    self.localPlayer = self.Players.LocalPlayer
    if not self.localPlayer then
        
        self.initialized = false
        return
    end

    
    self.DEFAULT_WALK_SPEED = 16
    self.DEFAULT_JUMP_POWER = 50
    self.CHECK_INTERVAL = 0.05
    self.SPEED_THRESHOLD = 50
    self.RESTORE_REPEAT_TIMES = 3
    self.RESTORE_REPEAT_INTERVAL = 0.05

    
    self.character = nil
    self.humanoid = nil
    self.humanoidRootPart = nil
    self.isDetectionEnabled = false 
    self.initialized = true 
    self.isUnloaded = false 
    self.isLoopRunning = true 
    self.characterAddedConnection = nil 
    self.isNormalJumpProcess = false 
    self.humanoidStateChangedConn = nil 

    
    self:bindCharacterAndComponents(self.localPlayer.Character)
    self.characterAddedConnection = self.localPlayer.CharacterAdded:Connect(function(newCharacter)
        self:bindCharacterAndComponents(newCharacter)
    end)

    
    self:startMainLoop()

end


function StandRecovery:bindCharacterAndComponents(newCharacter)
    
    if not self.initialized or self.isUnloaded then return end
    if not newCharacter then
        
        self.character = nil
        self.humanoid = nil
        self.humanoidRootPart = nil
        self.isNormalJumpProcess = false 
        
        if self.humanoidStateChangedConn then
            pcall(function() self.humanoidStateChangedConn:Disconnect() end)
            self.humanoidStateChangedConn = nil
        end
        return
    end

    
    self.character = newCharacter

    
    local success1, tempHumanoid = pcall(function()
        return self.character:WaitForChild("Humanoid", 3) 
    end)

    
    local success2, tempRootPart = pcall(function()
        return self.character:WaitForChild("HumanoidRootPart", 3)
    end)

    
    if not success1 or not tempHumanoid or not tempHumanoid:IsA("Humanoid") then
        
        self.humanoid = nil
        
        if self.humanoidStateChangedConn then
            pcall(function() self.humanoidStateChangedConn:Disconnect() end)
            self.humanoidStateChangedConn = nil
        end
        return
    else
        self.humanoid = tempHumanoid
        self.humanoid.AutoRotate = true

        
        self.isNormalJumpProcess = false

        
        if self.humanoidStateChangedConn then
            pcall(function() self.humanoidStateChangedConn:Disconnect() end)
        end

        
        self.humanoidStateChangedConn = self.humanoid.StateChanged:Connect(function(oldState, newState)
            
            if self.isUnloaded or not self.humanoid or not self.humanoid.Parent or not newState then
                pcall(function() self.humanoidStateChangedConn:Disconnect() end)
                self.humanoidStateChangedConn = nil
                self.isNormalJumpProcess = false
                return
            end

            
            local success, result = pcall(function()
                
                local newStateStr = tostring(newState)

                
                if newStateStr == tostring(Enum.HumanoidStateType.Jumping) then
                    self.isNormalJumpProcess = true
                end

                
                if newStateStr == tostring(Enum.HumanoidStateType.Standing) then
                    self.isNormalJumpProcess = false
                end

                
                local protectStates = {
                    tostring(Enum.HumanoidStateType.Climbing),
                    tostring(Enum.HumanoidStateType.Swimming),
                    tostring(Enum.HumanoidStateType.Dead)
                }
                if table.find(protectStates, newStateStr) then
                    self.isNormalJumpProcess = false
                end
            end)

            
            if not success then
                pcall(function() self.humanoidStateChangedConn:Disconnect() end)
                self.humanoidStateChangedConn = nil
                self.isNormalJumpProcess = false
            end
        end)
    end

    if not success2 or not tempRootPart then
        self.humanoidRootPart = nil
    else
        self.humanoidRootPart = tempRootPart
    end
end


function StandRecovery:isUncontrollable()
    
    if not self.initialized or self.isUnloaded or not self.isDetectionEnabled then
        return false
    end
    if not self.character or not self.humanoid or not self.humanoid.Parent or not self.humanoidRootPart or self.humanoid.Health <= 0 then
        self.isNormalJumpProcess = false
        return false
    end

    
    if self.isNormalJumpProcess then
        return false
    end

    
    local abnormalStates = {}
    pcall(function()
        abnormalStates = {
            Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Ragdoll,
            Enum.HumanoidStateType.Flying,
            Enum.HumanoidStateType.Freefall,
            Enum.HumanoidStateType.Seated
        }
    end)

    local currentState, inAbnormalState = nil, false
    pcall(function()
        currentState = self.humanoid:GetState()
        inAbnormalState = table.find(abnormalStates, currentState) ~= nil
    end)

    local inHighSpeed = self.humanoidRootPart.Velocity.Magnitude > self.SPEED_THRESHOLD
    local inLockedState = self.humanoid.PlatformStand or self.humanoid.WalkSpeed <= 0

    local isUncontrol = inAbnormalState or inHighSpeed or inLockedState
    if isUncontrol then
        pcall(function()
            
            
        end)
    end
    return isUncontrol
end


function StandRecovery:singleRestore()
    
    if not self.initialized or self.isUnloaded then
        return false
    end
    if not self.character or not self.humanoid or not self.humanoid.Parent or not self.humanoidRootPart then
        return false
    end

    
    pcall(function()
        self.humanoid:ChangeState(Enum.HumanoidStateType.None)
        task.wait(0.001)
        self.humanoid:ChangeState(Enum.HumanoidStateType.Standing)
        self.humanoid:ChangeState(Enum.HumanoidStateType.Standing)
    end)

    
    self.humanoid.WalkSpeed = self.DEFAULT_WALK_SPEED
    self.humanoid.JumpPower = self.DEFAULT_JUMP_POWER
    self.humanoid.PlatformStand = false
    self.humanoid.AutoRotate = true
    self.humanoid.Health = math.min(self.humanoid.Health + 1, self.humanoid.MaxHealth)

    
    self.humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    self.humanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
    local bodyPos = Instance.new("BodyPosition")
    bodyPos.Parent = self.humanoidRootPart
    bodyPos.Position = self.humanoidRootPart.Position
    bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyPos.D = 100
    bodyPos.P = 5000
    task.delay(0.1, function()
        if bodyPos and bodyPos.Parent then
            bodyPos:Destroy()
        end
    end)

    
    local removedCount = 0
    local function clearPhysicsObjects(obj)
        for _, child in pairs(obj:GetChildren()) do
            if child:IsA("BodyVelocity") or child:IsA("BodyForce") or child:IsA("BodyGyro") or child:IsA("BodyPosition") then
                pcall(function() child:Destroy() end)
                removedCount = removedCount + 1
            end
            clearPhysicsObjects(child)
        end
    end
    pcall(function() clearPhysicsObjects(self.character) end)

    
    local rootCF = self.humanoidRootPart.CFrame
    pcall(function()
        self.humanoidRootPart.CFrame = CFrame.new(rootCF.Position) * CFrame.Angles(0, rootCF:ToEulerAnglesYXZ().y, 0)
    end)

    if removedCount > 0 then
        
    end
    return true
end


function StandRecovery:batchRestore()
    
    if not self.initialized or self.isUnloaded or not self.isDetectionEnabled then
        return false
    end
    
    local successCount = 0

    for i = 1, self.RESTORE_REPEAT_TIMES do
        if self:singleRestore() then
            successCount = successCount + 1
        end
        task.wait(self.RESTORE_REPEAT_INTERVAL)
    end

    
    return successCount > 0
end


function StandRecovery:enableDetection()
    
    if not self.initialized or self.isUnloaded then
        
        return
    end
    if self.isDetectionEnabled then
        
        return
    end
    self.isDetectionEnabled = true
    
end


function StandRecovery:disableDetection()
    
    if not self.initialized or self.isUnloaded then
        
        return
    end
    if not self.isDetectionEnabled then
        
        return
    end
    self.isDetectionEnabled = false
    
end


function StandRecovery:unload()
    
    if self.isUnloaded then
        
        return
    end
    if not self.initialized then
        
        return
    end

    
    self.isUnloaded = true
    self.isDetectionEnabled = false
    self.isNormalJumpProcess = false 

    
    self.isLoopRunning = false

    
    if self.characterAddedConnection and self.characterAddedConnection.Connected then
        pcall(function() self.characterAddedConnection:Disconnect() end)
        self.characterAddedConnection = nil
    end
    if self.humanoidStateChangedConn then
        pcall(function() self.humanoidStateChangedConn:Disconnect() end)
        self.humanoidStateChangedConn = nil
    end

    
    self.character = nil
    self.humanoid = nil
    self.humanoidRootPart = nil
    self.localPlayer = nil
    self.Players = nil

    
    
    
    
    

end


function StandRecovery:startMainLoop()
    if not self.initialized then return end
    task.spawn(function() 
        while self.isLoopRunning do 
            task.wait(self.CHECK_INTERVAL)

            
            if self.isUnloaded or not self.isDetectionEnabled then
                continue
            end

            if not self.character or not self.humanoid or not self.humanoidRootPart then
                continue
            end

            
            if self:isUncontrollable() then
                pcall(function() self:batchRestore() end)
                
                local guardTime = 0.5
                local guardStart = tick()
                while tick() - guardStart < guardTime and self.isDetectionEnabled and self.isLoopRunning do
                    if self:isUncontrollable() then
                        pcall(function() self:singleRestore() end)
                    end
                    task.wait(0.01)
                end
                task.wait(0.2)
            end
        end
    end)
end


StandRecovery:init()


return StandRecovery