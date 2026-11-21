local RectangleObject = {}
RectangleObject.__index = RectangleObject

setmetatable(RectangleObject, {__index = ObjectBase})


function RectangleObject:new(objectManager, x, y, sx, sy, colour, colliders)
    local obj = {}

    obj.x = x or 0
    obj.y = y or 0
    obj.sx = sx or 100
    obj.sy = sy or 100

    obj.colour = colour or {1, 1, 1}

    obj.colliders = colliders


    setmetatable(obj, {
        __index = RectangleObject,
    })

    return obj
end

function RectangleObject:draw()
    love.graphics.setColor(self.colour)
    love.graphics.rectangle("fill", self.x, self.y, self.sx, self.sy)
    love.graphics.setColor(1, 1, 1)

end


return RectangleObject