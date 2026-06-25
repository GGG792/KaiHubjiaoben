local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local ContextActionService = cloneref(game:GetService("ContextActionService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local localPlayer = Players.LocalPlayer
local module = {}


local enabled = false          
local moveDistance = 10        


local ACTION_MOVE_FORWARD = "MoveForward"
local ACTION_MOVE_BACKWARD = "MoveBackward"
local ACTION_MOVE_LEFT = "MoveLeft"
local ACTION_MOVE_RIGHT = "MoveRight"


local function getRootPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart)
end


local function onAction(actionName, inputState, input)
    
    if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
    
    if UserInputService:GetFocusedTextBox() then return Enum.ContextActionResult.Pass end

    
    local character = localPlayer.Character
    if not character then return Enum.ContextActionResult.Pass end
    local rootPart = getRootPart(character)
    if not rootPart then return Enum.ContextActionResult.Pass end

    
    local moveVec
    if actionName == ACTION_MOVE_FORWARD then
        moveVec = rootPart.CFrame.LookVector * moveDistance      
    elseif actionName == ACTION_MOVE_BACKWARD then
        moveVec = -rootPart.CFrame.LookVector * moveDistance     
    elseif actionName == ACTION_MOVE_LEFT then
        moveVec = -rootPart.CFrame.RightVector * moveDistance    
    elseif actionName == ACTION_MOVE_RIGHT then
        moveVec = rootPart.CFrame.RightVector * moveDistance     
    end

    
    moveVec = Vector3.new(moveVec.X, 0, moveVec.Z)

    
    rootPart.CFrame = rootPart.CFrame + moveVec

    
    return Enum.ContextActionResult.Sink
end


function module.Enable()
    if enabled then return end
    enabled = true

    
    
    ContextActionService:BindActionAtPriority(
        ACTION_MOVE_FORWARD,
        onAction,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.Up
    )
    ContextActionService:BindActionAtPriority(
        ACTION_MOVE_BACKWARD,
        onAction,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.Down
    )
    ContextActionService:BindActionAtPriority(
        ACTION_MOVE_LEFT,
        onAction,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.Left
    )
    ContextActionService:BindActionAtPriority(
        ACTION_MOVE_RIGHT,
        onAction,
        false,
        Enum.ContextActionPriority.High.Value,
        Enum.KeyCode.Right
    )
end


function module.Disable()
    if not enabled then return end
    enabled = false

    ContextActionService:UnbindAction(ACTION_MOVE_FORWARD)
    ContextActionService:UnbindAction(ACTION_MOVE_BACKWARD)
    ContextActionService:UnbindAction(ACTION_MOVE_LEFT)
    ContextActionService:UnbindAction(ACTION_MOVE_RIGHT)
end


function module.Unload()
    
    module.Disable()
    
    
    moveDistance = 10
    
    
    module.Enable = nil
    module.Disable = nil
    module.SetDistance = nil
    module.GetDistance = nil
    module.Unload = nil
    
    
    
end


function module.SetDistance(distance)
    assert(type(distance) == "number" and distance >= 0, "Distance must be a non-negative number")
    moveDistance = distance
end


function module.GetDistance()
    return moveDistance
end

return module