local eventStack = {}
function addEvent(eventType, method, priority)
	if not eventStack[eventType] then
		eventStack[eventType] = {}
	end

	local event = {method, priority}
	table.insert(eventStack[eventType], event)

	table.sort(eventStack[eventType], function(a, b) return a[2] < b[2] end)
end


local function processEventStack(name, a,b,c,d,e,f)
	if love[name] and love[name](a,b,c,d,e,f) == true then
		return true
	end

	if eventStack[name] then
		for i = 1,#eventStack[name] do
			if eventStack[name][i][1](a, b, c, d, e, f) == true then
				return true
			end
		end
	end
end


local function processEvents(gameState)
	if love.event then
		love.event.pump()
		for name, a,b,c,d,e,f in love.event.poll() do

			local result = processEventStack(name, a,b,c,d,e,f)

			if name == "quit" and not result then
				return a or 0
			end
		end
	end
end


local function mainUpdate()
	-- Update dt, as we'll be passing it to update
	local dt
	if love.timer then dt = math.min(love.timer.step(), 1/10) end

	processEventStack("update", dt)
end


local function draw()
	if love.graphics and love.graphics.isActive() then
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.origin()

		processEventStack("draw")

		love.graphics.present()
	end
end


function love.run()
	-- We don't want the first frame's dt to include time taken by loading.
	if love.timer then love.timer.step() end

	-- Main loop
	return function()
		local quit = processEvents(gameState)
		if quit then return quit end

		mainUpdate()

		draw()

		if love.timer then love.timer.sleep(0.001) end
	end
end


-- Managers should be persistant
print("Loading Managers")
local managers = love.filesystem.getDirectoryItems("manager")
for i = 1,#managers do
	local managerName = string.gsub(managers[i], ".lua", "")

	require("manager/" .. managerName)

	print(" -> Loaded " .. managerName)
end

-- Global ojects, objects that anything can acsess
print("Loading Global Objects")
local globalObjects = love.filesystem.getDirectoryItems("globalObject")
for i = 1,#globalObjects do
	local objectName = string.gsub(globalObjects[i], ".lua", "")

	require("globalObject/" .. objectName)

	print(" -> Loaded " .. objectName)
end

love.graphics.setDefaultFilter("nearest","nearest")
love.filesystem.load("code/globals.lua")()