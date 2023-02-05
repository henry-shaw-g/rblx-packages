--[[
	VisualDebug: Debugging utility.
	Author: wafflechad
	Version: 1.0.0 (server & client compatible, types, refactors)

	* Display visual information such as points, radii, cframes, lines, etc.
	* Choose between displaying per frame or for longer periods
	* Uses pooling for efficient rapid rendering with many instances
]]

local visualDebug = {}

-- DEPENDS --
local runService = game:GetService("RunService")
local debris = game:GetService("Debris")
local renderPool = require(script:WaitForChild("RenderPool"))

-- Constants --
local DEFAULT_COLOR = Color3.fromRGB(255, 255, 255)

-- Variables --
local terrain = workspace.Terrain
local pools = {}

-- Private --
local function getColor(c): Color3
	if typeof(c) == "Color3" then
		return c
	elseif typeof(c) == "string" then
		if visualDebug.color[c] then
			return visualDebug.color[c]
		else
			error("Invalid Color String.")
		end
	else
		return DEFAULT_COLOR
	end
end

local function createDebugPart(): Part
	local part = Instance.new("Part")
	part.Name = "VisualDebugPart"

	part.Transparency = 0.25
	part.Size = Vector3.new(0, 0, 0)
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Parent = terrain

	return part
end

local function createPart(): Part
	local part = createDebugPart()
	part.Shape = Enum.PartType.Block
	return part
end

local function createSphere(): Part
	local sphere = createDebugPart()
	sphere.Shape = Enum.PartType.Ball
	return sphere
end

local spherePool = renderPool.new(createSphere)
	table.insert(pools, spherePool)
local partPool = renderPool.new(createPart)
	table.insert(pools, partPool)

local function getSphere(t, cf, color, radius)
	local sphere
	if t then
		sphere = createSphere()
		debris:AddItem(sphere, t)
	else
		sphere = spherePool:use()
	end
	sphere.Color = getColor(color)
	sphere.Size = Vector3.new(2 * radius, 2 * radius, 2 * radius)
	sphere.CFrame = cf
	return sphere
end

local function getPart(t, cf, color, width, length)
	local part
	if t then
		if not (t == visualDebug.PERMANENT) then
			part = createPart()
			debris:AddItem(part, t)
		end
	else
		part = partPool:use()
	end
	part.Color = getColor(color)
	part.Size = Vector3.new(width, width, length)
	part.CFrame = cf
	return part
end


-- clean all pools
local function flush()
	for i = 1, #pools do
		local pool = pools[i]
		if not pool then continue end

		pool:flush()
	end
end

-- render all pools
local function render()
	for i = 1, #pools do
		local pool = pools[i]
		if not pool then continue end

		pool:rendered()
	end
end

-- Public --
visualDebug.PERMANENT = -1 -- time input flag to make a debug item permanent

-- mini color library
visualDebug.color = {
	red 			= Color3.fromRGB(255, 0, 0),
	green 			= Color3.fromRGB(0, 255, 0),
	blue 			= Color3.fromRGB(0, 0, 255),
	yellow 			= Color3.fromRGB(255, 217, 0),
	orange  		= Color3.fromRGB(255, 126, 14),
	purple 			= Color3.fromRGB(135, 14, 255),
}

-- drawing interface
function visualDebug.drawRay(position, vector, color, timelength)
	local position = position + vector/2
	local ray = getPart(timelength, CFrame.new(position, position + vector), color, 0.2, vector.Magnitude)
end

function visualDebug.drawSphere(position, radius, color, timelength)
	local sphere = getSphere(timelength, CFrame.new(position), color, radius)
end

function visualDebug.drawCFrame(cframe, scale, timelength)
	scale = scale or 1
	visualDebug.drawRay(cframe.Position, cframe.LookVector * scale, visualDebug.color.blue, timelength)
	visualDebug.drawRay(cframe.Position, cframe.RightVector * scale, visualDebug.color.red, timelength)
	visualDebug.drawRay(cframe.Position, cframe.UpVector * scale, visualDebug.color.green, timelength)
end

function visualDebug.drawLine(p1, p2, color, timeLength)
	visualDebug.drawRay(p1, p2 - p1, color, timeLength)
end

-- STARTUP --
if runService:IsClient() then
	runService.Heartbeat:Connect(function() 
		flush() -- it may be ok to just flush and render in render stepped
	end)
	runService.RenderStepped:Connect(function() 
		render()
	end)
else
	runService.Heartbeat:Connect(function() 
		flush()
		render()
	end)
end


return visualDebug