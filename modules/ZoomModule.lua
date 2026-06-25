


local ZoomModule = {}
ZoomModule.__index = ZoomModule


local cloneref = cloneref or clonereference or function(obj) return obj end
local UserInputService = cloneref(game:GetService("UserInputService"))
local TweenService = cloneref(game:GetService("TweenService"))
local Workspace = cloneref(game:GetService("Workspace"))


function ZoomModule.new()
    local self = setmetatable({}, ZoomModule)
    
    
    self.config = {
        
        bindKey = Enum.KeyCode.C,
        
        tweenTime = 0.15,
        
        zoomStep = 5,
        
        minZoomFOV = 5,               
        
        defaultZoomFOV = 30,
    }
    
    
    self.isEnabled = false
    self.isZooming = false
    self.normalFOV = 70              
    self.currentZoomFOV = self.config.defaultZoomFOV  
    
    
    self.connections = {
        inputBegan = nil,
        inputEnded = nil,
    }
    
    self.camera = Workspace.CurrentCamera
    return self
end


function ZoomModule:GetNormalFOV()
    return self.normalFOV
end


function ZoomModule:SetNormalFOV(fov)
    self.normalFOV = fov
    if not self.isZooming and self.isEnabled then
        self.camera.FieldOfView = self.normalFOV
    end
end


function ZoomModule:UpdateCameraFOV(targetFOV)
    local tween = TweenService:Create(self.camera, TweenInfo.new(self.config.tweenTime), {FieldOfView = targetFOV})
    tween:Play()
end


function ZoomModule:AdjustZoom(delta)
    if not self.isZooming or not self.isEnabled then return end
    
    local step = delta * self.config.zoomStep
    local newZoomFOV = self.currentZoomFOV + step
    newZoomFOV = math.clamp(newZoomFOV, self.config.minZoomFOV, self.normalFOV)
    
    if newZoomFOV == self.currentZoomFOV then return end
    
    self.currentZoomFOV = newZoomFOV
    self:UpdateCameraFOV(self.currentZoomFOV)
end


function ZoomModule:StartZoom()
    if not self.isEnabled then return end
    
    self.isZooming = true
    
    self.currentZoomFOV = self.config.defaultZoomFOV
    self:UpdateCameraFOV(self.currentZoomFOV)
end


function ZoomModule:StopZoom()
    if not self.isEnabled then return end
    
    self.isZooming = false
    self:UpdateCameraFOV(self.normalFOV)
end


function ZoomModule:SetBindKey(keyType)
    self.config.bindKey = keyType
end


function ZoomModule:GetBindKey()
    return self.config.bindKey
end


function ZoomModule:SetMinZoomFOV(minFOV)
    self.config.minZoomFOV = minFOV
    
    if self.isZooming and self.currentZoomFOV < minFOV then
        self.currentZoomFOV = minFOV
        self:UpdateCameraFOV(self.currentZoomFOV)
    end
end


function ZoomModule:GetMinZoomFOV()
    return self.config.minZoomFOV
end


function ZoomModule:SetDefaultZoomFOV(defaultFOV)
    self.config.defaultZoomFOV = math.clamp(defaultFOV, self.config.minZoomFOV, self.normalFOV)
end


function ZoomModule:GetDefaultZoomFOV()
    return self.config.defaultZoomFOV
end


function ZoomModule:SetZoomStep(step)
    self.config.zoomStep = step
end


function ZoomModule:GetZoomStep()
    return self.config.zoomStep
end


function ZoomModule:SetTweenTime(time)
    self.config.tweenTime = time
end


function ZoomModule:GetTweenTime()
    return self.config.tweenTime
end


function ZoomModule:IsMatchingInput(input)
    return input.UserInputType == self.config.bindKey or input.KeyCode == self.config.bindKey
end


function ZoomModule:Enable()
    if self.isEnabled then return end
    
    
    self.normalFOV = self.camera.FieldOfView
    
    
    self.config.defaultZoomFOV = math.clamp(self.config.defaultZoomFOV, self.config.minZoomFOV, self.normalFOV)
    self.currentZoomFOV = self.config.defaultZoomFOV
    
    
    self.connections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        
        if self:IsMatchingInput(input) then
            self:StartZoom()
        end
        
        
        if self.isZooming then
            if input.KeyCode == Enum.KeyCode.Minus then
                self:AdjustZoom(-1)   
                input:Processed()
            elseif input.KeyCode == Enum.KeyCode.Equals then
                self:AdjustZoom(1)    
                input:Processed()
            end
        end
    end)
    
    self.connections.inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        
        if self:IsMatchingInput(input) then
            self:StopZoom()
        end
    end)
    
    self.isEnabled = true
end


function ZoomModule:Disable()
    if not self.isEnabled then return end
    
    if self.isZooming then
        self:StopZoom()
        self.isZooming = false
    end
    
    
    if self.connections.inputBegan then
        self.connections.inputBegan:Disconnect()
        self.connections.inputBegan = nil
    end
    
    if self.connections.inputEnded then
        self.connections.inputEnded:Disconnect()
        self.connections.inputEnded = nil
    end
    
    self.isEnabled = false
end


function ZoomModule:Unload()
    self:Disable()
    self.camera = nil
    self.config = nil
    self.connections = nil
    self.isEnabled = nil
    self.isZooming = nil
    self.normalFOV = nil
    self.currentZoomFOV = nil
end

return ZoomModule