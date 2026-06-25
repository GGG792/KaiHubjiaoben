local module = {}
local enabled = false
local connection = nil
local originals = {}

function module.enable()
	if enabled then return end
	enabled = true

	
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			originals[v] = v.HoldDuration
			v.HoldDuration = 0
		end
	end

	
	connection = workspace.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("ProximityPrompt") then
			originals[descendant] = descendant.HoldDuration
			descendant.HoldDuration = 0
		end
	end)
end

function module.disable()
	if not enabled then return end
	enabled = false

	if connection then
		connection:Disconnect()
		connection = nil
	end

	
	for prompt, originalDuration in pairs(originals) do
		if prompt and prompt.Parent then
			prompt.HoldDuration = originalDuration
		end
	end
	table.clear(originals)
end

function module.unload()
	module.disable()
end

return module