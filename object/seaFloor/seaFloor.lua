local variants = {
    "coral", "shortgrass", "tallGrass", "rock"
}

local images = {}
for i = 1, #variants do
    images[variants[i]] = {
        love.graphics.newImage("object/seaFloor/" .. variants[i] .. "1.png"),
        love.graphics.newImage("object/seaFloor/" .. variants[i] .. "2.png")
    }
end

local SeaFloor = {}
SeaFloor.__index = SeaFloor

setmetatable(SeaFloor, {__index = ObjectBase})


function SeaFloor:new(objectManager, x, y, scale)
    local variant = variants[math.random(1, #variants)]


    local obj = ObjectBase:new(x, y, images[variant], colour, colliders)

    
    obj.variant = variant
    obj.type = "SeaFloor"

    obj.oy = obj.images[1]:getHeight()

    obj.sx, obj.sy = (scale or 2), (scale or 2)

    obj.colliders = {RectangularCollider(-obj.ox, -obj.oy*2, obj.images[1]:getWidth() * scale, obj.images[1]:getHeight()* scale)}

    setmetatable(obj, {
        __index = SeaFloor,
    })

    return obj, extra
end

function SeaFloor:drawFind(wobble, x, y, w, h, scale, isCorrect)
    love.graphics.draw(self.images[wobble], x + 25/2 + 50, y + h, 0, scale, scale, self.images[1]:getWidth()/2, self.images[1]:getHeight())
end

function SeaFloor:permutate()
    local varIdx = math.random(1, #variants)
    local newVariant = variants[varIdx]

    if newVariant == self.variant then
        varIdx = varIdx - 1
        if varIdx == 0 then varIdx = #variants-1 end -- um no jaraph from varswappin or somethin

        newVariant = variants[varIdx]
    end

    self.variant = newVariant
    self.images = images[self.variant]
    self.oy = self.images[1]:getHeight()

    self.ox = self.images[1]:getWidth()/2

    self.colliders = {RectangularCollider(-self.ox, -self.oy*2, self.images[1]:getWidth() * self.sx, self.images[1]:getHeight() * self.sy)}

    self.hasMutated = true
end

return SeaFloor