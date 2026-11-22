local level = {}

-- viewing time in secconds
level.time = 35

local objectManager = ObjectManager()

function level.cleanUp()
    objectManager = nil
    level.time = nil
end

function level.loadObjects()
    objectManager:flush()

    objectManager:load("object/building/building.lua", "building")
    objectManager:load("object/skyObject/skyObject.lua", "skyObject")


    objectManager:load("object/static/static.lua", "static")
    objectManager:load("object/rectangle.lua", "rect")
end


function level.generateObjects()
    local o = {}

    local objectSize = 250

    local x = -100
    local lastWidth = 0
    while x < 1400 do
        --x = x + lastWidth * math.random(0.55, 0.88)
        x = x + (lastWidth) - math.random(25, 50)

        local obj = objectManager:get("building"):new(objectManager, x, 700)

        obj.x = obj.x + obj.ox

        local yOffset = math.random(0, 25)
        obj.y = obj.y + yOffset

        x = x + (obj.ox) - math.random(25, 50)

        lastWidth = obj.ox

        -- Rng used for sorting (higher buildings go towards the end)
        obj.rng = math.random(obj.oy, obj.oy)

        table.insert(o, obj)
    end

    table.sort(o, function(a, b) return a.rng > b.rng end)

    table.insert(o, objectManager:get("static"):new(objectManager, 700, 700, "bar"))

    local count = math.random(2, 3)
    for i = 1, count do
        local p = (i - 0.5) / (count)
        local x = (p) * 1200 + 100 + math.random(-100, 100)
        local y = math.random(100, 250)

        table.insert(o, objectManager:get("skyObject"):new(objectManager, x, y))
    end

    table.insert(o, 1, objectManager:get("rect"):new(objectManager, 0, 700, 1400, 300, {.2, .7, .3}))

    return o, {104/255, 171/255, 197/255}
end

function level.permutate(objects)
    local changes = {}

    local choices = {}
    for i = 1,#objects do
        if objects[i].permutate and objects[i].x > 0 and objects[i].x < 1400 then
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