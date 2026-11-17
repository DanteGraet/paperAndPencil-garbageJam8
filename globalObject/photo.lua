-- Photo stores multiple papers

-- I can't be bother to import quindoc yet so...
local function sign(x)
    return (x > 0 and 1) or (x < 0 and -1) or 0
end


Photo = {}
Photo.__index = Photo

fontManager.loadFont("assets/QuindocahLite.ttf", "quindocha")

setmetatable(Photo, {
    __call = function(self, x, y, level)
        return self:new(x, y, level)
    end
})


function Photo:new(x, y, level)
    local obj = {}

    obj.level = love.filesystem.load("pictures/" .. level)()
    obj.objects = {}
    obj.changes = {}

    obj.x = x
    obj.y = y

    obj.canvases = {
        love.graphics.newCanvas(1400, 950),
        love.graphics.newCanvas(1400, 950),
    }

    setmetatable(obj, {
        __index = Photo,
    })


    obj.level.loadObjects()
    obj.objects, obj.bgColour = obj.level.generateObjects()

    -- obj:render(1)
    -- obj:render(2)

    return obj
end

function Photo:getClosestObject(x, y)
    local closestIndex

    local mx, my = camera:translatePosition(x, y)
    local closest = math.huge

    for i = 1, #self.objects do
        local object = self.objects[i]
        local dx = mx - self.x - object.x
        local dy = my - self.y - object.y

        if (dx*dx)/(object.rx*object.sx*object.rx*object.sx) + (dy*dy)/(object.ry*object.sy*object.ry*object.sy) < 1 then
            -- check if it is closer (dont need sqrt here)
            local distance = dx*dx + dy*dy

            if distance < closest then
                closest = distance
                closestIndex = i
            end
        end
    end

    return closestIndex, self.objects[closestIndex]
end


function Photo:render(canvasNo, scaleHoverd)
    love.graphics.setCanvas(self.canvases[canvasNo])
    love.graphics.origin()
    love.graphics.clear(self.bgColour or {1, 1, 1})

    local scaleIndex
    local scaleBonus
    if scaleHoverd then
        scaleIndex = self:getClosestObject(love.mouse.getPosition())

        scaleBonus = (love.mouse.isDown(1) and 0.8) or 1.2
    end

    for i = 1, #self.objects do
        local object = self.objects[i]
        love.graphics.setColor(1,1,1)
        object:draw(canvasNo, (i == scaleIndex and scaleBonus) or 1)
    end

    love.graphics.setCanvas()
end


function Photo:permutate(count)
    print("MUtating")

    self.changes = self.level.permutate(self.objects, count or 3)

    self:render(1)
    self:render(2)
end


function Photo:drawWithScaleBonus()
    local canvasToDraw = math.floor((timer*5) % 2) + 1

    self:render(canvasToDraw, true)
    love.graphics.origin()
    camera()

    love.graphics.draw(self.canvases[canvasToDraw], self.x, self.y)


    -- CHEAT PLEASE REMOVE LATER
    if DEV == true and love.keyboard.isDown("lshift") then
        love.graphics.setColor(1,0, 0)
        for i = 1,#self.changes do
            local c = self.changes[i]
            love.graphics.ellipse("line", c[1], c[2], c[3], c[4])
        end
        love.graphics.setColor(1,1,1)
    end
end


function Photo:draw()
    local canvasToDraw = math.floor((timer*5) % 2) + 1
    love.graphics.draw(self.canvases[canvasToDraw], self.x, self.y)

    -- CHEAT PLEASE REMOVE LATER
    if DEV == true and love.keyboard.isDown("lshift") then
        love.graphics.setColor(1,0, 0)
        for i = 1,#self.changes do
            local c = self.changes[i]
            love.graphics.circle("line", c[1], c[2], c[3])
        end
        love.graphics.setColor(1,1,1)
    end
end