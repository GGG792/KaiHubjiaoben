
local ChatSpy = {}


local enabled = false
local connections = {}      
local spyOnSelf = false     
local publicMode = false    
local ignoreList = {        
    {Message = ":part/1/1/1", ExactMatch = true},
    {Message = ":part/10/10/10", ExactMatch = true},
    {Message = "A?????????", ExactMatch = false},
    {Message = ":colorshifttop 10000 0 0", ExactMatch = true},
    {Message = ":colorshiftbottom 10000 0 0", ExactMatch = true},
    {Message = ":colorshifttop 0 10000 0", ExactMatch = true},
    {Message = ":colorshiftbottom 0 10000 0", ExactMatch = true},
    {Message = ":colorshifttop 0 0 10000", ExactMatch = true},
    {Message = ":colorshiftbottom 0 0 10000", ExactMatch = true},
}


local cloneref = cloneref or clonereference or function(obj) return obj end
local Players = cloneref(game:GetService("Players"))
local TextChatService = cloneref(game:GetService("TextChatService"))
local LocalPlayer = Players.LocalPlayer


local isLegacyChat = TextChatService.ChatVersion == Enum.ChatVersion.LegacyChatService


local SystemNotification = loadstring(game:HttpGet("https://raw.atomgit.com/Furrycalin/ChronixHub/raw/main/modules/SystemNotification.lua"))()


local generalChannel = nil
local function getGeneralChannel()
    if not generalChannel then
        generalChannel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
    end
    return generalChannel
end


local function isIgnored(message)
    for _, v in ipairs(ignoreList) do
        if v.ExactMatch and message == v.Message then
            return true
        elseif not v.ExactMatch and message:find(v.Message) then
            return true
        end
    end
    return false
end


local function sendSpyMessage(text)
    local messageText = "[SPY] - " .. text
    if publicMode then
        
        local channel = getGeneralChannel()
        if channel then
            
            channel:SendAsync(messageText)
        elseif isLegacyChat then
            
            local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
            local DefaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if DefaultChatSystemChatEvents then
                local SayMessageRequest = DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                if SayMessageRequest then
                    SayMessageRequest:FireServer(messageText, "All")
                end
            end
        end
    else
        
        if isLegacyChat then
            local StarterGui = cloneref(game:GetService("StarterGui"))
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = messageText,
                Color = Color3.fromRGB(255, 0, 0)
            })
        else
            
            SystemNotification.Custom(messageText, Color3.fromRGB(255, 0, 0), "SourceSans", 14)
        end
    end
end


local function sendStatusMessage(text, isError)
    local color = isError and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    if isLegacyChat then
        local StarterGui = cloneref(game:GetService("StarterGui"))
        StarterGui:SetCore("ChatMakeSystemMessage", {
            Text = "[SPY] - " .. text,
            Color = color
        })
    else
        if isError then
            SystemNotification.Error("[SPY] - " .. text)
        else
            SystemNotification.Success("[SPY] - " .. text)
        end
    end
end


local function onMessageReceived(message, channel)
    
    if not enabled then return end

    
    local sender = message.TextSource
    local player = sender and Players:GetPlayerByUserId(sender.UserId)
    if not player then return end

    
    if not spyOnSelf and player == LocalPlayer then return end

    
    local cleanedMessage = message.Text:gsub("[\n\r]", ""):gsub("\t", " "):gsub("[ ]+", " ")
    if #cleanedMessage == 0 or isIgnored(cleanedMessage) then return end

    
    local isTeamChat = (channel.Name == "RBXTeam")
    
    
    
    

    
    if #cleanedMessage > 1200 then
        cleanedMessage = cleanedMessage:sub(1, 1200) .. "..."
    end
    
    local channelPrefix = isTeamChat and "[Team] " or ""
    local outputText = channelPrefix .. player.Name .. ": " .. cleanedMessage
    sendSpyMessage(outputText)
end


local function setupNewChatListener()
    local channel = getGeneralChannel()
    if not channel then
        
        task.wait(1)
        return setupNewChatListener()
    end
    
    
    local generalConn = channel.MessageReceived:Connect(function(msg)
        onMessageReceived(msg, channel)
    end)
    table.insert(connections, generalConn)
    
    
    local teamChannel = TextChatService.TextChannels:FindFirstChild("RBXTeam")
    if teamChannel then
        local teamConn = teamChannel.MessageReceived:Connect(function(msg)
            onMessageReceived(msg, teamChannel)
        end)
        table.insert(connections, teamConn)
    end
end


local function clearAllConnections()
    for _, conn in ipairs(connections) do
        if conn then
            conn:Disconnect()
        end
    end
    connections = {}
end


function ChatSpy.enable()
    if enabled then return end
    enabled = true
    clearAllConnections() 
    
    if isLegacyChat then
        
        sendStatusMessage("Legacy mode is not fully supported in this version.", true)
        return
    else
        
        setupNewChatListener()
    end

    sendStatusMessage("Enabled", false)
end


function ChatSpy.disable()
    if not enabled then return end
    enabled = false
    clearAllConnections()
    sendStatusMessage("Disabled", true)
end


function ChatSpy.unload()
    ChatSpy.disable()
    
    
    ChatSpy.enable = nil
    ChatSpy.disable = nil
    ChatSpy.unload = nil
    ChatSpy.setSpyOnSelf = nil
    ChatSpy.setPublicMode = nil
end


function ChatSpy.setSpyOnSelf(value)
    spyOnSelf = value
end

function ChatSpy.setPublicMode(value)
    publicMode = value
end

return ChatSpy