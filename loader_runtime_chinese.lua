

local url = string.char(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,71,71,71,55,57,50,47,75,97,105,72,117,98,106,105,97,111,98,101,110,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,85,105,46,108,117,97) .. "?t=" .. tostring(tick())


loadstring(game:HttpGet(url))()


local textReplacements = {
    
    ["Launches:"] = "启动次数:",
    ["Session:"] = "使用时长:",

    
    ["Detected"] = "已检测",
    ["Undetected"] = "未检测",
    ["Free"] = "免费",
    ["Paid"] = "付费",
    ["Updated"] = "已更新",
    ["Outdated"] = "已过期",
    ["Website:"] = "官网:",
    ["Discord:"] = "Discord:",

    
    ["HWID"] = "设备标识",
    ["Memory"] = "内存",
    ["Network"] = "网络",
    ["Ping"] = "延迟",

    
    ["UnKnown"] = "未知",
    ["Unknown"] = "未知",
    ["Success"] = "成功",
    ["Error"] = "错误",
    ["Warning"] = "警告",
    ["Info"] = "信息",
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
