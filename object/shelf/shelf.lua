local images = {
    love.graphics.newImage("object/shelf/shelf1.png"),
    love.graphics.newImage("object/shelf/shelf2.png")
}

local Shelf = {}
Shelf.__index = Shelf

setmetatable(Shelf, {__index = ObjectBase})


function Shelf:new(x, y)
    local obj = ObjectBase:new(x, y, images, colour, nil)

    obj.type = "Shelf"

    setmetatable(obj, {
        __index = Shelf,
    })


    local extra = {}

    for i = 1, 3 do
        local obj = objectManager.getRandom("full"):new(x - 200 + i*100 + math.random(-25, 25), y-50, nil, 100)
        table.insert(extra, obj)
    end


    return obj, extra
end


return Shelf