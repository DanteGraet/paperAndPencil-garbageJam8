-- Photo stores multiple papers

-- I can't be bother to import quindoc yet so...
local function sign(x)
    return (x > 0 and 1) or (x < 0 and -1) or 0
end

local frameImages = {
    love.graphics.newImage("assets/ui/frame1.png"),
    love.graphics.newImage("assets/ui/frame2.png")
}

local findImages = {
    miss = {
        love.graphics.newImage("assets/ui/finds/miss1.png"),
        love.graphics.newImage("assets/ui/finds/miss2.png"),
    },
    outline = {
        love.graphics.newImage("assets/ui/finds/correct1.png"),
        love.graphics.newImage("assets/ui/finds/correct2.png"),
    },
    incorrect = {
        love.graphics.newImage("assets/ui/finds/incorrect1.png"),
        love.graphics.newImage("assets/ui/finds/incorrect2.png"),
    },
}

local grades = {
    {"S", 1},
    {"A", 0.85},
    {"B", 0.7},
    {"C", 0.6},
    {"D", 0.5},
    {"F", 0},
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

    obj.finds = {}
    obj.findImage = math.random(1, 2)

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

function Photo:getScore()
    if #self.finds == 0 then
        return 0
    end

    -- Actually math
    local count = #self.objects
    local totalModifications = 0
    for i = 1,#self.objects do
        if self.objects[i].hasMutated == true then
            totalModifications = totalModifications + 1
        end
    end

    local foundModifications = 0
    local incorectIdentifications = 0
    for i = 1,#self.finds do
        local find = self.objects[self.finds[i][1]]

        if self.finds[i][2] == "miss" then

        else
            if find.hasMutated == true then
                foundModifications = foundModifications + 1
            else
                incorectIdentifications = incorectIdentifications + 1
            end
        end
    end

    local foundPortion = foundModifications / totalModifications
    local wrongPortion = incorectIdentifications / (count - totalModifications)

    local score = (foundPortion / 2 + 0.5) * (1 - wrongPortion)


    return score
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


function Photo:addToFinds(x, y)
    local mx, my = camera:translatePosition(x, y)
    local index, object = self:getClosestObject(x, y)

    for i = 1, #self.finds do
        if self.finds[i][1] == index then
            return
        end
    end

    if index then
        local outline = "incorrect"

        if object.hasMutated == true then
            outline = "correct"
        end

        local t = {index, outline}
        print("adding iFind")

        table.insert(self.finds, t)
    end

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

function Photo:drawFinds()
    local canvasToDraw = math.floor(((timer*5) + self.findImage) % 2) + 1

    love.graphics.setLineWidth(4)
    if #self.finds == 0 then return end

    for i = 1, #self.finds do
        local x = self.x + 1500 + (125+35)*((i-1) % 2)
        local y = self.y + math.floor((i-1)/2)*(125+35)

        local object = self.objects[self.finds[i][1]]
        local image = object.images[canvasToDraw]

        local scale = math.min(125/image:getWidth(), 125/image:getHeight())

        if self.finds[i][2] == "correct" then

        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        love.graphics.draw(findImages.outline[canvasToDraw], x - 10, y - 10)

        love.graphics.draw(image, x, y, 0, scale, scale)

        love.graphics.setColor(1, 1, 1)


        if findImages[self.finds[i][2]] then
            love.graphics.draw(findImages[self.finds[i][2]][canvasToDraw], x - 10, y - 10)

        end
    end

    -- We aint drawing this anyumore
    -- fontManager.set("quindocha", 128)
    -- love.graphics.setColor(0, 0, 0)

    -- local letter
    -- local score = self:getScore()
    -- for i = 1,#grades do
    --     if score > grades[i][2] then
    --         letter = grades[i][1]
    --         break
    --     end
    -- end

    -- love.graphics.print(letter, self.x + 1500, self.y + 850)
end