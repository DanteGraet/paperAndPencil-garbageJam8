local variants = {
    "small",  "large",
    "pot",  "kettle"

}

local images = {}
for i = 1, #variants do
    images[variants[i]] = {
        love.graphics.newImage("object/stoveTop/" .. variants[i] .. "1.png"),
        love.graphics.newImage("object/stoveTop/" .. variants[i] .. "2.png")
    }
end

local StoveTop = {}
StoveTop.__index = StoveTop

setmetatable(StoveTop, {__index = ObjectBase})


function StoveTop:new(x, y, var)
    local variant = var or variants[math.random(1, #variants)]

    local r = images[variant][1]:getWidth()/2
    local colliders = {
        ElipticalCollider(0, 0, r * 0.9, r * 0.9)
    }

    local obj = ObjectBase:new(x, y, images[variant], nil, colliders)


    obj.variant = variant
    obj.type = "StoveTop"

    obj.r = math.random() * math.pi * 2

    local extra = {}
    if obj.variant == "pot" then
        obj.items = math.random(0, 3)
        local r = math.random() * math.pi * 2

        for i = 1, obj.items do
            local xPos, yPos = x + math.cos(r + math.random()/3) * 50, y + math.sin(r + math.random()/3) * 50

            local bonus = objectManager.get("fruit"):new(xPos, yPos, nil, 150)

            bonus.r = math.random() * math.pi * 2
            if obj.items ~= 0 then      -- prevent a div 0
                r = r + math.pi * 2 / obj.items
            end

            table.insert(extra, bonus)
        end

        if obj.items == 0 then
            obj.items = nil
        end
    end


    setmetatable(obj, {
        __index = StoveTop,
    })

    return obj, extra
end

function StoveTop:brandNewVariant()
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
    local r = images[self.variant][1]:getWidth()/2

    self.ox = r
    self.oy = r

    self.colliders = { ElipticalCollider(0, 0, r * 0.9, r * 0.9) }
end


function StoveTop:permutate()


    if self.variants == "small" or self.variants == "large" then
        self:brandNewVariant()
    else
        if not self.items and math.random(1, 3) == 1 then
            self:brandNewVariant()
        elseif self.variant == "pot" then
            self.r = self.r + math.pi/4 + math.random() * math.pi/2
        elseif self.variant == "kettle" then
            self.r = self.r + math.pi/4 + math.random() * math.pi*3/2
        else
            self:brandNewVariant()
        end
    end



    self.hasMutated = true
end

return StoveTop