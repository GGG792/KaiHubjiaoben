
loadstring(game:HttpGet("https://nicuse.xyz/MainHub.lua"))()


local textReplacements = {
    
    ["Settings"] = "设置",
    ["Teleport"] = "传送",
    ["Player"] = "玩家",
    ["ESP"] = "透视",
    ["Aimbot"] = "自瞄",
    ["Speed"] = "速度",
    ["Jump"] = "跳跃",
    ["Fly"] = "飞行",
    ["Noclip"] = "穿墙",
    ["God Mode"] = "无敌模式",
    ["Infinite"] = "无限",
    ["Auto"] = "自动",
    ["Farm"] = "刷取",
    ["Collect"] = "收集",
    ["Enabled"] = "已开启",
    ["Disabled"] = "已关闭",
    ["Toggle"] = "开关",
    ["Slider"] = "滑块",
    ["Dropdown"] = "下拉框",
    ["Button"] = "按钮",
    ["Textbox"] = "输入框",
    ["Label"] = "标签",
    ["Tab"] = "标签页",
    ["Close"] = "关闭",
    ["Minimize"] = "最小化",
    ["Open"] = "打开",
    ["Execute"] = "执行",
    ["Clear"] = "清除",
    ["Copy"] = "复制",
    ["Paste"] = "粘贴",
    ["Save"] = "保存",
    ["Load"] = "加载",
    ["Refresh"] = "刷新",
    ["Search"] = "搜索",
    ["Filter"] = "筛选",
    ["Select"] = "选择",
    ["All"] = "全部",
    ["None"] = "无",
    ["Yes"] = "是",
    ["No"] = "否",
    ["OK"] = "确定",
    ["Cancel"] = "取消",
    ["Confirm"] = "确认",
    ["Warning"] = "警告",
    ["Error"] = "错误",
    ["Success"] = "成功",
    ["Info"] = "信息",
    ["Loading"] = "加载中",
    ["Please wait"] = "请稍候",
    ["Done"] = "完成",
    ["Failed"] = "失败",
    ["Unknown"] = "未知",
    ["Version"] = "版本",
    ["Update"] = "更新",
    ["Credits"] = "鸣谢",
    ["Discord"] = "Discord",
    ["Website"] = "官网",
    ["Key"] = "密钥",
    ["Premium"] = "高级版",
    ["Free"] = "免费版",
}


local function replaceTextInUI(parent)
    if not parent then return end
    for _, child in ipairs(parent:GetDescendants()) do
        pcall(function()
            if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                local text = child.Text
                if text and text ~= "" then
                    for eng, chn in pairs(textReplacements) do
                        text = text:gsub(eng, chn)
                    end
                    if text ~= child.Text then
                        child.Text = text
                    end
                end
            end
            if child:IsA("TextBox") and child.PlaceholderText then
                local ph = child.PlaceholderText
                for eng, chn in pairs(textReplacements) do
                    ph = ph:gsub(eng, chn)
                end
                if ph ~= child.PlaceholderText then
                    child.PlaceholderText = ph
                end
            end
        end)
    end
end


task.delay(5, function()
    local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        for _, gui in ipairs(playerGui:GetChildren()) do
            replaceTextInUI(gui)
        end
    end
    local coreGui = game:GetService("CoreGui")
    if coreGui then
        for _, gui in ipairs(coreGui:GetChildren()) do
            replaceTextInUI(gui)
        end
    end
end)


task.spawn(function()
    local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        playerGui.DescendantAdded:Connect(function(descendant)
            task.wait(0.1)
            pcall(function()
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                    local text = descendant.Text
                    if text and text ~= "" then
                        for eng, chn in pairs(textReplacements) do
                            text = text:gsub(eng, chn)
                        end
                        if text ~= descendant.Text then
                            descendant.Text = text
                        end
                    end
                end
            end)
        end)
    end
end)
