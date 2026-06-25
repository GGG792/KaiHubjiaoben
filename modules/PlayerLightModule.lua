

local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))

local LocalPlayerLight = {}
LocalPlayerLight.__index = LocalPlayerLight


LocalPlayerLight._allInstances = {}


local DEFAULT_CONFIG = {
    Enabled = false,
    Brightness = 2,
    Range = 10,
    Color = Color3.fromRGB(255, 255, 255),
    Shadows = false,
    Attachment_Name = "PlayerLightAttachment",
    Offset_Position = Vector3.new(0, 1.5, 0),
    Offset_Rotation = Vector3.new(0, 0, 0),
    AttachToBodyPart = "UpperTorso",
}


local function getUniqueAttachmentName(baseName)
    local suffix = 1
    local newName = baseName
    local char = Players.LocalPlayer and Players.LocalPlayer.Character
    if char then
        
        local bodyPart = char:FindFirstChild("UpperTorso") 
            or char:FindFirstChild("Torso")
            or char:FindFirstChild("HumanoidRootPart")
        if bodyPart then
            while bodyPart:FindFirstChild(newName) do
                newName = baseName .. "_" .. suffix
                suffix += 1
            end
        end
    end
    return newName
end



local function findValidBodyPart(character, preferredPart)
    
    local part = character:FindFirstChild(preferredPart)
    if part and part:IsA("BasePart") then
        return part, preferredPart  
    end
    
    
    local alternativeParts = {
        "UpperTorso",       
        "Torso",            
        "HumanoidRootPart", 
    }
    
    for _, name in ipairs(alternativeParts) do
        if name ~= preferredPart then  
            part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then
                return part, name  
            end
        end
    end
    
    
    return nil, nil
end


local function attachLightToCharacter(self)
    self:cleanupLight()

    if not self.localPlayer or not self.localPlayer.Character then return end
    
    local character = self.localPlayer.Character
    
    
    local bodyPart, usedPartName = findValidBodyPart(character, self.config.AttachToBodyPart)
    
    if not bodyPart then
        warn("在角色 " .. character.Name .. " 上找不到挂载光源的身体部位")
        return
    end

    
    local attachment = Instance.new("Attachment")
    attachment.Name = getUniqueAttachmentName(self.config.Attachment_Name)
    attachment.CFrame = CFrame.new(self.config.Offset_Position) 
        * CFrame.Angles(
            math.rad(self.config.Offset_Rotation.X),
            math.rad(self.config.Offset_Rotation.Y),
            math.rad(self.config.Offset_Rotation.Z)
        )
    attachment.Parent = bodyPart

    
    local pointLight = Instance.new("PointLight")
    pointLight.Enabled = self._enableCache
    pointLight.Brightness = self.config.Brightness
    pointLight.Range = self.config.Range
    pointLight.Color = self.config.Color
    
    
    if usedPartName == "Torso" then
        
        pointLight.Shadows = false
    else
        
        pointLight.Shadows = self.config.Shadows
    end
    
    pointLight.Parent = attachment

    
    self.lightData = {
        Attachment = attachment,
        PointLight = pointLight,
    }
    self._isLightCreated = true
end


function LocalPlayerLight.new(customConfig)
    local self = setmetatable({}, LocalPlayerLight)

    
    self.config = table.clone(DEFAULT_CONFIG)
    self.localPlayer = Players.LocalPlayer
    self.lightData = nil
    self.characterAddedConnection = nil
    self.isLoaded = true
    self._enableCache = false
    self._isLightCreated = false

    
    if type(customConfig) == "table" then
        for k, v in pairs(customConfig) do
            if self.config[k] ~= nil then
                self.config[k] = v
            end
        end
    end

    
    self._enableCache = self.config.Enabled

    
    if not self.localPlayer then
        warn("无法获取本地玩家，光源创建失败")
        self.isLoaded = false
        table.insert(LocalPlayerLight._allInstances, self)
        return self
    end

    
    task.spawn(function()
        local character = self.localPlayer.Character or self.localPlayer.CharacterAdded:Wait()
        if not character then return end
        
        
        local bodyPartName = self.config.AttachToBodyPart
        local waited = 0
        while waited < 10 do
            local bodyPart = findValidBodyPart(character, bodyPartName)
            if bodyPart then
                break
            end
            task.wait(0.5)
            waited = waited + 0.5
        end
        
        attachLightToCharacter(self)
    end)

    
    self.characterAddedConnection = self.localPlayer.CharacterAdded:Connect(function(newCharacter)
        
        local bodyPartName = self.config.AttachToBodyPart
        local waited = 0
        while waited < 10 do
            task.wait(0.5)
            local bodyPart = findValidBodyPart(newCharacter, bodyPartName)
            if bodyPart then
                break
            end
            waited = waited + 0.5
        end
        
        attachLightToCharacter(self)
        
        if self._isLightCreated and self.lightData and self.lightData.PointLight then
            self.lightData.PointLight.Enabled = self._enableCache
        end
    end)

    
    table.insert(LocalPlayerLight._allInstances, self)
    return self
end


function LocalPlayerLight:cleanupLight()
    pcall(function() if self.lightData and self.lightData.PointLight then self.lightData.PointLight:Destroy() end end)
    pcall(function() if self.lightData and self.lightData.Attachment then self.lightData.Attachment:Destroy() end end)
    self.lightData = nil
    self._isLightCreated = false
end


function LocalPlayerLight:__index(key)
    if key == "enable" then
        return self._enableCache
    end

    local value = LocalPlayerLight[key]
    if value then
        return value
    else
        return nil
    end
end

function LocalPlayerLight:__newindex(key, value)
    if key == "enable" then
        local boolValue = not not value
        self._enableCache = boolValue

        if not self.isLoaded then
            warn("光源实例已卸载，无法修改enable")
            return
        end

        if self._isLightCreated and self.lightData and self.lightData.PointLight then
            pcall(function()
                self.lightData.PointLight.Enabled = boolValue
            end)
        end
    else
        rawset(self, key, value)
    end
end


function LocalPlayerLight:unload()
    if not self.isLoaded then
        return
    end

    
    self:cleanupLight()

    
    pcall(function() if self.characterAddedConnection then self.characterAddedConnection:Disconnect() end end)
    self.characterAddedConnection = nil

    
    self.isLoaded = false
    self._enableCache = false

    
    for i, inst in ipairs(LocalPlayerLight._allInstances) do
        if inst == self then
            table.remove(LocalPlayerLight._allInstances, i)
            break
        end
    end
end


function LocalPlayerLight:unloadAll()
    for i = #LocalPlayerLight._allInstances, 1, -1 do
        local inst = LocalPlayerLight._allInstances[i]
        if inst.isLoaded then
            inst:unload()
        end
    end
    LocalPlayerLight._allInstances = {}
end

return LocalPlayerLight