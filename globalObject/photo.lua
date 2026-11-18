-- Photo stores multiple papers

-- I can't be bother to import quindoc yet so...
local function sign(x)
    return (x > 0 and 1) or (x < 0 and -1) or 0
end

local frameImages = {
    love.graphics.newImage("assets/ui/frame1.png"),
    love.graphics.newImage("assets/ui/frame2.png")
}

local frameColours = {
    {1, 1, 1},
    {0, 1, 1},
    {1, 0, 1},
    {1, 1, 0},
    {0, 0, 1},
    {1, 0, 0},
    {0, 1, 0},
    {0, 0, 0},

    {104/255, 171/255, 197/255},    -- jaraph blud
    {54/255, 1/255, 63/255},        -- purple
}

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

    obj.frameColour = frameColours[math.random(1, #frameColours)]

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

        local x, y = mx - self.x - object.x, my - self.y - object.y

        if object.colliders then
            for j = 1,#object.colliders do
                local collision, distance = object.colliders[j]:checkCollision(x, y)

                if collision and distance < closest then
                    closest = distance
                    closestIndex = i
                end
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


function Photo:drawDebug()
    -- CHEAT PLEASE REMOVE LATER
    if DEV == true and love.keyboard.isDown("lshift") then

        for i = 1, #self.objects do
            local object = self.objects[i]

            if object.hasMutated == true then
                love.graphics.setColor(1,0,0)
            else
                love.graphics.setColor(0,0,1)
            end

            if object.colliders then
                for j = 1,#object.colliders do
                    object.colliders[j]:draw(object.x + object.ox, object.y + object.oy)
                end
            end
        end
    end
end

function Photo:drawWithScaleBonus()
    local canvasToDraw = math.floor((timer*5) % 2) + 1

    self:render(canvasToDraw, true)
    love.graphics.origin()
    camera()

    love.graphics.draw(self.canvases[canvasToDraw], self.x, self.y)

    love.graphics.setColor(self.frameColour)
    love.graphics.draw(frameImages[canvasToDraw], self.x - 50, self.y - 50)
    love.graphics.setColor(1,1,1)

    self:drawDebug()
end


function Photo:draw()
    local canvasToDraw = math.floor((timer*5) % 2) + 1
    love.graphics.draw(self.canvases[canvasToDraw], self.x, self.y)


    love.graphics.setColor(self.frameColour)
    love.graphics.draw(frameImages[canvasToDraw], self.x - 50, self.y - 50)
    love.graphics.setColor(1,1,1)

    self:drawDebug()
end