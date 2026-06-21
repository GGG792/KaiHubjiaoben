-- 恐脚本 - 恐怖风格启动器
-- 作者: KaiHub

if not game:IsLoaded() then game.Loaded:Wait() end

-- 防止重复加载
if _G.KongJuBenLoaded then return end
_G.KongJuBenLoaded = true

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- ========== 创建恐脚本启动界面 ==========
local gui = Instance.new("ScreenGui")
gui.Name = "KongJuBen"
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999
gui.Parent = LP:WaitForChild("PlayerGui")

-- 红色背景
local bg = Instance.new("Frame")
bg.Name = "Background"
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.fromRGB(139, 0, 0) -- 深红色
bg.BorderSizePixel = 0
bg.Parent = gui

-- 渐变效果
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(139, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 0, 0))
})
gradient.Rotation = 45
gradient.Parent = bg

-- 恐脚本大字
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(0, 600, 0, 150)
title.Position = UDim2.new(0.5, -300, 0.3, -75)
title.BackgroundTransparency = 1
title.Text = "恐脚本"
title.Font = Enum.Font.GothamBlack
title.TextSize = 120
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.TextStrokeTransparency = 0.3
title.TextStrokeColor3 = Color3.fromRGB(50, 0, 0)
title.Parent = bg

-- 副标题
local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(0, 400, 0, 40)
subtitle.Position = UDim2.new(0.5, -200, 0.45, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "恐怖的脚本，极致的体验"
subtitle.Font = Enum.Font.GothamBold
subtitle.TextSize = 24
subtitle.TextColor3 = Color3.fromRGB(200, 50, 50)
subtitle.TextTransparency = 0.3
subtitle.Parent = bg

-- 启动按钮
local startBtn = Instance.new("TextButton")
startBtn.Name = "StartButton"
startBtn.Size = UDim2.new(0, 250, 0, 60)
startBtn.Position = UDim2.new(0.5, -125, 0.6, 0)
startBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
startBtn.BorderSizePixel = 0
title.Text = "恐脚本"
startBtn.Text = "点击启动恐脚本"
startBtn.Font = Enum.Font.GothamBold
startBtn.TextSize = 22
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.AutoButtonColor = false
startBtn.Parent = bg

-- 按钮圆角
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = startBtn

-- 按钮发光效果
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 50, 50)
btnStroke.Thickness = 2
btnStroke.Parent = startBtn

-- 按钮悬停效果
startBtn.MouseEnter:Connect(function()
    TweenService:Create(startBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 20, 20)}):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 100, 100)}):Play()
end)

startBtn.MouseLeave:Connect(function()
    TweenService:Create(startBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 0, 0)}):Play()
    TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 50, 50)}):Play()
end)

-- ========== 恐脚本飘落效果 ==========
local fallingTexts = {}
local maxFalling = 15

local function createFallingText()
    if #fallingTexts >= maxFalling then return end

    local text = Instance.new("TextLabel")
    text.Name = "FallingKong"
    text.Size = UDim2.new(0, math.random(80, 150), 0, math.random(30, 50))
    text.Position = UDim2.new(math.random() * 0.9, 0, -0.1, 0)
    text.BackgroundTransparency = 1
    text.Text = "恐脚本"
    text.Font = Enum.Font.GothamBold
    text.TextSize = math.random(20, 36)
    text.TextColor3 = Color3.fromRGB(math.random(150, 255), 0, 0)
    text.TextTransparency = math.random(0.3, 0.7)
    text.TextStrokeTransparency = 0.8
    text.TextStrokeColor3 = Color3.fromRGB(50, 0, 0)
    text.Rotation = math.random(-30, 30)
    text.Parent = bg
    table.insert(fallingTexts, text)

    local fallSpeed = math.random(40, 80)
    local swaySpeed = math.random(0.5, 2)
    local startX = text.Position.X.Scale
    local startTime = tick()

    task.spawn(function()
        while text and text.Parent do
            local elapsed = tick() - startTime
            local yProgress = elapsed * fallSpeed
            local sway = math.sin(elapsed * swaySpeed) * 0.05

            text.Position = UDim2.new(
                math.clamp(startX + sway, 0, 0.85), 0,
                -0.1 + (yProgress / 1000), 0
            )

            if yProgress > 1200 then
                text:Destroy()
                for i, t in ipairs(fallingTexts) do
                    if t == text then
                        table.remove(fallingTexts, i)
                        break
                    end
                end
                return
            end

            task.wait(0.03)
        end
    end)
end

-- 循环生成飘落文字
task.spawn(function()
    while bg and bg.Parent do
        createFallingText()
        task.wait(math.random(0.5, 1.5))
    end
end)

-- ========== 启动按钮点击 ==========
startBtn.MouseButton1Click:Connect(function()
    -- 按钮点击动画
    TweenService:Create(startBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 240, 0, 55)}):Play()
    task.wait(0.1)
    TweenService:Create(startBtn, TweenInfo.new(0.1), {Size = UDim2.new(0, 250, 0, 60)}):Play()

    -- 淡出启动界面
    TweenService:Create(bg, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
    for _, child in ipairs(bg:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            TweenService:Create(child, TweenInfo.new(0.8), {TextTransparency = 1}):Play()
        end
        if child:IsA("UIStroke") then
            TweenService:Create(child, TweenInfo.new(0.8), {Transparency = 1}):Play()
        end
    end

    task.wait(1)

    -- 删除启动界面
    bg:Destroy()

    -- 创建悬浮窗
    createFloatingWindow()
end)

-- ========== 悬浮窗功能 ==========
function createFloatingWindow()
    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "KongJuBenFloat"
    floatGui.ResetOnSpawn = false
    floatGui.DisplayOrder = 10000
    floatGui.Parent = LP:WaitForChild("PlayerGui")

    -- 主窗口
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = floatGui

    -- 圆角
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    -- 边框
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(180, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    -- 标题文字
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -80, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "恐脚本"
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 20
    titleText.TextColor3 = Color3.fromRGB(255, 50, 50)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- 关闭按钮
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = titleBar

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        floatGui:Destroy()
        _G.KongJuBenLoaded = false
    end)

    -- 内容区
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 4
    content.ScrollBarImageColor3 = Color3.fromRGB(150, 0, 0)
    content.CanvasSize = UDim2.new(0, 0, 0, 300)
    content.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = content

    -- 功能按钮
    local function addButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        btn.AutoButtonColor = false
        btn.LayoutOrder = #content:GetChildren()
        btn.Parent = content

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100, 0, 0)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 0, 0)}):Play()
        end)
        btn.MouseButton1Click:Connect(callback)

        return btn
    end

    -- 添加功能按钮
    addButton("加载 KaiHub", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GGG792/KaiHubjiaoben/refs/heads/main/Ui.lua"))()
    end)

    addButton("加载 最强战场", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GGG792/KaiHubjiaoben/refs/heads/main/scripts/最强战场.lua"))()
    end)

    addButton("加载 ItemMagnet", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GGG792/KaiHubRetroTest/refs/heads/main/ItemMagnet.lua"))()
    end)

    addButton("加载 PlayerIntel", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GGG792/KaiHubRetroTest/refs/heads/main/PlayerIntelScanner.lua"))()
    end)

    addButton("加载 复古UI", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GGG792/KaiHubRetroTest/refs/heads/main/main.lua"))()
    end)

    addButton("关闭悬浮窗", function()
        floatGui:Destroy()
        _G.KongJuBenLoaded = false
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

    -- 阻止桌面滑动（通过拦截输入）
    local blockConn = UserInputService.TouchPan:Connect(function()
        return nil
    end)

    -- 悬浮窗关闭时解除拦截
    floatGui.Destroying:Connect(function()
        if blockConn then blockConn:Disconnect() end
    end)
end
