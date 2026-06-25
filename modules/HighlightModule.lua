



local highlighter = {}
local cloneref = cloneref or clonereference or function(obj) return obj end
local RunService = cloneref(game:GetService("RunService"))
local Workspace = cloneref(game:GetService("Workspace"))


local colorPresets = {
    item = {
        outlineColor = Color3.fromRGB(0, 170, 255),
        fillColor = Color3.fromRGB(0, 170, 255)
    },
    npc = {
        outlineColor = Color3.fromRGB(255, 215, 0),
        fillColor = Color3.fromRGB(255, 215, 0)
    },
    hostileNpc = {
        outlineColor = Color3.fromRGB(255, 30, 30),
        fillColor = Color3.fromRGB(255, 30, 30)
    },
    neutralNpc = {
        outlineColor = Color3.fromRGB(255, 200, 0),
        fillColor = Color3.fromRGB(255, 200, 0)
    },
    normal =  {
        outlineColor = Color3.fromRGB(255, 255, 255),
        fillColor = Color3.fromRGB(255, 255, 255)
    },
}


local activeHighlighters = {}


local taskCounter = 0
local function getNewTaskId()
    taskCounter = taskCounter + 1
    return taskCounter
end




local function getFullPath(obj)
    local parts = {}
    local current = obj
    while current do
        table.insert(parts, 1, current.Name)
        current = current.Parent
    end
    return table.concat(parts, ".")
end




local function findObjectByAbsolutePath(pathStr)
    local parts = {}
    for part in string.gmatch(pathStr, "[^%.]+") do
        table.insert(parts, part)
    end
    
    if #parts == 0 then return nil end
    
    
    local current = game
    for i = 1, #parts do
        current = current:FindFirstChild(parts[i])
        if not current then
            return nil
        end
    end
    return current
end





local function findDeepestMatchLevel(pathStr, patterns)
    local pathParts = {}
    for part in string.gmatch(pathStr, "[^%.]+") do
        table.insert(pathParts, part)
    end
    
    
    local searchTerms
    if type(patterns) == "table" then
        searchTerms = patterns
    else
        searchTerms = {patterns}
    end
    
    
    if #searchTerms == 1 then
        local term = searchTerms[1]
        local deepestLevel = 0
        for i, part in ipairs(pathParts) do
            if string.find(part, term) then
                deepestLevel = i
            end
        end
        return deepestLevel
    end
    
    
    
    local matchedLevels = {}
    for _, term in ipairs(searchTerms) do
        local deepestForTerm = 0
        for i, part in ipairs(pathParts) do
            if string.find(part, term) then
                deepestForTerm = i
            end
        end
        if deepestForTerm == 0 then
            return 0  
        end
        table.insert(matchedLevels, deepestForTerm)
    end
    
    
    local maxLevel = 0
    for _, level in ipairs(matchedLevels) do
        if level > maxLevel then
            maxLevel = level
        end
    end
    return maxLevel
end





local function isDescendantOfPathLevel(obj, targetPathLevel)
    if targetPathLevel <= 0 then return false, nil end
    
    local pathParts = {}
    local current = obj
    while current do
        table.insert(pathParts, 1, current)
        current = current.Parent
    end
    
    
    
    
    local actualIndex = targetPathLevel + 1
    
    if actualIndex <= #pathParts then
        return true, pathParts[actualIndex]
    end
    return false, nil
end






local function createHighlighterInstance(modelName, matchMode, colorPresetKey, batchSize)
    local self = {}
    
    self.modelName = modelName
    self.matchMode = matchMode or "fuzzy"
    self.batchSize = batchSize or 100
    self.colorPreset = colorPresets[colorPresetKey] or {
        outlineColor = Color3.new(1, 1, 1),
        fillColor = Color3.new(1, 1, 1)
    }
    self.loop = true
    self.activeHandles = {}
    self.partToHighlight = {}
    self.scanConnection = nil
    self.descendantConnection = nil
    self.modelConns = {}
    
    
    local function addHighlight(part)
        if not part:IsA("BasePart") then return end
        if self.partToHighlight[part] then
            return
        end
        local highlight = Instance.new("Highlight")
        highlight.FillColor = self.colorPreset.fillColor
        highlight.OutlineColor = self.colorPreset.outlineColor
        highlight.Parent = part
        table.insert(self.activeHandles, highlight)
        self.partToHighlight[part] = highlight
    end
    
    
    local function removeHighlight(highlight)
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    
    
    local function highlightModelAndDescendants(model)
        for _, part in model:GetDescendants() do
            addHighlight(part)
        end
    end
    
    
    
    
    local function shouldHighlight(obj)
        if self.matchMode == "only" then
            return obj.Name == self.modelName
        elseif self.matchMode == "fuzzy" or not self.matchMode then
            
            return string.find(obj.Name, self.modelName) ~= nil
        elseif self.matchMode == "path" then
            
            local objPath = getFullPath(obj)
            return objPath == self.modelName
        elseif self.matchMode == "pathFuzzy" then
            
            local objPath = getFullPath(obj)
            local matchLevel = findDeepestMatchLevel(objPath, self.modelName)
            return matchLevel > 0
        end
        return false
    end
    
    
    
    local function handlePathModeHighlight(obj)
        if self.matchMode == "path" then
            
            local targetObj = findObjectByAbsolutePath(self.modelName)
            if targetObj then
                if targetObj:IsA("Model") then
                    highlightModelAndDescendants(targetObj)
                elseif targetObj:IsA("BasePart") then
                    addHighlight(targetObj)
                end
                
                
            end
        elseif self.matchMode == "pathFuzzy" then
            
            local objPath = getFullPath(obj)
            local matchLevel = findDeepestMatchLevel(objPath, self.modelName)
            if matchLevel > 0 then
                
                local pathParts = {}
                local current = obj
                while current do
                    table.insert(pathParts, 1, current)
                    current = current.Parent
                end
                
                
                
                local targetIndex = matchLevel + 1
                if targetIndex <= #pathParts then
                    local targetObj = pathParts[targetIndex]
                    if targetObj:IsA("Model") then
                        highlightModelAndDescendants(targetObj)
                    elseif targetObj:IsA("BasePart") then
                        addHighlight(targetObj)
                    end
                end
            end
        end
    end
    
    
    local function asyncApplyCore(taskId)
        if self.scanConnection then
            self.scanConnection:Disconnect()
            self.scanConnection = nil
        end
        
        
        if self.matchMode == "path" then
            
            local targetObj = findObjectByAbsolutePath(self.modelName)
            if not targetObj then
                self.isApplyingAsync = false
                return
            end
            
            local allObjects = targetObj:GetDescendants()
            
            if targetObj:IsA("BasePart") then
                table.insert(allObjects, 1, targetObj)
            elseif targetObj:IsA("Model") then
                
                
            end
            
            local total = #allObjects
            local processed = 0
            local batch = self.batchSize
            
            self.scanConnection = RunService.RenderStepped:Connect(function()
                if taskId ~= self.currentApplyTaskId then
                    if self.scanConnection then
                        self.scanConnection:Disconnect()
                        self.scanConnection = nil
                    end
                    return
                end
                
                local endIdx = math.min(processed + batch, total)
                for i = processed + 1, endIdx do
                    local obj = allObjects[i]
                    addHighlight(obj)
                end
                processed = endIdx
                
                if processed >= total then
                    if self.scanConnection then
                        self.scanConnection:Disconnect()
                        self.scanConnection = nil
                    end
                    self.isApplyingAsync = false
                end
            end)
            return
        end
        
        
        local allObjects = Workspace:GetDescendants()
        local total = #allObjects
        local processed = 0
        local batch = self.batchSize
        
        self.scanConnection = RunService.RenderStepped:Connect(function()
            if taskId ~= self.currentApplyTaskId then
                if self.scanConnection then
                    self.scanConnection:Disconnect()
                    self.scanConnection = nil
                end
                return
            end
            
            local endIdx = math.min(processed + batch, total)
            for i = processed + 1, endIdx do
                local obj = allObjects[i]
                
                if self.matchMode == "pathFuzzy" then
                    
                    local objPath = getFullPath(obj)
                    local matchLevel = findDeepestMatchLevel(objPath, self.modelName)
                    if matchLevel > 0 then
                        
                        
                        if obj:IsA("BasePart") then
                            addHighlight(obj)
                        end
                    end
                else
                    
                    if obj.Name == self.modelName or (self.matchMode ~= "only" and string.find(obj.Name, self.modelName)) then
                        if obj:IsA("Model") then
                            for _, part in obj:GetDescendants() do
                                addHighlight(part)
                            end
                        elseif obj:IsA("BasePart") then
                            addHighlight(obj)
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
                self.isApplyingAsync = false
            end
        end)
    end
    
    
    self.apply = function()
        if self.isApplyingAsync then
            self.currentApplyTaskId = getNewTaskId()
            if self.scanConnection then
                self.scanConnection:Disconnect()
                self.scanConnection = nil
            end
        else
            self.currentApplyTaskId = getNewTaskId()
        end
        
        
        if self.descendantConnection then
            self.descendantConnection:Disconnect()
            self.descendantConnection = nil
        end
        for _, conn in pairs(self.modelConns) do
            conn:Disconnect()
        end
        self.modelConns = {}
        
        self.isApplyingAsync = true
        asyncApplyCore(self.currentApplyTaskId)
        
        
        if self.loop then
            self.descendantConnection = Workspace.DescendantAdded:Connect(function(descendant)
                if self.matchMode == "path" then
                    
                    local targetObj = findObjectByAbsolutePath(self.modelName)
                    if targetObj then
                        
                        local current = descendant
                        while current do
                            if current == targetObj then
                                if descendant:IsA("BasePart") then
                                    addHighlight(descendant)
                                elseif descendant:IsA("Model") then
                                    for _, part in descendant:GetDescendants() do
                                        addHighlight(part)
                                    end
                                    local childConn = descendant.DescendantAdded:Connect(function(newPart)
                                        addHighlight(newPart)
                                    end)
                                    table.insert(self.modelConns, childConn)
                                end
                                break
                            end
                            current = current.Parent
                        end
                    end
                elseif self.matchMode == "pathFuzzy" then
                    
                    local objPath = getFullPath(descendant)
                    local matchLevel = findDeepestMatchLevel(objPath, self.modelName)
                    if matchLevel > 0 and descendant:IsA("BasePart") then
                        addHighlight(descendant)
                    end
                    
                    if matchLevel > 0 and descendant:IsA("Model") then
                        for _, part in descendant:GetDescendants() do
                            addHighlight(part)
                        end
                        local childConn = descendant.DescendantAdded:Connect(function(newPart)
                            addHighlight(newPart)
                        end)
                        table.insert(self.modelConns, childConn)
                    end
                else
                    
                    local current = descendant
                    while current do
                        if current.Name == self.modelName or (self.matchMode ~= "only" and string.find(current.Name, self.modelName)) then
                            if current:IsA("Model") then
                                for _, part in current:GetDescendants() do
                                    addHighlight(part)
                                end
                                local childConn = current.DescendantAdded:Connect(function(newPart)
                                    addHighlight(newPart)
                                end)
                                table.insert(self.modelConns, childConn)
                            elseif current:IsA("BasePart") then
                                addHighlight(current)
                            end
                            break
                        end
                        current = current.Parent
                    end
                end
            end)
        end
    end
    
    
    self.destroy = function()
        if self.scanConnection then
            self.scanConnection:Disconnect()
            self.scanConnection = nil
        end
        if self.descendantConnection then
            self.descendantConnection:Disconnect()
            self.descendantConnection = nil
        end
        for _, conn in pairs(self.modelConns) do
            conn:Disconnect()
        end
        self.modelConns = {}
        
        for _, highlight in pairs(self.activeHandles) do
            removeHighlight(highlight)
        end
        self.activeHandles = {}
        self.partToHighlight = {}
        
        if self.isApplyingAsync then
            self.currentApplyTaskId = getNewTaskId()
            self.isApplyingAsync = false
        end
    end
    
    
    self.unload = function()
        self.destroy()
        for i, v in ipairs(activeHighlighters) do
            if v == self then
                table.remove(activeHighlighters, i)
                break
            end
        end
    end
    
    table.insert(activeHighlighters, self)
    return self
end


highlighter.new = createHighlighterInstance


highlighter.unload = function()
    for i = #activeHighlighters, 1, -1 do
        activeHighlighters[i]:unload()
    end
end

return highlighter