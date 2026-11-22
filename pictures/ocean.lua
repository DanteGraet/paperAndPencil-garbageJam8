local level = {}

-- viewing time in secconds
level.time = 20

local objectManager = ObjectManager()

function level.cleanUp()
    objectManager = nil
    level.time = nil
end

function level.loadObjects()
    objectManager:flush()

    objectManager:load("object/fish/fish.lua", "fish")
    objectManager:load("object/seaFloor/seaFloor.lua", "seaFloor")
end


function level.generateObjects()
    local o = {}

    local objectSize = 250


    -- spawn a shark or sub

    for i = 1, 10 do
        local x = math.random(50, 1300)
        local y = math.random(50, 800)
        
        local spawn = true
        for j = 1, #o do
            if quindoc.pythag(o[j].x - x, o[j].y - y) < 150 then
                spawn = false
            end
        end

        if spawn == true then
            table.insert(o, objectManager:get("fish"):new(objectManager, x, y, nil, 200))
        end
    end

    for x = 1, 5 do
        if math.random(1, 4) == 1 then
            
        else
            local x = 200 + (x-1)  / 4 * 1000 + math.random(-100, 100)
            local y = math.random(800, 950)
            obj = objectManager:get("seaFloor"):new(objectManager, x, y, 2)
            table.insert(o, math.random(1, #o+1), obj)
        end
    end

    table.sort(o, function(a, b) return a.y + ((a.type == "Fish" and 300) or 0) < b.y + ((b.type == "Fish" and 300) or 0) end)

    return o, nil, love.graphics.newImage("object/background/underwater.png")
end

function level.permutate(objects)
    local changes = {}

    local choices = {}
    for i = 1,#objects do
        if objects[i].permutate and objects[i].x > 0 and objects[i].x < 1400 then
            table.insert(choices, i)
        end
    end

    for i = 1, math.min(math.random(3, 4), #choices) do
        local r = math.random(1, #choices)
        local obj = objects[choices[r]]

        table.remove(choices, r)

        local change = obj:permutate()

        table.insert(changes, change)
    end

    return changes
end

return level