local level = {}

-- viewing time in secconds
level.time = 20
local swapChance = 0

local backgroundColours = {
    {0.1, 0.2, 0.4},
    {0.2, 0.4, 0.1},
    {0.4, 0.1, 0.2},
}

local objectManager = ObjectManager()

function level.loadObjects()
    objectManager:flush()

    objectManager:load("object/chess/chessPiece.lua", "chessPiece")
    objectManager:load("object/fruit/fruit.lua", "fruit")
end


function level.generateObjects()
    local o = {}

    local size = 400
    for y = 1, 4 do
        for x = 1, y do
            local xPos = (x - y/2 -0.5) * 250
            local yPos = 150*8 - 950 + y *150

            --[[
            1400, 950
            ]]

            local obj = objectManager:getRandom():new(objectManager, 700 + xPos, yPos, nil, size)


            obj.r = math.random(-100, 100)/100

            table.insert(o, obj)
        end
    end

    return o, backgroundColours[math.random(1, #backgroundColours)]
end

function level.permutate(objects)
    local changes = {}

    local choices = {}
    for i = 1,#objects do
        if objects[i].permutate then
            table.insert(choices, i)
        end
    end

    for i = 1, math.min(3, #choices) do
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