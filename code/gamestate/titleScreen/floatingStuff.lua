local floatingStuff = {}

local objects = {}
local spawnFloatingStuffTimer = 0
local floatingTimer = 0

function floatingStuff.spawn(scatter)
    local objectsCanSpawn = {
        "fruit/fruit", "chess/chessPiece", "utensil/utensil", "fish/fish"
    }
    local ox, oy = 0, 0
    if camera then
        ox, oy = camera:getOffset()
    end

    local name = objectsCanSpawn[math.random(1, #objectsCanSpawn)]

    local obj = love.filesystem.load("object/" ..  name .. ".lua")():new(nil, math.random(250, 1920-250), ((scatter == true and math.random(-oy, oy + 1080) ) or - oy - 200), nil, 250)
    obj.vy = math.random(50, 150)
    obj.ro = math.random(1, 1000)
    obj.rm = math.random(0.95, 1.95)


    table.insert(objects, obj)
end

function floatingStuff.draw()
    local toDraw = math.floor((spawnFloatingStuffTimer*5) % 2) + 1
    for i = 1,#objects do
        objects[i]:draw(toDraw)
    end

    local ox, oy = camera:getOffset()
    love.graphics.setColor(73/255, 142/255, 145/255, 0.5)
    love.graphics.rectangle("fill", -10, -10 - oy, 1920 + 20, 1080 + 20 + oy*2)

    love.graphics.setColor(1, 1, 1)
end


function floatingStuff.update(dt)
    spawnFloatingStuffTimer = spawnFloatingStuffTimer - dt
    floatingTimer = floatingTimer + dt

    if spawnFloatingStuffTimer < 0 then
        floatingStuff.spawn()
        spawnFloatingStuffTimer = spawnFloatingStuffTimer + math.random(30, 50)/10
    end
    local ox, oy = camera:getOffset()
    for i = #objects, 1, -1 do
        local obj = objects[i]

        obj.y = obj.y + dt * obj.vy
        obj.r = math.sin((floatingTimer + obj.ro) * obj.rm) / 4

        if obj.y > oy + 1280 then
            table.remove(objects, i)
        end
    end
end

math.randomseed(os.time(), love.timer.getTime())
for i = 1,10 do
    floatingStuff.spawn(true)
end

return floatingStuff