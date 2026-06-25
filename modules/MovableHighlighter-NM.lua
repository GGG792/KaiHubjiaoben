




local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))

local MovableHighlighter = {}


local DEFAULT_CONFIG = {
    fillColor = Color3.fromRGB(255, 215, 0),      
    outlineColor = Color3.fromRGB(255, 215, 0),     
    fillTransparency = 0.7,
    outlineTransparency = 0.0,
    maxHeight = 100,                               
    excludedNames = {"Camera", "Terrain"},         
    batchSize = 80,                                
}


local instances = {}




local Highlighter = {}
Highlighter.__index = Highlighter


function MovableHighlighter.new(config)
    local self = setmetatable({}, Highlighter)
    self.config = {}
    for k, v in pairs(DEFAULT_CONFIG) do
        self.config[k] = config and config[k] ~= nil and config[k] or v
    end
    self.enabled = false
    self.activeHighlights = {}          
    self.scanConnection = nil           
    self.descendantConnection = nil     
    self.pendingTask = nil              
    table.insert(instances, self)
    return self
end




local function isValidPart(self, part)
    
    if not part:IsA("BasePart") then
        return false
    end
    
    if part.Anchored then
        return false
    end
    
    local model = part
    while model and not model:IsA("Model") do
        model = model.Parent
    end
    if model and Players:GetPlayerFromCharacter(model) then
        return false
    end
    
    if table.find(self.config.excludedNames, part.Name) then
        return false
    end
    
    if part.Position.Y >= self.config.maxHeight then
        return false
    end
    return true
end




local function addHighlightToPart(self, part)
    if self.activeHighlights[part] then
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Name = "MovableObjectHighlight"
    highlight.FillColor = self.config.fillColor
    highlight.OutlineColor = self.config.outlineColor
    highlight.FillTransparency = self.config.fillTransparency
    highlight.OutlineTransparency = self.config.outlineTransparency
    highlight.Adornee = part
    highlight.Parent = part
    self.activeHighlights[part] = highlight
end




local function removeAllHighlights(self)
    for part, highlight in pairs(self.activeHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    self.activeHighlights = {}
end




local function scanExistingAsync(self)
    if self.scanConnection then
        self.scanConnection:Disconnect()
        self.scanConnection = nil
    end
    
    local allObjects = Workspace:GetDescendants()
    local relevant = {}
    for _, obj in ipairs(allObjects) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            table.insert(relevant, obj)
        end
    end
    local total = #relevant
    local processed = 0
    local batchSize = self.config.batchSize
    local taskId = {}
    self.pendingTask = taskId

    self.scanConnection = RunService.RenderStepped:Connect(function()
        if not self.enabled or taskId ~= self.pendingTask then
            if self.scanConnection then
                self.scanConnection:Disconnect()
                self.scanConnection = nil
            end
            return
        end
        local endIdx = math.min(processed + batchSize, total)
        for i = processed + 1, endIdx do
            local obj = relevant[i]
            if obj:IsA("BasePart") and isValidPart(self, obj) then
                addHighlightToPart(self, obj)
            elseif obj:IsA("Model") then
                
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") and isValidPart(self, part) then
                        addHighlightToPart(self, part)
                    end
                end
            end
        end
        processed = endIdx
        if processed >= total then
            if self.scanConnection then
                self.scanConnection:Disconnect()
                self.scanConnection = nil
            end
            self.pendingTask = nil
        end
    end)
end




local function startListeners(self)
    if self.descendantConnection then
        self.descendantConnection:Disconnect()
        self.descendantConnection = nil
    end
    self.descendantConnection = Workspace.DescendantAdded:Connect(function(desc)
        if not self.enabled then return end
        if desc:IsA("BasePart") and isValidPart(self, desc) then
            addHighlightToPart(self, desc)
        elseif desc:IsA("Model") then
            
            for _, part in ipairs(desc:GetDescendants()) do
                if part:IsA("BasePart") and isValidPart(self, part) then
                    addHighlightToPart(self, part)
                end
            end
        end
    end)
end




local function stopAll(self)
    if self.scanConnection then
        self.scanConnection:Disconnect()
        self.scanConnection = nil
    end
    if self.descendantConnection then
        self.descendantConnection:Disconnect()
        self.descendantConnection = nil
    end
    self.pendingTask = nil
end




function Highlighter:enable()
    if self.enabled then return end
    self.enabled = true
    
    task.defer(function()
        if not self.enabled then return end
        scanExistingAsync(self)
        startListeners(self)
    end)
end




function Highlighter:disable()
    if not self.enabled then return end
    self.enabled = false
    stopAll(self)
    removeAllHighlights(self)
end




function Highlighter:unload()
    self:disable()
    
    for i, inst in ipairs(instances) do
        if inst == self then
            table.remove(instances, i)
            break
        end
    end
    setmetatable(self, nil)
end




function MovableHighlighter.unloadAll()
    for i = #instances, 1, -1 do
        instances[i]:unload()
    end
end

return MovableHighlighter