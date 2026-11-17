-- hey it's the paper (& pencil from the theme)
-- Prehapse do velocity stuff to make erase larger (QOL)

ObjectBase = {}
ObjectBase.__index = ObjectBase


setmetatable(ObjectBase, {
    __call = function(self, x, y, rx, ry, images, colour)
        return self:new(width, x, y, rx, ry, images, colour)
    end
})


function ObjectBase:new(x, y, rx, ry, images, colour)
    local obj = {}

    obj.x = x
    obj.y = y
    obj.rx = rx
    obj.ry = ry
    obj.colour = colour


    obj.images = images
    if math.random(1, 2) == 1 then      -- randomly flip the images
        images[1], images[2] = images[2], images[1]
    end

    -- these can be manually changed ig
    obj.sx = 1
    obj.sy = 1
    obj.r = 0

    obj.ox = images[1]:getWidth()/2
    obj.oy = images[1]:getHeight()/2

    setmetatable(obj, {
        __index = ObjectBase,
    })


    return obj
end

function ObjectBase:draw(imageNo)
    local image = self.images[imageNo or 1]

    love.graphics.setColor(self.colour or {1,1,1})
    love.graphics.draw(image, self.x, self.y, self.r, self.sx, self.sy, self.ox, self.oy)
end