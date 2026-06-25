local ConfigModule = {}
local cloneref = cloneref or clonereference or function(obj) return obj end
ConfigModule.mainFolderName = nil
ConfigModule.config = {}


local function stringSplit(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from, true)
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from, true)
    end
    table.insert(result, string.sub(str, from))
    return result
end


local function isAudioFile(filename)
    local audioExtensions = {
        [".mp3"] = true,
        [".wav"] = true,
        [".ogg"] = true,
        [".flac"] = true,
        [".m4a"] = true,
        [".wma"] = true,
        [".aac"] = true
    }
    
    local lowerFilename = string.lower(filename)
    for ext, _ in pairs(audioExtensions) do
        if string.sub(lowerFilename, -string.len(ext)) == ext then
            return true
        end
    end
    return false
end


local function createDirectory(path)
    local parts = stringSplit(path, "/")
    local currentPath = ""
    for _, part in ipairs(parts) do
        if part ~= "" then  
            if currentPath == "" then
                currentPath = part
            else
                currentPath = currentPath .. "/" .. part
            end
            
            local success = pcall(function()
                readfile(currentPath .. "/.keep")
            end)
            
            if not success then
                local writeSuccess, writeErr = pcall(function()
                    writefile(currentPath .. "/.keep", "")
                end)
                if not writeSuccess then
                    warn("无法创建目录: " .. currentPath .. " - " .. tostring(writeErr))
                end
            end
        end
    end
end

local function isSupportedPath(str)
    
    for _, char in utf8.codes(str) do
        if char > 127 then
            
            return false
        end
    end
    
    
    
    local unsafeChars = {
        ["\\"] = true,  
        [":"] = true,   
        ["*"] = true,   
        ["?"] = true,   
        ['"'] = true,   
        ["<"] = true,   
        [">"] = true,   
        ["|"] = true,   
        ["%%"] = true,  
    }
    
    for char in string.gmatch(str, ".") do
        if unsafeChars[char] then
            return false
        end
    end
    
    return true
end


function ConfigModule.setmain(folderName)
    if not folderName or folderName == "" then
        error("必须提供有效的主配置文件夹名称")
    end
    
    ConfigModule.mainFolderName = folderName
    createDirectory(folderName)
end


function ConfigModule.createconfig(path)
    if not ConfigModule.mainFolderName then
        error("请先使用 setmain() 设置主配置文件夹")
    end
    
    if not path or path == "" then
        error("必须提供有效的配置文件路径")
    end
    
    local pathParts = stringSplit(path, "/")
    local fileName = pathParts[#pathParts]
    table.remove(pathParts, #pathParts)
    
    local fullPath = ConfigModule.mainFolderName
    for _, part in ipairs(pathParts) do
        fullPath = fullPath .. "/" .. part
    end
    
    
    createDirectory(fullPath)
    
    local configFilePath = fullPath .. "/" .. fileName .. ".json"
    
    
    local configData = {}
    local success, content = pcall(function()
        return readfile(configFilePath)
    end)
    
    if success and content and content ~= "" then
        local decodeSuccess, decodedData = pcall(function()
            return cloneref(game:GetService("HttpService")):JSONDecode(content)
        end)
        if decodeSuccess then
            configData = decodedData
        end
    end
    
    local configObject = {}
    
    
    local data = configData
    local filePath = configFilePath
    
    local mt = {
        __index = function(_, key)
            return data[key]
        end,
        __newindex = function(_, key, value)
            data[key] = value
            local encodedData = cloneref(game:GetService("HttpService")):JSONEncode(data)
            writefile(filePath, encodedData)
        end
    }
    
    setmetatable(configObject, mt)
    ConfigModule.config[path] = configObject
    
    return configObject
end


function ConfigModule.createmusicconfig(path)
    if not ConfigModule.mainFolderName then
        error("请先使用 setmain() 设置主配置文件夹")
    end
    
    if not path or path == "" then
        error("必须提供有效的音乐配置路径")
    end
    
    
    local musicFolderPath = ConfigModule.mainFolderName .. "/" .. path
    
    
    if not isfolder(musicFolderPath) then
        makefolder(musicFolderPath)
        return { ["无"] = "" }
    end
    
    
    local musicTable = {}
    local success, files = pcall(function()
        return listfiles(musicFolderPath)
    end)
    
    if success and files then
        for _, filepath in ipairs(files) do
            
            local parts = stringSplit(filepath, "\\")
            local filename = parts[#parts]

            if not isSupportedPath(filename) then
                warn("不支持的文件名: " .. filename)
                
            elseif isAudioFile(filename) then
                
                local nameWithoutExt = string.gsub(filename, "%.[^.]*$", "")
                
                
                local assetId = getcustomasset(filepath)
                
                if assetId and assetId ~= "" then
                    musicTable[nameWithoutExt] = assetId
                end
            end
        end
    else
        warn("无法读取音乐文件夹: " .. musicFolderPath)
    end
    
    return musicTable
end

return ConfigModule