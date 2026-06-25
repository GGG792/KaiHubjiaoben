local TeleportModule = {}

local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))


local function isValidCharacter(player)
    local character = player.Character
    if not character then
        return false, nil, nil
    end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not hrp or not humanoid or humanoid.Health <= 0 then
        return false, nil, nil
    end
    return true, hrp, character
end


local function collectTargets(partNames)
    local targets = {}
    
    local nameList = {}
    if type(partNames) == "string" then
        nameList = {partNames}
    elseif type(partNames) == "table" then
        nameList = partNames
    else
        return targets
    end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            for _, targetName in ipairs(nameList) do
                if obj.Name == targetName then
                    table.insert(targets, obj)
                    break
                end
            end
        end
    end
    return targets
end


local function sortByDistance(hrp, targets)
    local playerPos = hrp.Position
    table.sort(targets, function(a, b)
        local distA = (a.Position - playerPos).Magnitude
        local distB = (b.Position - playerPos).Magnitude
        return distA < distB
    end)
end




function TeleportModule.TeleportToParts(partNames, delay)
    delay = delay or 0.1
    local player = Players.LocalPlayer
    
    
    local valid, hrp = isValidCharacter(player)
    if not valid then
        return
    end
    
    
    local targets = collectTargets(partNames)
    if #targets == 0 then
        return
    end
    
    
    sortByDistance(hrp, targets)
    
    for i, part in ipairs(targets) do
        
        local validNow, currentHrp = isValidCharacter(player)
        if not validNow then
            break
        end
        hrp = currentHrp
        
        local targetPos = part.Position + Vector3.new(0, 2, 0)
        hrp.CFrame = CFrame.new(targetPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        
        task.wait(delay)
    end
end

return TeleportModule