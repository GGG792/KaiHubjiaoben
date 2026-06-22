-- FPS 优化器 + UI
-- 提升帧率、降低延迟、优化渲染

if not game:IsLoaded() then game.Loaded:Wait() end

if _G.FPSBoosterLoaded then
    warn("[FPSBooster] 已经加载了！")
    return
end
_G.FPSBoosterLoaded = true

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local function notify(t, txt)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=t, Text=txt, Duration=3})
    end)
end

-- ========== FPS 优化功能 ==========
local fpsSettings = {
    fpsCap = 999,
    lowGraphics = false,
    noShadows = false,
    noParticles = false,
    noTextures = false,
    renderDistance = 500,
    antiLag = false,
}

local originalSettings = {}

-- 设置FPS上限
local function setFPSCap(cap)
    if setfpscap then
        setfpscap(cap)
        return true
    end
    return false
end

-- 低画质模式
local function enableLowGraphics(enable)
    if enable then
        originalSettings.Technology = Lighting.Technology
        Lighting.Technology = Enum.Technology.Compatibility
        
        originalSettings.GlobalShadows = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
        
        originalSettings.FogEnd = Lighting.FogEnd
        Lighting.FogEnd = 0
        
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("PostEffect") then
                originalSettings[v.Name] = v.Enabled
                v.Enabled = false
            end
        end
    else
        if originalSettings.Technology then
            Lighting.Technology = originalSettings.Technology
        end
        if originalSettings.GlobalShadows ~= nil then
            Lighting.GlobalShadows = originalSettings.GlobalShadows
        end
        if originalSettings.FogEnd then
            Lighting.FogEnd = originalSettings.FogEnd
        end
        for _, v in ipairs(Lighting:GetDescendants()) do
            if v:IsA("PostEffect") and originalSettings[v.Name] ~= nil then
                v.Enabled = originalSettings[v.Name]
            end
        end
    end
end

-- 移除阴影
local function removeShadows(enable)
    if enable then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                if originalSettings[v] == nil then
                    originalSettings[v] = v.CastShadow
                end
                v.CastShadow = false
            end
        end
    else
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and originalSettings[v] ~= nil then
                v.CastShadow = originalSettings[v]
            end
        end
    end
end

-- 移除粒子效果
local particleConnections = {}
local function removeParticles(enable)
    if enable then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                originalSettings[v] = v.Enabled
                v.Enabled = false
            end
        end
        
        -- 监听新创建的粒子
        table.insert(particleConnections, Workspace.DescendantAdded:Connect(function(desc)
            if desc:IsA("ParticleEmitter") or desc:IsA("Trail") or desc:IsA("Smoke") or desc:IsA("Fire") or desc:IsA("Sparkles") then
                originalSettings[desc] = desc.Enabled
                desc.Enabled = false
            end
        end))
    else
        for _, conn in ipairs(particleConnections) do
            conn:Disconnect()
        end
        particleConnections = {}
        
        for _, v in ipairs(Workspace:GetDescendants()) do
            if (v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles")) and originalSettings[v] ~= nil then
                v.Enabled = originalSettings[v]
            end
        end
    end
end

-- 简化纹理
local function simplifyTextures(enable)
    if enable then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Material ~= Enum.Material.SmoothPlastic and v.Material ~= Enum.Material.Neon then
                if originalSettings[v] == nil then
                    originalSettings[v] = v.Material
                end
                v.Material = Enum.Material.SmoothPlastic
            end
            if v:IsA("Decal") or v:IsA("Texture") then
                if originalSettings[v] == nil then
                    originalSettings[v] = v.Transparency
                end
                v.Transparency = 1
            end
        end
    else
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and originalSettings[v] ~= nil then
                v.Material = originalSettings[v]
            end
            if (v:IsA("Decal") or v:IsA("Texture")) and originalSettings[v] ~= nil then
                v.Transparency = originalSettings[v]
            end
        end
    end
end

-- 渲染距离优化
local renderConn = nil
local function setRenderDistance(dist)
    if renderConn then
        renderConn:Disconnect()
        renderConn = nil
    end
    
    renderConn = RunService.RenderStepped:Connect(function()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local playerPos = hrp.Position
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Parent ~= char then
                local distance = (v.Position - playerPos).Magnitude
                if distance > dist then
                    v.LocalTransparencyModifier = 1
                else
                    v.LocalTransparencyModifier = 0
                end
            end
        end
    end)
end

-- 反卡顿
local antiLagConn = nil
local function enableAntiLag(enable)
    if enable then
        antiLagConn = RunService.Heartbeat:Connect(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Anchored and v.CanCollide == false and v.Transparency == 1 then
                    v:Destroy()
                end
            end
        end)
    else
        if antiLagConn then
            antiLagConn:Disconnect()
            antiLagConn = nil
        end
    end
end

-- ========== UI 创建 ==========
local gui = Instance.new("ScreenGui")
gui.Name = "FPSBooster"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

-- 主框架
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 420)
mainFrame.Position = UDim2.new(0.5, -140, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local frameStroke = Instance.new("UIStroke", mainFrame)
frameStroke.Color = Color3.fromRGB(0, 180, 120)
frameStroke.Thickness = 2

-- 标题栏
local titleBar = Instance.new("TextButton")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BorderSizePixel = 0
titleBar.Text = "  FPS 优化器"
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 14
titleBar.TextColor3 = Color3.fromRGB(0, 220, 150)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.AutoButtonColor = false
titleBar.Active = true
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

-- 关闭按钮
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -28, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    if renderConn then renderConn:Disconnect() end
    if antiLagConn then antiLagConn:Disconnect() end
    for _, conn in ipairs(particleConnections) do
        conn:Disconnect()
    end
    _G.FPSBoosterLoaded = false
end)

-- FPS 显示
local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -16, 0, 24)
fpsLabel.Position = UDim2.new(0, 8, 0, 36)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Text = "FPS: 计算中..."
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextSize = 16
fpsLabel.TextColor3 = Color3.fromRGB(0, 220, 150)
fpsLabel.Parent = mainFrame

-- 实时FPS计算
local fps = 0
local lastTick = tick()
RunService.RenderStepped:Connect(function()
    fps = fps + 1
    if tick() - lastTick >= 1 then
        fpsLabel.Text = "FPS: " .. fps
        lastTick = tick()
        fps = 0
    end
end)

-- 内容区
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -68)
content.Position = UDim2.new(0, 8, 0, 62)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 4
content.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 120)
content.CanvasSize = UDim2.new(0, 0, 0, 400)
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 6)
layout.Parent = content

-- 创建开关函数
local function createToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.BorderSizePixel = 0
    frame.Parent = content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, -8, 1, 0)
    label.Position = UDim2.new(0, 8, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 44, 0, 22)
    toggle.Position = UDim2.new(1, -52, 0.5, -11)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(80, 80, 100)
    toggle.BorderSizePixel = 0
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = frame
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 11)
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 18, 0, 18)
    dot.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    dot.BorderSizePixel = 0
    dot.Parent = toggle
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local enabled = default
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 180, 120)}):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
        else
            TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 100)}):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
        callback(enabled)
    end)
    
    return frame
end

-- 创建滑块
local function createSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.BorderSizePixel = 0
    frame.Parent = content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 0, 20)
    label.Position = UDim2.new(0, 8, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. default
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(200, 200, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -16, 0, 8)
    sliderBg.Position = UDim2.new(0, 8, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 4)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4)
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = sliderBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    
    local dragging = false
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + pos * (max - min))
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -7, 0.5, -7)
        label.Text = text .. ": " .. value
        callback(value)
    end
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return frame
end

-- 创建按钮
local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(0, 140, 100)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.AutoButtonColor = false
    btn.Parent = content
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 180, 120)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 140, 100)}):Play()
    end)
    btn.MouseButton1Click:Connect(callback)
    
    return btn
end

-- 添加控件
createToggle("解锁FPS上限", false, function(val)
    if val then
        if setFPSCap(999) then
            notify("FPS优化器", "FPS上限已解锁为 999")
        else
            notify("FPS优化器", "当前执行器不支持修改FPS上限")
        end
    else
        setFPSCap(60)
        notify("FPS优化器", "FPS上限已恢复为 60")
    end
end)

createToggle("低画质模式", false, function(val)
    enableLowGraphics(val)
    notify("FPS优化器", val and "低画质模式已开启" or "低画质模式已关闭")
end)

createToggle("移除阴影", false, function(val)
    removeShadows(val)
    notify("FPS优化器", val and "阴影已移除" or "阴影已恢复")
end)

createToggle("移除粒子效果", false, function(val)
    removeParticles(val)
    notify("FPS优化器", val and "粒子效果已移除" or "粒子效果已恢复")
end)

createToggle("简化纹理", false, function(val)
    simplifyTextures(val)
    notify("FPS优化器", val and "纹理已简化" or "纹理已恢复")
end)

createSlider("渲染距离", 100, 2000, 500, function(val)
    fpsSettings.renderDistance = val
    setRenderDistance(val)
end)

createToggle("反卡顿清理", false, function(val)
    enableAntiLag(val)
    notify("FPS优化器", val and "反卡顿已开启" or "反卡顿已关闭")
end)

createButton("一键优化", function()
    -- 开启所有优化
    setFPSCap(999)
    enableLowGraphics(true)
    removeShadows(true)
    removeParticles(true)
    simplifyTextures(true)
    setRenderDistance(500)
    enableAntiLag(true)
    notify("FPS优化器", "一键优化已开启！所有优化项已激活")
end)

createButton("恢复默认", function()
    setFPSCap(60)
    enableLowGraphics(false)
    removeShadows(false)
    removeParticles(false)
    simplifyTextures(false)
    if renderConn then
        renderConn:Disconnect()
        renderConn = nil
    end
    enableAntiLag(false)
    notify("FPS优化器", "所有设置已恢复默认")
end)

-- 拖拽功能
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

notify("FPS优化器", "加载完成！当前FPS: " .. math.floor(1/RunService.RenderStepped:Wait()))
