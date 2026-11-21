local images = {

}

local Static = {}
Static.__index = Static

setmetatable(Static, {__index = ObjectBase})


function Static:new(objectManager, x, y, var)
    local images = {
        love.graphics.newImage("object/static/" .. var .. "1.png"),
        love.graphics.newImage("object/static/" .. var .. "2.png")
    }
    local obj = ObjectBase:new(x, y, images, colour, nil)

    obj.type = "Static"

    setmetatable(obj, {
        __index = Static,
    })

    return obj
end


return Static