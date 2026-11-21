local level = {}

-- viewing time in secconds
level.time = 15
local swapChance = 0
local potI

local objectManager = ObjectManager()

function level.loadObjects()
    objectManager:flush()

    objectManager:load("object/fruit/fruit.lua", "fruit", {"benchTop", "inPot"})
    objectManager:load("object/utensil/utensil.lua", "utensil", {"benchTop"})

    objectManager:load("object/stoveTop/stoveTop.lua", "stoveTop")
end


function level.generateObjects()
    local o = {}

    local objectSize = 250

    local potI = math.random(0, 3)

    for i = 0, 3 do
        local x, y = 245 + 460*(i % 2), 255 + 440 * math.floor(i/2)
        local obj = objectManager:get("stoveTop"):new(objectManager, x, y)

        if i == potI then
            obj, extras = objectManager:get("stoveTop"):new(objectManager, x, y, "pot")

            for j = 1, #extras do
                table.insert(o, extras[j])
            end
        end

        table.insert(o, 1, obj)
    end


    if potI == 4 then
        potI = nil
    end

    for y = 1, 3 do
        local obj = objectManager:getRandom("benchTop"):new(objectManager, -50 + 5*250, -25 + y*250, nil, objectSize)

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

        local change = obj:permutate()

        table.insert(changes, change)
    end

    return changes
end

return level