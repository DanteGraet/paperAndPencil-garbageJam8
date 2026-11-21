local images = {
    base = {
        love.graphics.newImage("object/clock/clock1.png"),
        love.graphics.newImage("object/clock/clock2.png")
    },
    hands = {
        love.graphics.newImage("object/clock/hands1.png"),
        love.graphics.newImage("object/clock/hands2.png")
    },
}

local Clock = {}
Clock.__index = Clock

setmetatable(Clock, {__index = ObjectBase})


function Clock:new(objectManager, x, y)
    local colliders = {
        ElipticalCollider(0, 0, 150, 150)
    }

    local obj = ObjectBase:new(x, y, images.base, colour, colliders)

    
    obj.variant = math.random(1, 64)
    obj.type = "Clock"


    setmetatable(obj, {
        __index = Clock,
    })

    return obj, extra
end


function Clock:permutate()
    local newVariant = math.random(1, 64)

    if newVariant == self.variant then
        -- this should garantee it's different
        newVariant = newVariant + math.random(1, 63)
    end

    self.variant = newVariant

    self.hasMutated = true
end

function Clock:draw(imageNo, scaleBonus)
    local image = self.images[imageNo or 1]

    love.graphics.setColor(self.colour or {1,1,1})
    love.graphics.draw(image, self.x, self.y, self.r, self.sx * (scaleBonus or 1), self.sy * (scaleBonus or 1), self.ox, self.oy)

    local hand1 = (self.variant % 8) / 8 * math.pi * 2
    local hand2 = math.floor(self.variant/ 8) / 8 * math.pi * 2

    love.graphics.draw(images.hands[imageNo], self.x, self.y, hand1, self.sx * (scaleBonus or 1), self.sy * (scaleBonus or 1), self.ox, self.oy)
    love.graphics.draw(images.hands[imageNo], self.x, self.y, hand2, self.sx * (scaleBonus or 1), self.sy * (scaleBonus or 1), self.ox, self.oy)

end

return Clock