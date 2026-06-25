

















local LoopOofModule = {}


local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = Players.LocalPlayer


local isActive = false
local currentLoop = nil
local currentPlayers = {}


local connections = {}


local function getOofSound(character)
    if not character then return nil end
    
    local head = character:FindFirstChild("Head")
    if not head then return nil end
    
    
    for _, sound in pairs(head:GetChildren()) do
        if sound:IsA("Sound") then
            return sound
        end
    end
    
    return nil
end


local function playOofSound(player)
    if not player or not player.Character then return false end
    
    local character = player.Character
    local oofSound = getOofSound(character)
    
    if oofSound then
        pcall(function()
            oofSound.Playing = true
        end)
        return true
    end
    return false
end


local function playAllOofSounds()
    for _, player in pairs(currentPlayers) do
        if player and player.Character then
            playOofSound(player)
        end
    end
end


local function updatePlayerList()
    currentPlayers = {}
    for _, player in pairs(Players:GetPlayers()) do
        table.insert(currentPlayers, player)
    end
end


local function startLoop()
    if currentLoop then
        currentLoop:Disconnect()
        currentLoop = nil
    end
    
    isActive = true
    updatePlayerList()
    
    
    currentLoop = RunService.Heartbeat:Connect(function()
        if not isActive then
            if currentLoop then
                currentLoop:Disconnect()
                currentLoop = nil
            end
            return
        end
        
        playAllOofSounds()
        task.wait(0.1)
    end)
    
    
    local playerAddedConn = Players.PlayerAdded:Connect(function(player)
        table.insert(currentPlayers, player)
    end)
    table.insert(connections, playerAddedConn)
    
    local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
        for i, p in ipairs(currentPlayers) do
            if p == player then
                table.remove(currentPlayers, i)
                break
            end
        end
    end)
    table.insert(connections, playerRemovingConn)
    
    
    table.insert(connections, currentLoop)
end


local function stopLoop()
    isActive = false
    if currentLoop then
        currentLoop:Disconnect()
        currentLoop = nil
    end
end


local function cleanupAll()
    stopLoop()
    
    for _, conn in ipairs(connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    connections = {}
    currentPlayers = {}
end


function LoopOofModule.enable()
    if isActive then
        return false
    end
    startLoop()
    return true
end


function LoopOofModule.disable()
    if not isActive then
        return false
    end
    stopLoop()
    return true
end


function LoopOofModule.isEnabled()
    return isActive
end


function LoopOofModule.unload()
    cleanupAll()
    
    
    LoopOofModule.enable = nil
    LoopOofModule.disable = nil
    LoopOofModule.isEnabled = nil
    LoopOofModule.unload = nil
    
    
    isActive = false
    currentLoop = nil
    currentPlayers = {}
    connections = {}
end

return LoopOofModule