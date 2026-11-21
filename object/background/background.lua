local Background = {}
Background.__index = Background

setmetatable(Background, {__index = ObjectBase})


function Background:new(objectManager, var, colour)
    local image = love.graphics.newImage("object/background/" .. var .. ".png")

    -- im hoping this just stores a 
    local images = {
        image,
        image
    }

    local obj = ObjectBase:new(700, 950/2, images, colour)

    obj.type = "Background"

    setmetatable(obj, {
        __index = Background,
    })

    return obj
end

return Background