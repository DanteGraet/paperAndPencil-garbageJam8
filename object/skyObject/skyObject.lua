local variants = {
    "ca",  "cb",   "cc",        -- clouds

}

local images = {}
for i = 1, #variants do
    images[variants[i]] = {
        love.graphics.newImage("object/skyObject/" .. variants[i] .. "1.png"),
        love.graphics.newImage("object/skyObject/" .. variants[i] .. "2.png")
    }
end

local SkyObject = {}
SkyObject.__index = SkyObject

setmetatable(SkyObject, {__index = ObjectBase})


function SkyObject:new(objectManager, x, y, var)
    local variant = var or variants[math.random(1, #variants)]

    local colliders = {
        ElipticalCollider(0, 0, 324/2, 179/2)
    }

    local obj = ObjectBase:new(x, y, images[variant], colour, colliders)


    obj.variant = variant
    obj.type = "SkyObject"

    if math.random(1, 10) == 1 then
        obj.variant = "blank"
    end

    setmetatable(obj, {
        __index = SkyObject,
    })

    return obj
end


function SkyObject:permutate()
    local varIdx = math.random(1, #variants)
    local newVariant = variants[varIdx]

    if newVariant == self.variant then
        varIdx = varIdx - 1
        if varIdx == 0 then varIdx = #variants-1 end -- um no jaraph from varswappin or somethin

        newVariant = variants[varIdx]
    end

    self.variant = newVariant
    self.images = images[self.variant]

    if math.random(1, 10) == 1 then
        self.variant = "blank"
    end

    self.hasMutated = true
end

return SkyObject