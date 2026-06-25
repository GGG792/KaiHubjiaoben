
































local HandleKillModule = {}


local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local LocalPlayer = Players.LocalPlayer


local isActive = false
local currentLoop = nil
local currentTargets = {}
local currentRange = math.huge


local connections = {}


local function getRoot(char)
    if char and char:FindFirstChildOfClass("Humanoid") then
        return char:FindFirstChildOfClass("Humanoid").RootPart
    end
    return nil
end


local function parseRange(range)
    if range == nil then
        return math.huge
    end
    
    if type(range) == "string" and range:lower() == "infinity" then
        return math.huge
    end
    
    if type(range) == "number" and range > 0 then
        return range
    end
    
    return math.huge
end


local function parsePlayers(input)
    local result = {}
    
    
    if type(input) == "string" and input:lower() == "all" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(result, player)
            end
        end
        return result
    end
    
    
    if type(input) == "string" then
        for _, player in pairs(Players:GetPlayers()) do
            if player.Name:lower() == input:lower() or 
               (player.DisplayName and player.DisplayName:lower() == input:lower()) then
                if player ~= LocalPlayer then
                    table.insert(result, player)
                end
                break
            end
        end
        return result
    end
    
    
    if type(input) == "userdata" and input:IsA("Player") then
        if input ~= LocalPlayer then
            table.insert(result, input)
        end
        return result
    end
    
    
    if type(input) == "table" then
        for _, item in ipairs(input) do
            if type(item) == "string" then
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Name:lower() == item:lower() or 
                       (player.DisplayName and player.DisplayName:lower() == item:lower()) then
                        if player ~= LocalPlayer and not table.find(result, player) then
                            table.insert(result, player)
                        end
                    end
                end
            elseif type(item) == "userdata" and item:IsA("Player") then
                
                if item ~= LocalPlayer and not table.find(result, item) then
                    table.insert(result, item)
                end
            end
        end
        return result
    end
    
    return result
end


local function isInRange(player, range)
    if range == math.huge then return true end
    local char = LocalPlayer.Character
    local targetChar = player.Character
    if not char or not targetChar then return false end
    
    local root = getRoot(char)
    local targetRoot = getRoot(targetChar)
    if not root or not targetRoot then return false end
    
    return (root.Position - targetRoot.Position).magnitude <= range
end


local function getFireTouchInterest()
    
    local fireFunc = syn and syn.fire_touch_interest
    
    if not fireFunc then
        fireFunc = firetouchinterest
    end
    
    if not fireFunc then
        local env = getrenv and getrenv()
        if env then
            fireFunc = env.firetouchinterest
        end
    end
    
    if not fireFunc then
        local gc = getgc and getgc()
        if gc then
            for _, v in pairs(gc) do
                if type(v) == "function" and tostring(v):find("firetouchinterest") then
                    fireFunc = v
                    break
                end
            end
        end
    end
    
    return fireFunc
end


local function startKillLoop(targetPlayers, range)
    
    if currentLoop then
        currentLoop:Disconnect()
        currentLoop = nil
    end
    
    if not targetPlayers or #targetPlayers == 0 then
        isActive = false
        return false
    end
    
    currentTargets = targetPlayers
    currentRange = range
    isActive = true
    
    
    local function validateTool()
        local char = LocalPlayer.Character
        if not char then return false, nil, nil end
        
        
        local tool = nil
        for _, child in pairs(char:GetChildren()) do
            if child:IsA("Tool") then
                tool = child
                break
            end
        end
        
        if not tool then return false, nil, nil end
        
        local handle = tool:FindFirstChild("Handle")
        if not handle then return false, nil, nil end
        
        return true, tool, handle
    end
    
    
    local firetouchinterestFunc = getFireTouchInterest()
    
    if not firetouchinterestFunc then
        isActive = false
        return false
    end
    
    
    currentLoop = RunService.Heartbeat:Connect(function()
        if not isActive then
            if currentLoop then currentLoop:Disconnect() end
            currentLoop = nil
            return
        end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local success, tool, handle = validateTool()
        if not success or not tool or not handle then
            
            if currentLoop then currentLoop:Disconnect() end
            currentLoop = nil
            isActive = false
            return
        end
        
        
        if tool.Parent ~= char then
            return
        end
        
        
        for i = #currentTargets, 1, -1 do
            local player = currentTargets[i]
            
            
            if not player or not player:IsDescendantOf(Players) then
                table.remove(currentTargets, i)
                break
            end
            
            
            local targetChar = player.Character
            if not targetChar then
                break
            end
            
            local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then
                break
            end
            
            
            if not isInRange(player, currentRange) then
                break
            end
            
            
            local state = humanoid:GetState()
            if state == Enum.HumanoidStateType.Dead then
                break
            end
            
            
            local targetRoot = getRoot(targetChar)
            if targetRoot then
                pcall(function()
                    
                    firetouchinterestFunc(handle, targetRoot, 0)
                    firetouchinterestFunc(handle, targetRoot, 1)
                end)
            end
        end
        
        
        if #currentTargets == 0 then
            if currentLoop then currentLoop:Disconnect() end
            currentLoop = nil
            isActive = false
        end
    end)
    
    
    table.insert(connections, currentLoop)
    
    return true
end


local function stopKill()
    isActive = false
    if currentLoop then
        currentLoop:Disconnect()
        currentLoop = nil
    end
    currentTargets = {}
    currentRange = math.huge
end


local function cleanupAll()
    stopKill()
    
    for _, conn in ipairs(connections) do
        if conn and conn.Disconnect then
            pcall(function() conn:Disconnect() end)
        end
    end
    connections = {}
end


function HandleKillModule.kill(targets, range)
    
    stopKill()
    
    
    local parsedRange = parseRange(range)
    
    
    local playerList = parsePlayers(targets)
    
    if #playerList == 0 then
        return false
    end
    
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hasTool = false
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Tool") then
            local handle = child:FindFirstChild("Handle")
            if handle then
                hasTool = true
                break
            end
        end
    end
    
    if not hasTool then
        return false
    end
    
    
    if not getFireTouchInterest() then
        return false
    end
    
    
    return startKillLoop(playerList, parsedRange)
end


function HandleKillModule.stop()
    stopKill()
end


function HandleKillModule.isRunning()
    return isActive
end


function HandleKillModule.getTargetCount()
    return #currentTargets
end


function HandleKillModule.unload()
    cleanupAll()
    
    
    HandleKillModule.kill = nil
    HandleKillModule.stop = nil
    HandleKillModule.isRunning = nil
    HandleKillModule.getTargetCount = nil
    HandleKillModule.unload = nil
    
    
    isActive = false
    currentLoop = nil
    currentTargets = {}
    currentRange = math.huge
    connections = {}
end

return HandleKillModule