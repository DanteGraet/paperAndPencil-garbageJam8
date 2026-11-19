ElipticalCollider = {}
ElipticalCollider.__index = ElipticalCollider


setmetatable(ElipticalCollider, {
    __call = function(self, x, y, rx, ry)
        return self:new(x, y, rx, ry)
    end
})


function ElipticalCollider:new(x, y, rx, ry)
    local obj = {}

    obj.x = x
    obj.y = y
    obj.rx =  rx or 100
    obj.ry = ry or 100

    setmetatable(obj, {
        __index = ElipticalCollider,
    })

    return obj
end

function ElipticalCollider:checkCollision(x, y)
    local collision = false
    local distance = math.huge


    local dx = x - self.x
    local dy = y - self.y

    if (dx*dx)/(self.rx*self.rx) + (dy*dy)/(self.ry*self.ry) < 1 then
        -- check if it is closer (dont need sqrt here)
        distance = math.sqrt(dx*dx + dy*dy)
        collision = true
    end
    
    return collision, distance 
end

function ElipticalCollider:draw(ox, oy)
    love.graphics.ellipse("line", self.x + ox, self.y + oy, self.rx, self.ry)
end