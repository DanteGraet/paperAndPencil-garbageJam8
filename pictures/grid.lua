local level = {}

-- viewing time in secconds
level.time = 20
local swapChance = 0


local objectManager = ObjectManager()

function level.loadObjects()
    objectManager:flush()

    objectManager:load("object/chess/chessPiece.lua", "chessPiece", {"full"})
    objectManager:load("object/fruit/fruit.lua", "fruit", {"full"})
    objectManager:load("object/utensil/utensil.lua", "utensil", {"full"})
    
    objectManager:load("object/empty.lua", "empty")
end


function level.generateObjects()
    local o = {}

    local objectSize = 250

    for x = 1,5 do
        for y = 1, 3 do
            local obj = objectManager:getRandom():new(objectManager, -50 + x*250, -25 + y*250, nil, objectSize)
            --local scale = 250/(obj.ox*2)
            -- only using sx for consistantcy or something

            obj.r = math.random(-100, 100)/200

            if math.random(1, 10) == 1 then
                obj = objectManager:get("empty"):new(objectManager, -50 + x*250, -25 + y*250, nil, objectSize)
            end

            table.insert(o, obj)
        end
    end

    return o
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
            obj =  objectManager:getRandom():new(objectManager, obj.x, obj.y)
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