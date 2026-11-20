local variants = {
    "r", "s",
}

local colours = {
    {.7, 0.4, 0.4},
    {.3, .7, .7},
    {.6, .3, .7},
    {.5, 0.4, 0.5},
    {.2, .7, .6},
    {.4, .8, .7},
    {.4, .8, .2},
}

local images = {}
for i = 1, #variants do
    images[variants[i]] = {
        love.graphics.newImage("object/frame/" .. variants[i] .. "1.png"),
        love.graphics.newImage("object/frame/" .. variants[i] .. "2.png")
    }
end

local PhotoFrame = {}
PhotoFrame.__index = PhotoFrame

setmetatable(PhotoFrame, {__index = ObjectBase})


function PhotoFrame:new(x, y)
    local variant = variants[math.random(1, #variants)]

    local colliders = {
        RectangularCollider(-110, -160, 220, 320)
    }

    local obj = ObjectBase:new(x, y, images[variant], colour, colliders)

    
    obj.variant = variant
    obj.type = "PhotoFrame"
    obj.r = 0

    obj.colour = colours[math.random(1, #colours)]

    setmetatable(obj, {
        __index = PhotoFrame,
    })

    local extra = {
        objectManager.getRandom("full"):new(x, y, nil, 150)
    }

    return obj, extra
end


function PhotoFrame:permutate()
    local varIdx = math.random(1, #variants)
    local newVariant = (self.variant == "s" and "r") or "s"

    if newVariant == self.variant then
        crash()
    end

    self.variant = newVariant
    self.images = images[self.variant]

    self.hasMutated = true
end

return PhotoFrame