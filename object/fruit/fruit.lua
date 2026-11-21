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


function ChessPiece:new(x, y, var, size)
    local variant = var or variants[math.random(1, #variants)]

    local colliders = {
        ElipticalCollider(0, 0, size*0.4 or 50, size*0.4 or 50)
    }

    local obj = ObjectBase:new(x, y, images[variant], colour, colliders)

    obj.sx = (size or 100)/(obj.ox*2)
    obj.sy = (size or 100)/(obj.ox*2)

    obj.variant = variant
    obj.type = "Fruit"

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

    self.hasMutated = true
end

return ChessPiece