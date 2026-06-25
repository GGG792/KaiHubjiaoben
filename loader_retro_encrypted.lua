
if _G.unloadKaiHubRetro then pcall(_G.unloadKaiHubRetro) end
_G.KaiHubRetroLoaded = false
_G.KaiHubRetroLoading = false
task.wait(0.5)
local url = string.char(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,71,71,71,55,57,50,47,75,97,105,72,117,98,82,101,116,114,111,84,101,115,116,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,109,97,105,110,46,108,117,97) .. "?t=" .. tostring(tick())
loadstring(game:HttpGet(url))()
