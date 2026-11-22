local variants = {
    "yellow",
    "orange",
}

local images = {}
for i = 1, #variants do
    images[variants[i]] = {
        love.graphics.newImage("object/fish/" .. variants[i] .. "1.png"),
        love.graphics.newImage("object/fish/" .. variants[i] .. "2.png")
    }
end

local Fish = {}
Fish.__index = Fish

setmetatable(Fish, {__index = ObjectBase})


function Fish:new(objectManager, x, y, var, size)
    local variant = var or variants[math.random(1, #variants)]

    local colliders = {
        ElipticalCollider(0, 0, size*0.4 or 50, size*0.4 or 50)
    }

    local obj = ObjectBase:new(x, y, images[variant], colour, colliders)

    obj.sx = (size or 100)/(obj.ox*2)* ((math.random(1, 2) == 1 and -1) or 1)
    obj.sy = (size or 100)/(obj.ox*2) 

    obj.variant = variant
    obj.type = "Fish"

    setmetatable(obj, {
        __index = Fish,
    })

    return obj
end


function Fish:permutate()

    if math.random(1, 2) == 1 then
        self.sx = -self.sx
    else
        local newVariant = (self.variant == "yellow" and "orange") or "yellow"
        self.variant = newVariant
        self.images = images[self.variant]
    end

    self.hasMutated = true
end

return Fish