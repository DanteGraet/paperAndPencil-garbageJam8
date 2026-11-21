local variants = {
    "2d",
    "3d",
    "2l",
    "3l",
}

local images = {
    frame = {love.graphics.newImage("object/window/" .. "frame" .. "1.png"),
    love.graphics.newImage("object/window/" .. "frame" .. "2.png")}
}
for i = 1, #variants do
    images[variants[i]] = {
        love.graphics.newImage("object/window/" .. variants[i] .. "1.png"),
        love.graphics.newImage("object/window/" .. variants[i] .. "2.png")
    }
end

local Window = {}
Window.__index = Window

setmetatable(Window, {__index = ObjectBase})


function Window:new(objectManager, x, y, var)
    local variant = var or variants[math.random(1, #variants)]

    local colliders = {
        RectangularCollider(-150, -150, 300, 300)
    }

    local obj = ObjectBase:new(x, y, images[variant], colour, colliders)

    obj.variant = variant
    obj.type = "Window"

    setmetatable(obj, {
        __index = Window,
    })

    return obj
end


function Window:permutate()
    local varIdx = math.random(1, #variants)
    local newVariant = variants[varIdx]

    if newVariant == self.variant then
        varIdx = varIdx - 1
        if varIdx == 0 then varIdx = #variants-1 end -- um no jaraph from varswappin or somethin

        newVariant = variants[varIdx]
    end

    self.variant = newVariant
    self.images = images[self.variant]

    self.hasMutated = true
end


function Window:draw(imageNo, scaleBonus)
    local image = self.images[imageNo or 1]

    love.graphics.setColor(self.colour or {1,1,1})
    love.graphics.draw(image, self.x, self.y, self.r, self.sx * (scaleBonus or 1), self.sy * (scaleBonus or 1), self.ox, self.oy)
    love.graphics.draw(images["frame"][imageNo or 1], self.x, self.y, self.r, self.sx * (scaleBonus or 1), self.sy * (scaleBonus or 1), self.ox, self.oy)
end

return Window