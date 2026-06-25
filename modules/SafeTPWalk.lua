
local TPWalk = {}


local cloneref = cloneref or clonereference or function(obj) return obj end
local RunService = cloneref(game:GetService("RunService"))
local Players = cloneref(game:GetService("Players"))

local _enabled = false
local _speed = 1
local _connection = nil
local _player = Players.LocalPlayer


local function update(delta)
    if not _enabled then return end
    
    local character = _player.Character
    local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
    
    if not (character and humanoid and humanoid.Parent) then
        return
    end
    
    local moveDir = humanoid.MoveDirection
    if moveDir.Magnitude > 0 then
        character:TranslateBy(moveDir * _speed * delta * 10)
    end
end


local function start()
    if _connection then return end
    _connection = RunService.Heartbeat:Connect(update)
end


local function stop()
    if _connection then
        _connection:Disconnect()
        _connection = nil
    end
end


function TPWalk:Enabled(state)
    if state == nil then
        return _enabled
    end
    _enabled = state
    if _enabled then
        start()
    else
        stop()
    end
end

function TPWalk:GetSpeed()
    return _speed
end

function TPWalk:SetSpeed(num)
    if type(num) == "number" and num >= 0 then
        _speed = num
    end
end

function TPWalk:unload()
    stop()
    _enabled = false
    _speed = 16
end

return TPWalk