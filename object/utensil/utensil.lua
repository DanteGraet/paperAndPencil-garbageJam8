local variants = {
    "cleaver",  "knife",
    "spoon",  "spatula",
    "pin",

}

local images = {}
for i = 1, #variants do
    images[variants[i]] = {
        love.graphics.newImage("object/utensil/" .. variants[i] .. "1.png"),
        love.graphics.newImage("object/utensil/" .. variants[i] .. "2.png")
    }
end

local Utensil = {}
Utensil.__index = Utensil

setmetatable(Utensil, {__index = ObjectBase})


function Utensil:new(objectManager, x, y, var)
    local variant = var or variants[math.random(1, #variants)]

    local r = images[variant][1]:getWidth()
    local colliders = {
        ElipticalCollider(0, 0, r, r)
    }

    local obj = ObjectBase:new(x, y, images[variant], nil, colliders)

    obj.variant = variant
    obj.type = "Utensil"

    obj.sx = obj.sx * 3
    obj.sy = obj.sy * 3

    obj.r = math.random() * math.pi * 2


    setmetatable(obj, {
        __index = Utensil,
    })

    return obj
end

function Utensil:brandNewVariant()
    local varIdx = math.random(1, #variants)
    local newVariant = variants[varIdx]

    if newVariant == self.variant then
        varIdx = varIdx - 1
        if varIdx == 0 then varIdx = #variants-1 end

        newVariant = variants[varIdx]

    end

    self.r = math.random() * math.pi * 2

    self.variant = newVariant

    self.images = images[self.variant]
end


function Utensil:permutate()
    self:brandNewVariant() -- dont even mess with rotations for these ones

    self.hasMutated = true
end

return Utensil