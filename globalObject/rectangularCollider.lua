RectangularCollider = {}
RectangularCollider.__index = RectangularCollider


setmetatable(RectangularCollider, {
    __call = function(self, x, y, sx, sy)
        return self:new(x, y, sx, sy)
    end
})


function RectangularCollider:new(x, y, sx, sy)
    local obj = {}

    obj.x = x
    obj.y = y
    obj.sx =  sx or 100
    obj.sy = sy or 100

    setmetatable(obj, {
        __index = RectangularCollider,
    })

    return obj
end

function RectangularCollider:checkCollision(x, y)
    local collision = false
    local distance = math.huge

    local dx = x - (self.x + self.sx/2)
    local dy = y - (self.y + self.sy/2)

    if x > self.x and x < self.x + self.sx and y > self.y and y < self.y + self.sy then
        distance = math.sqrt(dx*dx + dy*dy)
        collision = true
    end
    
    return collision, distance 
end

function RectangularCollider:draw(ox, oy)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", self.x + ox, self.y + oy, self.sx, self.sy)
end