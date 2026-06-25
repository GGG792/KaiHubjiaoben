

local url = string.char(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,71,71,71,55,57,50,47,75,97,105,72,117,98,106,105,97,111,98,101,110,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,85,105,46,108,117,97) .. "?t=" .. tostring(tick())


local source = game:HttpGet(url)


local replacements = {
    
    ['"Launches: "'] = '"启动次数: "',
    ['Session: 00:00:00'] = "使用时长: 00:00:00",
    ['Session:'] = "使用时长:",

    
    ['UNC:'] = "UNC:",
    ['sUNC:'] = "sUNC:",
    ['Detected'] = "已检测",
    ['Undetected'] = "未检测",
    ['Free'] = "免费",
    ['Paid'] = "付费",
    ['Updated'] = "已更新",
    ['Outdated'] = "已过期",
    ['Website'] = "官网",
    ['Discord'] = "Discord",

    
    ['HWID'] = "HWID",
    ['Memory'] = "内存",
    ['Network'] = "网络",

    
    ['Roblox - '] = "Roblox - ",

    
    ['UnKnown'] = "未知",
}


for eng, chn in pairs(replacements) do
    source = source:gsub(eng, chn)
end


loadstring(source)()
