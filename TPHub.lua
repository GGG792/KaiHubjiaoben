-- TP Hub - 位置传送器
-- 保存/传送/平移 + 穿墙 + 速度调节

if not game:IsLoaded() then game.Loaded:Wait() end

if _G.TPHubLoaded then return end
_G.TPHubLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer

local function notify(t, txt)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title=t, Text=txt, Duration=2})
    end)
end

-- ========== 状态 ==========
local savedPositions = {}
local glideSpeed = 100
local isGliding = false
local glideConn = nil

-- ========== 平移传送 ==========
local function glideToPosition(targetPos)
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    -- 停止之前的平移
    if glideConn then
        glideConn:Disconnect()
        glideConn = nil
    end

    isGliding = true

    -- 开启穿墙
    local originalCollisions = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            originalCollisions[part] = part.CanCollide
            part.CanCollide = false
        end
    end

    -- 平移到目标位置
    local startPos = root.Position
    local distance = (targetPos - startPos).Magnitude
    local duration = distance / glideSpeed

    local startTime = tick()
    glideConn = RunService.Heartbeat:Connect(function()
        if not isGliding or not root or not root.Parent then
            if glideConn then glideConn:Disconnect() glideConn = nil end
            return
        end

        local elapsed = tick() - startTime
        local alpha = math.clamp(elapsed / duration, 0, 1)

        -- 平滑插值
        local currentPos = startPos:Lerp(targetPos, alpha)
        root.CFrame = CFrame.new(currentPos, currentPos + root.CFrame.LookVector)

        if alpha >= 1 then
            -- 恢复碰撞
            for part, original in pairs(originalCollisions) do
                if part and part.Parent then
                    part.CanCollide = original
                end
            end
            isGliding = false
            if glideConn then
                glideConn:Disconnect()
                glideConn = nil
            end
            notify("TP Hub", "已到达目标位置")
        end
    end)
end

-- ========== 瞬移传送 ==========
local function teleportToPosition(pos)
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    root.CFrame = CFrame.new(pos)
    notify("TP Hub", "已传送")
end

-- ========== 停止平移 ==========
local function stopGlide()
    if glideConn then
        glideConn:Disconnect()
        glideConn = nil
    end
    isGliding = false

    -- 恢复碰撞
    local char = LP.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    notify("TP Hub", "平移已停止")
end

-- ========== UI ==========
local gui = Instance.new("ScreenGui")
gui.Name = "TPHub"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

-- 主窗口
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 230, 0, 320)
mainFrame.Position = UDim2.new(0.5, -115, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = gui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(100, 150, 255)
stroke.Thickness = 2

-- 标题栏
local titleBar = Instance.new("TextButton")
titleBar.Size = UDim2.new(1, 0, 0, 26)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
titleBar.BorderSizePixel = 0
titleBar.Text = "  TP Hub"
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 12
titleBar.TextColor3 = Color3.fromRGB(100, 150, 255)
titleBar.TextXAlignment = Enum.TextXAlignment.Left
titleBar.AutoButtonColor = false
titleBar.Active = true
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 6)

-- 最小化按钮 (扳手图标)
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 20)
minBtn.Position = UDim2.new(1, -50, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
minBtn.BorderSizePixel = 0
minBtn.Text = "🔧"
minBtn.Font = Enum.Font.Gotham
minBtn.TextSize = 11
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.AutoButtonColor = false
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

-- 关闭按钮
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 20)
closeBtn.Position = UDim2.new(1, -25, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

closeBtn.MouseButton1Click:Connect(function()
    if glideConn then stopGlide() end
    gui:Destroy()
    _G.TPHubLoaded = false
end)

-- ========== 最小化成扳手图标 ==========
local wrenchBtn = Instance.new("TextButton")
wrenchBtn.Size = UDim2.new(0, 44, 0, 44)
wrenchBtn.Position = UDim2.new(0, 10, 0, 10)
wrenchBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
wrenchBtn.BorderSizePixel = 0
wrenchBtn.Text = "🔧"
wrenchBtn.Font = Enum.Font.Gotham
wrenchBtn.TextSize = 22
wrenchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
wrenchBtn.AutoButtonColor = false
wrenchBtn.Active = true
wrenchBtn.Visible = false
wrenchBtn.Parent = gui
Instance.new("UICorner", wrenchBtn).CornerRadius = UDim.new(0, 10)
local wrenchStroke = Instance.new("UIStroke", wrenchBtn)
wrenchStroke.Color = Color3.fromRGB(100, 150, 255)
wrenchStroke.Thickness = 2

-- 扳手按钮拖拽
local wrenchDragging = false
local wrenchDragStart, wrenchStartPos
wrenchBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        wrenchDragging = true
        wrenchDragStart = input.Position
        wrenchStartPos = wrenchBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if wrenchDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - wrenchDragStart
        wrenchBtn.Position = UDim2.new(
            wrenchStartPos.X.Scale, wrenchStartPos.X.Offset + delta.X,
            wrenchStartPos.Y.Scale, wrenchStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        wrenchDragging = false
    end
end)

-- 点击扳手恢复
wrenchBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    wrenchBtn.Visible = false
end)

-- 点击最小化
minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    wrenchBtn.Visible = true
    -- 扳手位置跟主窗口位置
    wrenchBtn.Position = UDim2.new(
        mainFrame.Position.X.Scale, mainFrame.Position.X.Offset + 10,
        mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 10
    )
end)

-- 速度显示
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -16, 0, 14)
speedLabel.Position = UDim2.new(0, 8, 0, 30)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "平移速度: " .. glideSpeed
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 11
speedLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainFrame

-- 速度滑块
local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -16, 0, 6)
sliderBg.Position = UDim2.new(0, 8, 0, 46)
sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = mainFrame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 4)

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new((glideSpeed - 10) / 490, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0, 4)

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 14, 0, 14)
sliderKnob.Position = UDim2.new((glideSpeed - 10) / 490, -7, 0.5, -7)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBg
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1, 0)

local sliderDragging = false
local function updateSlider(input)
    local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
    glideSpeed = math.floor(10 + pos * 490)
    sliderFill.Size = UDim2.new(pos, 0, 1, 0)
    sliderKnob.Position = UDim2.new(pos, -7, 0.5, -7)
    speedLabel.Text = "平移速度: " .. glideSpeed
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = true
        updateSlider(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        sliderDragging = false
    end
end)

-- 按钮容器
local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -16, 0, 30)
btnContainer.Position = UDim2.new(0, 8, 0, 58)
btnContainer.BackgroundTransparency = 1
btnContainer.Parent = mainFrame

-- 保存当前按钮
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.32, 0, 1, 0)
saveBtn.Position = UDim2.new(0, 0, 0, 0)
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 100)
saveBtn.BorderSizePixel = 0
saveBtn.Text = "保存当前"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 12
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.AutoButtonColor = false
saveBtn.Parent = btnContainer
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)

-- 停止平移按钮
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.32, 0, 1, 0)
stopBtn.Position = UDim2.new(0.34, 0, 0, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
stopBtn.BorderSizePixel = 0
stopBtn.Text = "停止平移"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 12
stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.AutoButtonColor = false
stopBtn.Parent = btnContainer
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)

-- 清除全部按钮
local clearBtn = Instance.new("TextButton")
clearBtn.Size = UDim2.new(0.32, 0, 1, 0)
clearBtn.Position = UDim2.new(0.68, 0, 0, 0)
clearBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
clearBtn.BorderSizePixel = 0
clearBtn.Text = "清除全部"
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextSize = 12
clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clearBtn.AutoButtonColor = false
clearBtn.Parent = btnContainer
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)

-- 列表标题
local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, -16, 0, 14)
listTitle.Position = UDim2.new(0, 8, 0, 94)
listTitle.BackgroundTransparency = 1
listTitle.Text = "已保存的位置:"
listTitle.Font = Enum.Font.Gotham
listTitle.TextSize = 9
listTitle.TextColor3 = Color3.fromRGB(150, 150, 170)
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.Parent = mainFrame

-- 位置列表 (ScrollingFrame)
local posList = Instance.new("ScrollingFrame")
posList.Size = UDim2.new(1, -16, 1, -114)
posList.Position = UDim2.new(0, 8, 0, 110)
posList.BackgroundTransparency = 1
posList.BorderSizePixel = 0
posList.ScrollBarThickness = 4
posList.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
posList.CanvasSize = UDim2.new(0, 0, 0, 0)
posList.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = posList

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    posList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 4)
end)

-- ========== 位置项 UI ==========
local function refreshList()
    -- 清空列表
    for _, child in ipairs(posList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- 重新生成
    for i, posData in ipairs(savedPositions) do
        local item = Instance.new("Frame")
        item.Size = UDim2.new(1, 0, 0, 48)
        item.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        item.BorderSizePixel = 0
        item.LayoutOrder = i
        item.Parent = posList
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 5)

        -- 位置名称
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, -8, 0, 14)
        nameLabel.Position = UDim2.new(0, 6, 0, 3)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "位置" .. i .. " (" .. math.floor(posData.pos.X) .. "," .. math.floor(posData.pos.Y) .. "," .. math.floor(posData.pos.Z) .. ")"
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 10
        nameLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = item

        -- 瞬移按钮
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0.3, -4, 0, 24)
        tpBtn.Position = UDim2.new(0, 6, 0, 20)
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
        tpBtn.BorderSizePixel = 0
        tpBtn.Text = "瞬移"
        tpBtn.Font = Enum.Font.GothamBold
        tpBtn.TextSize = 11
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.AutoButtonColor = false
        tpBtn.Parent = item
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)

        tpBtn.MouseButton1Click:Connect(function()
            stopGlide()
            teleportToPosition(posData.pos)
        end)

        -- 平移按钮
        local glideBtn = Instance.new("TextButton")
        glideBtn.Size = UDim2.new(0.3, -4, 0, 24)
        glideBtn.Position = UDim2.new(0.33, 2, 0, 20)
        glideBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        glideBtn.BorderSizePixel = 0
        glideBtn.Text = "平移"
        glideBtn.Font = Enum.Font.GothamBold
        glideBtn.TextSize = 11
        glideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        glideBtn.AutoButtonColor = false
        glideBtn.Parent = item
        Instance.new("UICorner", glideBtn).CornerRadius = UDim.new(0, 4)

        glideBtn.MouseButton1Click:Connect(function()
            stopGlide()
            glideToPosition(posData.pos)
            notify("TP Hub", "平移中... 速度: " .. glideSpeed .. " (穿墙已开启)")
        end)

        -- 删除按钮
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.3, -4, 0, 24)
        delBtn.Position = UDim2.new(0.66, 2, 0, 20)
        delBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        delBtn.BorderSizePixel = 0
        delBtn.Text = "删除"
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 11
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.AutoButtonColor = false
        delBtn.Parent = item
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 4)

        delBtn.MouseButton1Click:Connect(function()
            table.remove(savedPositions, i)
            refreshList()
            notify("TP Hub", "位置 " .. i .. " 已删除")
        end)

        -- 悬停效果
        for _, btn in ipairs({tpBtn, glideBtn, delBtn}) do
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = btn.BackgroundColor3:LERP(Color3.new(1,1,1), 0.2)}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = btn.BackgroundColor3:LERP(Color3.new(0,0,0), 0)}):Play()
            end)
        end
    end
end

-- ========== 按钮事件 ==========
saveBtn.MouseButton1Click:Connect(function()
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    table.insert(savedPositions, {pos = root.Position})
    refreshList()
    notify("TP Hub", "位置 " .. #savedPositions .. " 已保存")
end)

stopBtn.MouseButton1Click:Connect(function()
    stopGlide()
end)

clearBtn.MouseButton1Click:Connect(function()
    savedPositions = {}
    refreshList()
    notify("TP Hub", "所有位置已清除")
end)

-- ========== 拖拽 ==========
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

-- ========== 快捷键 ==========
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.T then
        saveBtn.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.G then
        stopGlide()
    end
end)

notify("TP Hub", "加载完成！T键保存位置 | G键停止平移")
