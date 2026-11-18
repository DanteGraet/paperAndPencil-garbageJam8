local level = {}

-- viewing time in secconds
level.time = 15
local swapChance = 0

function level.loadObjects()
    objectManager.flush()

    objectManager.load("object/chess/chessPiece.lua", "chessPiece")
    --objectManager.load("object/fruit/fruit.lua", "fruit")
end


function level.generateObjects()
    local o = {}

    local objectSize = 250

    for x = 1,5 do
        for y = 1, 3 do
            local obj = objectManager.getRandom():new(-50 + x*250, -25 + y*250, nil, objectSize)
            --local scale = 250/(obj.ox*2)
            -- only using sx for consistantcy or something

            obj.r = math.random(-100, 100)/200

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