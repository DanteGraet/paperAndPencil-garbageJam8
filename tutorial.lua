local level = {}

-- viewing time in secconds
level.time = 60
local swapChance = 0

local objectManager = ObjectManager()

function level.loadObjects()
    objectManager:flush()

    objectManager:load("object/chess/chessPiece.lua", "chessPiece")
    objectManager:load("object/fruit/fruit.lua", "fruit")

    objectManager:load("object/background/background.lua", "bg")
end


function level.generateObjects()
    local o = {}

    -- this one is hard-coded
    table.insert(o, objectManager:get("bg"):new(objectManager,"tutorial1"))

    table.insert(o, objectManager:get("chessPiece"):new(objectManager, 400, 950/4*2.75, "Kb", 300))
    table.insert(o, objectManager:get("chessPiece"):new(objectManager, 700, 950/4*2.75, "Rw", 300))
    table.insert(o, objectManager:get("fruit"     ):new(objectManager,1000, 950/4*2.75,  "apple", 300))

    return o
end

function level.permutate(objects)
    local changes = {}

    objects[1] = objectManager:get("bg"):new(objectManager, "tutorial2")

    objects[3] = objectManager:get("chessPiece"):new(objectManager, 700, 950/4*2.75, "Rb", 300)
    objects[4] = objectManager:get("fruit"     ):new(objectManager,1000, 950/4*2.75,  "mango", 300)


    objects[3].hasMutated = true
    objects[4].hasMutated = true

    return changes
end

return level