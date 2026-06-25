
local SpectatorModule = {}


local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService")) 


local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera
local spectatorPlayers = {}
local currentSpectateIndex = 0
local isSpectating = false


local screenGui = nil
local buttonFrame = nil
local prevButton = nil
local nextButton = nil


local renderSteppedConn = nil
local playerAddedConn = nil
local playerRemovingConn = nil
local prevClickConn = nil
local nextClickConn = nil
local keybindConn = nil


local BUTTON_STYLE = {
    NormalColor = Color3.new(0.2, 0.4, 0.8),   
    HoverColor = Color3.new(0.3, 0.5, 0.9),    
    PressColor = Color3.new(0.1, 0.3, 0.7),    
    DisabledColor = Color3.new(0.3, 0.3, 0.3), 
    TextColor = Color3.new(1, 1, 1),           
    CornerRadius = UDim.new(0, 8),              
    Font = Enum.Font.SourceSansBold,
    TextSize = 18
}


local function createGUI()
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpectatorGUI"
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = cloneref(game.CoreGui)
    else
        screenGui.Parent = gethui and gethui() or cloneref(game.CoreGui)
    end
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    
    buttonFrame = Instance.new("Frame")
    buttonFrame.Name = "ButtonFrame"
    buttonFrame.Size = UDim2.new(0, 300, 0, 50)
    buttonFrame.Position = UDim2.new(0.5, -150, 1, -110) 
    buttonFrame.BackgroundTransparency = 1 
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Visible = false 
    buttonFrame.Parent = screenGui

    
    local function createButton(name, text, position)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0, 140, 0, 40)
        button.Position = position
        button.BackgroundColor3 = BUTTON_STYLE.DisabledColor
        button.Text = text
        button.TextColor3 = BUTTON_STYLE.TextColor
        button.Font = BUTTON_STYLE.Font
        button.TextSize = BUTTON_STYLE.TextSize
        button.AutoButtonColor = false 
        button.Active = false 
        button.Parent = buttonFrame

        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = BUTTON_STYLE.CornerRadius
        corner.Parent = button

        
        button.MouseEnter:Connect(function()
            if button.Active then
                button.BackgroundColor3 = BUTTON_STYLE.HoverColor
            end
        end)
        button.MouseLeave:Connect(function()
            if button.Active then
                button.BackgroundColor3 = BUTTON_STYLE.NormalColor
            else
                button.BackgroundColor3 = BUTTON_STYLE.DisabledColor
            end
        end)
        button.MouseButton1Down:Connect(function()
            if button.Active then
                button.BackgroundColor3 = BUTTON_STYLE.PressColor
            end
        end)
        button.MouseButton1Up:Connect(function()
            if button.Active then
                button.BackgroundColor3 = BUTTON_STYLE.HoverColor
            end
        end)

        return button
    end

    
    prevButton = createButton("PreviousButton", "上一个人", UDim2.new(0, 5, 0, 5))
    nextButton = createButton("NextButton", "下一个人", UDim2.new(0, 155, 0, 5))
end


local function refreshSpectatorPlayers()
    spectatorPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            table.insert(spectatorPlayers, player)
        end
    end

    if currentSpectateIndex > #spectatorPlayers then
        currentSpectateIndex = 0
    end

    
    local hasPlayers = #spectatorPlayers > 0
    prevButton.Active = isSpectating and hasPlayers
    nextButton.Active = isSpectating and hasPlayers
    
    
    prevButton.BackgroundColor3 = prevButton.Active and BUTTON_STYLE.NormalColor or BUTTON_STYLE.DisabledColor
    nextButton.BackgroundColor3 = nextButton.Active and BUTTON_STYLE.NormalColor or BUTTON_STYLE.DisabledColor
end


local function switchToPlayer(index)
    if not isSpectating then return end
    if #spectatorPlayers == 0 then
        currentSpectateIndex = 0
        camera.CameraSubject = localPlayer.Character and localPlayer.Character.Humanoid or camera
        return
    end

    
    currentSpectateIndex = index
    if currentSpectateIndex < 1 then
        currentSpectateIndex = #spectatorPlayers
    elseif currentSpectateIndex > #spectatorPlayers then
        currentSpectateIndex = 1
    end

    local targetPlayer = spectatorPlayers[currentSpectateIndex]
    if targetPlayer and targetPlayer.Character then
        local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            camera.CameraSubject = humanoid
            camera.CameraType = Enum.CameraType.Custom
        end
    end
end


function SpectatorModule.start()
    if isSpectating then return end
    isSpectating = true

    
    if not screenGui then
        createGUI()
    end

    
    if not playerAddedConn then
        playerAddedConn = Players.PlayerAdded:Connect(refreshSpectatorPlayers)
    end
    if not playerRemovingConn then
        playerRemovingConn = Players.PlayerRemoving:Connect(refreshSpectatorPlayers)
    end
    if not prevClickConn then
        prevClickConn = prevButton.MouseButton1Click:Connect(function()
            switchToPlayer(currentSpectateIndex - 1)
        end)
    end
    if not nextClickConn then
        nextClickConn = nextButton.MouseButton1Click:Connect(function()
            switchToPlayer(currentSpectateIndex + 1)
        end)
    end
    if not renderSteppedConn then
        renderSteppedConn = RunService.RenderStepped:Connect(function()
            if not isSpectating then return end
            refreshSpectatorPlayers()

            
            local currentPlayer = spectatorPlayers[currentSpectateIndex]
            if currentPlayer and (not currentPlayer.Character or not currentPlayer.Character:FindFirstChild("Humanoid")) then
                switchToPlayer(currentSpectateIndex + 1)
            end
        end)
    end

    
    refreshSpectatorPlayers()
    buttonFrame.Visible = true

    
    if #spectatorPlayers > 0 then
        switchToPlayer(1)
    end
end


function SpectatorModule.close()
    if not isSpectating then return end
    isSpectating = false
    currentSpectateIndex = 0

    
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            camera.CameraSubject = humanoid
        end
    end
    camera.CameraType = Enum.CameraType.Custom

    
    if buttonFrame then
        buttonFrame.Visible = false
    end

    
    if prevButton then prevButton.Active = false end
    if nextButton then nextButton.Active = false end
end


function SpectatorModule.unload()
    
    SpectatorModule.close()

    
    if renderSteppedConn then
        renderSteppedConn:Disconnect()
        renderSteppedConn = nil
    end
    if playerAddedConn then
        playerAddedConn:Disconnect()
        playerAddedConn = nil
    end
    if playerRemovingConn then
        playerRemovingConn:Disconnect()
        playerRemovingConn = nil
    end
    if prevClickConn then
        prevClickConn:Disconnect()
        prevClickConn = nil
    end
    if nextClickConn then
        nextClickConn:Disconnect()
        nextClickConn = nil
    end
    if keybindConn then
        keybindConn:Disconnect()
        keybindConn = nil
    end

    
    if screenGui then
        screenGui:Destroy()
        screenGui = nil
        buttonFrame = nil
        prevButton = nil
        nextButton = nil
    end
end


return SpectatorModule