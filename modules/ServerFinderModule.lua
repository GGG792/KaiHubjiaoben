



local cloneref = cloneref or clonereference or function(obj) return obj end
local HttpService = cloneref(game:GetService("HttpService"))

local ServerQuery = {}
ServerQuery.__index = ServerQuery


function ServerQuery.new(placeId)
	local self = setmetatable({}, ServerQuery)
	self._placeId = placeId or game.PlaceId
	self._servers = {}      
	self._scanning = false  
	return self
end


function ServerQuery:_fetchPage(cursor)
	local url = "https://games.roblox.com/v1/games/" .. self._placeId .. "/servers/Public?sortOrder=Desc&limit=100"
	if cursor and cursor ~= "null" then
		url = url .. "&cursor=" .. cursor
	end

	local success, result = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)

	if not success then
		return nil, result  
	end
	return result
end



function ServerQuery:refresh()
	if self._scanning then
		return self._servers  
	end

	self._scanning = true
	self._servers = {}

	local cursor = nil
	repeat
		local page, err = self:_fetchPage(cursor)
		if not page then
			warn("ServerQuery: 获取服务器列表出错:", err)
			break
		end

		if page.data then
			for _, server in ipairs(page.data) do
				table.insert(self._servers, server)
			end
		end

		cursor = page.nextPageCursor
		if cursor == "null" then
			cursor = nil
		end

		
		task.wait()
	until not cursor

	self._scanning = false
	return self._servers
end


function ServerQuery:getServers()
	return self._servers
end


function ServerQuery:getServerById(serverId)
	for _, server in ipairs(self._servers) do
		if server.id == serverId then
			return server
		end
	end
	return nil
end


function ServerQuery:isScanning()
	return self._scanning
end



function ServerQuery:refreshAsync(callback)
	if self._scanning then
		if callback then
			callback(self._servers)
		end
		return
	end

	self._scanning = true
	self._servers = {}

	local function scan(cursor)
		local page, err = self:_fetchPage(cursor)
		if not page then
			warn("ServerQuery: 获取服务器列表出错:", err)
			self._scanning = false
			if callback then callback(self._servers) end
			return
		end

		if page.data then
			for _, server in ipairs(page.data) do
				table.insert(self._servers, server)
			end
		end

		local nextCursor = page.nextPageCursor
		if nextCursor and nextCursor ~= "null" then
			
			task.spawn(function()
				scan(nextCursor)
			end)
		else
			self._scanning = false
			if callback then callback(self._servers) end
		end
	end

	task.spawn(function()
		scan(nil)
	end)
end

return ServerQuery