


local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))

local NPCHighlighter = {}
NPCHighlighter.__index = NPCHighlighter


function NPCHighlighter.new(options)
    local self = setmetatable({}, NPCHighlighter)
    
    options = options or {}
    
    
    self.enableHighlight = true
    self.outlineColor = options.outlineColor or Color3.fromRGB(255, 215, 0)
    self.fillColor = options.fillColor or Color3.fromRGB(255, 215, 0)
    self.highlightTransparency = options.highlightTransparency or 0.5
    
    
    self.enableNameTag = true
    self.namePrefix = options.namePrefix or "[NPC] "
    self.nameSuffix = options.nameSuffix or ""
    self.fontSize = 16
    self.showDistance = options.showDistance or false
    self.tagColor = options.tagColor or Color3.new(1, 1, 1)
    
    
    self.enabled = false
    self.isDestroyed = false
    
    
    self.npcData = {}               
    self.npcConnection = nil        
    self.removalConnection = nil    
    self.cleanupConnection = nil    
    self.heartbeatConnection = nil  
    
    
    self.batchSize = options.batchSize or 500
    self.waitTimeout = options.waitTimeout or 5  
    
    return self
end


local function isNPC(model)
    if not model:IsA("Model") then
        return false
    end
    
    local humanoid = model:FindFirstChild("Humanoid")
    if not humanoid then
        return false
    end
    
    local player = Players:GetPlayerFromCharacter(model)
    return player == nil
end


local function addHighlightToPart(part, outlineColor, fillColor, transparency)
    if not part:IsA("BasePart") then
        return nil
    end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "NPC_Highlight"
    highlight.OutlineColor = outlineColor
    highlight.FillColor = fillColor
    highlight.FillTransparency = transparency
    highlight.Parent = part
    
    return highlight
end


local function addHighlightToModel(model, outlineColor, fillColor, transparency)
    local highlights = {}
    
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("BasePart") then
            local highlight = addHighlightToPart(child, outlineColor, fillColor, transparency)
            if highlight then
                table.insert(highlights, highlight)
            end
        end
    end
    
    return highlights
end


local function createNameTag(model, adornee, text, fontSize, textColor)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NPC_NameTag"
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = textColor
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold
    label.Text = text
    label.Parent = billboard
    
    if fontSize then
        label.TextScaled = false
        label.TextSize = fontSize
    else
        label.TextScaled = true
    end
    
    return billboard, label
end


local function getAdorneeSync(model)
    
    local head = model:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        return head
    end
    
    
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:IsA("BasePart") then
        return hrp
    end
    
    
    if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
        return model.PrimaryPart
    end
    
    
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    
    return nil
end


local function waitForAdornee(model, timeout)
    
    local part = model:FindFirstChild("Head")
    if part and part:IsA("BasePart") then return part end
    part = model:FindFirstChild("HumanoidRootPart")
    if part and part:IsA("BasePart") then return part end

    
    local function tryWait(name)
        local success, result = pcall(model.WaitForChild, model, name, timeout)
        if success and result and result:IsA("BasePart") then
            return result
        end
        return nil
    end

    part = tryWait("Head") or tryWait("HumanoidRootPart")
    if part then return part end

    
    if model.PrimaryPart and model.PrimaryPart:IsA("BasePart") then
        return model.PrimaryPart
    end
    for _, child in ipairs(model:GetDescendants()) do
        if child:IsA("BasePart") then
            return child
        end
    end
    return nil
end


function NPCHighlighter:processNPC(npcModel)
    if self.npcData[npcModel] then return end
    self.npcData[npcModel] = { processing = true }

    task.spawn(function()
        local adornee = nil
        
        while self.enabled and npcModel and npcModel.Parent do
            adornee = waitForAdornee(npcModel, 2)  
            if adornee then break end
            task.wait()  
        end

        
        if not self.enabled or not npcModel or not npcModel.Parent or not adornee then
            self.npcData[npcModel] = nil
            return
        end

        local existingData = self.npcData[npcModel]
        if existingData and existingData.billboard then return end
        
        local data = {}
        
        
        if self.enableHighlight then
            data.highlights = addHighlightToModel(npcModel, self.outlineColor, self.fillColor, self.highlightTransparency)
        end
        
        
        if self.enableNameTag then
            local displayName = self.namePrefix .. npcModel.Name .. self.nameSuffix
            data.billboard, data.label = createNameTag(npcModel, adornee, displayName, self.fontSize, self.tagColor)
            data.baseName = displayName
        end
        
        
        if self.enableHighlight then
            local descendantAddedConn = npcModel.DescendantAdded:Connect(function(child)
                if child:IsA("BasePart") then
                    
                    local hasHighlight = false
                    if data.highlights then
                        for _, hl in ipairs(data.highlights) do
                            if hl and hl.Parent == child then
                                hasHighlight = true
                                break
                            end
                        end
                    end
                    
                    if not hasHighlight then
                        local highlight = addHighlightToPart(child, self.outlineColor, self.fillColor, self.highlightTransparency)
                        if highlight then
                            table.insert(data.highlights, highlight)
                        end
                    end
                end
            end)
            
            data.connections = { descendantAddedConn }
        end
        
        self.npcData[npcModel] = data
    end)
end


function NPCHighlighter:unprocessNPC(npcModel)
    local data = self.npcData[npcModel]
    if not data then
        return
    end
    
    
    if data.connections then
        for _, conn in ipairs(data.connections) do
            conn:Disconnect()
        end
    end
    
    
    if data.highlights then
        for _, highlight in ipairs(data.highlights) do
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
        end
    end
    
    
    if data.billboard and data.billboard.Parent then
        data.billboard:Destroy()
    end
    
    self.npcData[npcModel] = nil
end


function NPCHighlighter:updateDistances()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then
        return
    end
    
    local character = localPlayer.Character
    if not character then
        return
    end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not rootPart then
        return
    end
    
    for npcModel, data in pairs(self.npcData) do
        if data and not data.processing then  
            if npcModel and npcModel.Parent then
                if data.billboard and data.billboard.Adornee and data.label then
                    local adornee = data.billboard.Adornee
                    if adornee and adornee.Parent then
                        local distance = (adornee.Position - rootPart.Position).Magnitude
                        data.label.Text = string.format("%s (%.1f)", data.baseName, distance)
                    end
                end
            else
                self:unprocessNPC(npcModel)
            end
        end
    end
end


function NPCHighlighter:scanExisting()
    local allObjects = Workspace:GetDescendants()
    
    
    for _, obj in ipairs(allObjects) do
        if isNPC(obj) then
            self:processNPC(obj)
        end
    end
end


function NPCHighlighter:startListeners()
    
    if self.npcConnection then
        self.npcConnection:Disconnect()
    end
    self.npcConnection = Workspace.DescendantAdded:Connect(function(descendant)
        if self.enabled and isNPC(descendant) then
            self:processNPC(descendant)
        end
    end)
    
    
    if self.removalConnection then
        self.removalConnection:Disconnect()
    end
    self.removalConnection = Workspace.DescendantRemoving:Connect(function(descendant)
        if isNPC(descendant) then
            self:unprocessNPC(descendant)
        end
    end)
    
    
    if self.cleanupConnection then
        self.cleanupConnection:Disconnect()
    end
    self.cleanupConnection = RunService.Heartbeat:Connect(function()
        if not self.enabled then
            return
        end
        
        local toRemove = {}
        for npcModel, data in pairs(self.npcData) do
            if data and not data.processing then
                if not npcModel or not npcModel.Parent then
                    table.insert(toRemove, npcModel)
                end
            end
        end
        
        for _, npcModel in ipairs(toRemove) do
            self:unprocessNPC(npcModel)
        end
    end)
    
    
    if self.showDistance then
        if self.heartbeatConnection then
            self.heartbeatConnection:Disconnect()
        end
        self.heartbeatConnection = RunService.Heartbeat:Connect(function()
            self:updateDistances()
        end)
    end
end


function NPCHighlighter:stopListeners()
    if self.npcConnection then
        self.npcConnection:Disconnect()
        self.npcConnection = nil
    end
    
    if self.removalConnection then
        self.removalConnection:Disconnect()
        self.removalConnection = nil
    end
    
    if self.cleanupConnection then
        self.cleanupConnection:Disconnect()
        self.cleanupConnection = nil
    end
    
    if self.heartbeatConnection then
        self.heartbeatConnection:Disconnect()
        self.heartbeatConnection = nil
    end
end


function NPCHighlighter:enable()
    if self.enabled then
        return
    end
    
    self.enabled = true
    self:startListeners()
    self:scanExisting()
end


function NPCHighlighter:disable()
    if not self.enabled then
        return
    end
    
    self.enabled = false
    self:stopListeners()
    
    for npcModel, _ in pairs(self.npcData) do
        self:unprocessNPC(npcModel)
    end
    
    self.npcData = {}
end


function NPCHighlighter:unload()
    if self.isDestroyed then
        return
    end
    
    self:disable()
    self.isDestroyed = true
end


function NPCHighlighter:getCount()
    local count = 0
    for npcModel, data in pairs(self.npcData) do
        if data and not data.processing and npcModel and npcModel.Parent then
            count = count + 1
        end
    end
    return count
end


function NPCHighlighter:getNPCs()
    local npcs = {}
    for npcModel, data in pairs(self.npcData) do
        if data and not data.processing and npcModel and npcModel.Parent then
            table.insert(npcs, npcModel)
        end
    end
    return npcs
end


function NPCHighlighter:setColor(outlineColor, fillColor)
    self.outlineColor = outlineColor
    self.fillColor = fillColor or outlineColor
    
    for _, data in pairs(self.npcData) do
        if data and data.highlights then
            for _, highlight in ipairs(data.highlights) do
                if highlight and highlight.Parent then
                    highlight.OutlineColor = self.outlineColor
                    highlight.FillColor = self.fillColor
                end
            end
        end
    end
end

return NPCHighlighter