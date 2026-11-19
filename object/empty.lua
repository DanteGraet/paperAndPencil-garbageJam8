local EmptyObject = {}
EmptyObject.__index = EmptyObject

setmetatable(EmptyObject, {__index = ObjectBase})


function EmptyObject:new(x, y, var, size)
    local colliders = {
        ElipticalCollider(0, 0, size*0.8 or 50, size*0.8 or 50)
    }

    local obj = ObjectBase:new(x, y, nil, colour, colliders)


    setmetatable(obj, {
        __index = EmptyObject,
    })

    return obj
end

function EmptyObject:draw()

end


return EmptyObject