local variants = {
    "a", "b",
    "c", "e",
    "d", "f",
}

local colours = {
    {147/255, 75/255, 60/255},
    {213/255, 181/255, 143/255},
    {171/255, 157/255, 144/255},
    {229/255, 224/255, 213/255},
    {129/255, 129/255, 126/255},
    {96/255, 97/255, 108/255},
}

local images = {}
for i = 1, #variants do
    images[variants[i]] = {
        love.graphics.newImage("object/building/" .. variants[i] .. "1.png"),
        love.graphics.newImage("object/building/" .. variants[i] .. "2.png")
    }
end

local Building = {}
Building.__index = Building

setmetatable(Building, {__index = ObjectBase})


function Building:new(x, y)
    local variant = variants[math.random(1, #variants)]


    local obj = ObjectBase:new(x, y, images[variant], colour, colliders)

    
    obj.variant = variant
    obj.type = "Building"
    obj.colour = colours[math.random(1, #colours)]

    obj.oy = obj.images[1]:getHeight()

    obj.colliders = {RectangularCollider(-obj.ox, -obj.oy, obj.images[1]:getWidth(), obj.images[1]:getHeight())}

    setmetatable(obj, {
        __index = Building,
    })

    return obj, extra
end


function Building:permutate()
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

    self.colliders = {RectangularCollider(-self.ox, -self.oy, self.images[1]:getWidth(), self.images[1]:getHeight())}

    self.hasMutated = true
end

return Building