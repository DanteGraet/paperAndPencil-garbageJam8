local level = {}

-- viewing time in secconds
level.time = 30
local swapChance = 0

function level.loadObjects()
    objectManager.flush()

    objectManager.load("object/fruit/fruit.lua", "fruit", {"benchTop"})

    objectManager.load("object/stoveTop/stoveTop.lua", "stoveTop")
end


function level.generateObjects()
    local o = {}

    local objectSize = 250

    for i = 0, 3 do
        local x, y = 245 + 460*(i % 2), 255 + 440 * math.floor(i/2)
        local obj = objectManager.get("stoveTop"):new(x, y)

        table.insert(o, obj)
    end

    for y = 1, 3 do
        local obj = objectManager.getRandom("benchTop"):new(-50 + 5*250, -25 + y*250, nil, objectSize)

        obj.r = math.random(-100, 100)/150

        table.insert(o, obj)
    end

    return o, nil, love.graphics.newImage("object/background/kitchen.png")
end

function level.permutate(objects)
    local changes = {}

    local choices = {}
    for i = 1,#objects do
        if objects[i].permutate then
            table.insert(choices, i)
        end
    end

    for i = 1, math.min(math.random(3, 5), #choices) do
        local r = math.random(1, #choices)
        local obj = objects[choices[r]]

        table.remove(choices, r)

        if math.random() < swapChance then
            obj =  objectManager.getRandom():new(obj.x, obj.y)
            obj.sx = 250/(obj.ox*2)
            obj.sy = 250/(obj.ox*2)
            obj.r = math.random(-100, 100)/200

            table.insert(changes, {obj.x + obj.ox, obj.y + obj.oy, obj.rx * obj.sx, obj.ry * obj.sy})
        else
            local change = obj:permutate()
            obj.r = math.random(-100, 100)/200

            table.insert(changes, change)
        end
    end

    return changes
end

return level