
local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local TextChatService = cloneref(game:GetService("TextChatService"))

local isLegacyChat = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService

local SystemNotification = {}


local function escape(text)
    return text:gsub("[<>&]", {
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ["&"] = "&amp;"
    })
end


local function sendNew(message, font, size, colorRGB)
    local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    if not channel then return end
    local escaped = escape(message)
    local r, g, b = colorRGB.R * 255, colorRGB.G * 255, colorRGB.B * 255
    local rich = string.format(
        '<font color="rgb(%d,%d,%d)" face="%s" size="%d">%s</font>',
        r, g, b, font, size, escaped
    )
    channel:DisplaySystemMessage(rich)
end


local function sendOld(message, colorRGB)
    local player = Players.LocalPlayer
    if not player then return end
    local gui = player:WaitForChild("PlayerGui")
    pcall(function()
        gui:SetCore("ChatMakeSystemMessage", {
            Text = message,
            Color = colorRGB
        })
    end)
end


local function send(message, colorRGB, font, size)
    if isLegacyChat then
        sendOld(message, colorRGB)
    else
        sendNew(message, font, size, colorRGB)
    end
end


function SystemNotification.Success(message)
    send(message, Color3.fromRGB(0, 255, 0), "GothamBold", 18)
end

function SystemNotification.Warning(message)
    send(message, Color3.fromRGB(255, 200, 0), "SourceSansBold", 16)
end

function SystemNotification.Error(message)
    send(message, Color3.fromRGB(255, 0, 0), "GothamBold", 20)
end

function SystemNotification.Info(message)
    send(message, Color3.fromRGB(100, 150, 255), "SourceSans", 14)
end


local function hsvToColor3(h, s, v)
    local r, g, b
    local c = v * s
    local x = c * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - c

    if h < 60 then
        r, g, b = c, x, 0
    elseif h < 120 then
        r, g, b = x, c, 0
    elseif h < 180 then
        r, g, b = 0, c, x
    elseif h < 240 then
        r, g, b = 0, x, c
    elseif h < 300 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return Color3.new(r + m, g + m, b + m)
end


local function utf8chars(str)
    return coroutine.wrap(function()
        local i = 1
        while i <= #str do
            local byte = string.byte(str, i)
            local charLen = 1
            if byte > 0x7F then
                
                if byte >= 0xC0 then charLen = 2
                elseif byte >= 0xE0 then charLen = 3
                elseif byte >= 0xF0 then charLen = 4
                end
            end
            local char = string.sub(str, i, i + charLen - 1)
            coroutine.yield(char)
            i = i + charLen
        end
    end)
end


local function rainbowGradient(text, font, size)
    local chars = {}
    for ch in utf8chars(text) do
        table.insert(chars, ch)
    end
    local len = #chars
    if len == 0 then return "" end

    local parts = {}
    for i, ch in ipairs(chars) do
        local hue = (i - 1) / (len - 1) * 330  
        local color = hsvToColor3(hue, 0.6, 1) 
        local r = math.floor(color.R * 255)
        local g = math.floor(color.G * 255)
        local b = math.floor(color.B * 255)
        local escaped = ch:gsub("[<>&]", {
            ["<"] = "&lt;",
            [">"] = "&gt;",
            ["&"] = "&amp;"
        })
        parts[#parts + 1] = string.format('<font color="rgb(%d,%d,%d)" face="%s" size="%d">%s</font>',
            r, g, b, font, size, escaped)
    end
    return table.concat(parts)
end


local function redGradient(text, font, size)
    local chars = {}
    for ch in utf8chars(text) do
        table.insert(chars, ch)
    end
    local len = #chars
    if len == 0 then return "" end

    local parts = {}
    for i, ch in ipairs(chars) do
        local t = (i - 1) / (len - 1)
        local r = math.floor(255 - t * 75)   
        local g = math.floor(100 - t * 100)  
        local b = math.floor(100 - t * 100)  
        local escaped = ch:gsub("[<>&]", {
            ["<"] = "&lt;",
            [">"] = "&gt;",
            ["&"] = "&amp;"
        })
        parts[#parts + 1] = string.format('<font color="rgb(%d,%d,%d)" face="%s" size="%d">%s</font>',
            r, g, b, font, size, escaped)
    end
    return table.concat(parts)
end


function SystemNotification.Rainbow(message, font, size)
    font = font or "GothamBold"   
    size = size or 18              
    if isLegacyChat then
        
        SystemNotification.Send(message, Color3.fromRGB(200,200,200))
    else
        local rich = rainbowGradient(message, font, size)
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:DisplaySystemMessage(rich)
        end
    end
end


function SystemNotification.UnloadedGradient(message, font, size)
    font = font or "SourceSansBold"
    size = size or 16
    if isLegacyChat then
        SystemNotification.Send(message, Color3.fromRGB(255, 100, 100))
    else
        local rich = redGradient(message, font, size)
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then
            channel:DisplaySystemMessage(rich)
        end
    end
end


function SystemNotification.Custom(message, colorRGB, font, size)
    send(message, colorRGB, font, size)
end

return SystemNotification