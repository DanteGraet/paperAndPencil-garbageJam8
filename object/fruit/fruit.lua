local variants = {
    "apple",
    "banana",
    "cherry",
    "grape",
    "tomato",
    "strawberry",
    "pineapple",
    "lemon",
    "mango",
    "watermelon",
    "dragonfruit",
}

local images = {}
for i = 1, #variants do
    images[variants[i]] = {
        love.graphics.newImage("object/fruit/" .. variants[i] .. "1.png"),
        love.graphics.newImage("object/fruit/" .. variants[i] .. "2.png")
    }
end

local ChessPiece = {}
ChessPiece.__index = ChessPiece

setmetatable(ChessPiece, {__index = ObjectBase})


function ChessPiece:new(x, y, var)
    local variant = var or variants[math.random(1, #variants)]
    local obj = ObjectBase:new(x, y, rx, ry, images[variant], colour)

    obj.variant = variant
    obj.type = "ChessPiece"

    setmetatable(obj, {
        __index = ChessPiece,
    })

    return obj
end


function ChessPiece:permutate()
    local varIdx = math.random(1, #variants)
    local newVariant = variants[varIdx]

    if newVariant == self.variant then
        varIdx = varIdx - 1
        if varIdx == 0 then varIdx = #variants-1 end -- um no jaraph from varswappin or somethin

        newVariant = variants[varIdx]
    end

    self.variant = newVariant
    self.images = images[self.variant]

    -- return where the change happend and radii
    return {self.x + self.ox, self.y + self.oy, self.rx * self.sx, self.ry * self.sy}
end

return ChessPiece