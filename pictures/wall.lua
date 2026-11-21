local level = {}

-- viewing time in secconds
level.time = 25
local swapChance = 0

local colours = {
    {1, .8, .8},
    {.8, 1, .8},
    {.8, .8, 1},
    {1, 1, .8},
    {.8, 1, 1},
    {1, .8, 1},
}

local objectManager = ObjectManager()

function level.loadObjects()
    objectManager:flush()

    objectManager:load("object/frame/photoFrame.lua", "photoFrame", {"wallBase"})
    objectManager:load("object/shelf/shelf.lua", "shelf", {"wallBase"})-- shelf

    objectManager:load("object/window/window.lua", "window")-- shelf
    objectManager:load("object/clock/clock.lua", "clock")-- shelf

    objectManager:load("object/chess/chessPiece.lua", "chessPiece", {"full"})
    objectManager:load("object/fruit/fruit.lua", "fruit", {"full"})
    objectManager:load("object/empty.lua", "empty")
end


function level.generateObjects()
    local o = {}

    local clockPos = math.random(1, 7)  -- chance for no clock
    local windowPos = math.random(1, 6)  -- chance for no window (if it overlaps clock)

    for x = 1,3 do
        for y = 1, 2 do
            local xPos = (1400-100) / 3 * (x - 0.5) + math.random(-50, 50) + 50
            local yPos = (950-100) / 2 * (y - 0.5) + math.random(-50, 50) + 50

            local obj
            local extra
            if x + y * 3 == clockPos then
                obj = objectManager:get("clock"):new(objectManager, xPos, yPos, nil, objectSize)
            elseif x + y * 3 == windowPos then
                obj = objectManager:get("window"):new(objectManager, xPos, yPos, nil, objectSize)
            else
                if math.random(1, 4) == 1 then
                    obj, extra = objectManager:get("shelf"):new(objectManager, xPos, yPos, nil, objectSize)
                else
                    obj, extra = objectManager:get("photoFrame"):new(objectManager, xPos, yPos, nil, objectSize)
                end
            end

            table.insert(o, obj)


            if extra then
                for i = 1, #extra do
                    table.insert(o, extra[i])
                end
            end

        end
    end

    return o, colours[math.random(1,#colours)], love.graphics.newImage("object/background/wallpaper" .. math.random(1, 4) .. ".png")
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

            table.insert(changes, {obj.x + obj.ox, obj.y + obj.oy, obj.rx * obj.sx, obj.ry * obj.sy})
        else
            local change = obj:permutate()

            table.insert(changes, change)
        end
    end

    return changes
end

return level