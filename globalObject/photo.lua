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
    unknown = {
        love.graphics.newImage("assets/ui/finds/unknown1.png"),
        love.graphics.newImage("assets/ui/finds/unknown2.png"),
    },
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

    obj.outOfGuesses = -1

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
    local totalModifications = 0
    for i = 1,#self.objects do
        if self.objects[i].hasMutated == true then
            totalModifications = totalModifications + 1
        end
    end

    if #self.finds == 0 then
        return 0.000001, totalModifications   -- 000001 cause yea
    end

    -- Actually math
    local count = #self.objects


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

    -- so this does mean its better to guess once when you got no idea but idk how to fix that
    local score = (foundPortion / 2 + 0.5) * (1 - wrongPortion)


    return score, (totalModifications - foundModifications), totalModifications
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

                if collision and distance <= closest then
                    closest = distance
                    closestIndex = i
                end
            end
        end
    end

    return closestIndex, self.objects[closestIndex]
end


function Photo:addToFinds(x, y)
    if self.outOfGuesses >= 0 then
        return
    end

    if #self.finds >= 10 then
        -- Play Sound
        audioManager.playSound(audio.click, 0.2)
        return
    end

    local mx, my = camera:translatePosition(x, y)
    local index, object = self:getClosestObject(x, y)

    for i = 1, #self.finds do
        if self.finds[i][1] == index then
            audioManager.playSound(audio.click, 0.2)
            return
        end
    end

    if index then
        local outline = "incorrect"

        if object.hasMutated == true then
            object.found = true
            outline = "correct"
            self.missingMutations = self.missingMutations - 1
        else
            if #self.finds + self.missingMutations >= 10 then
                self.outOfGuesses = 0
                audioManager.playSound(audio.incorrect, 0.2)

                return
            end
        end

        audioManager.playSound(audio[outline], 0.2)

        local t = {index, outline}

        table.insert(self.finds, t)

        if self.missingMutations == 0 then
            self.outOfGuesses = 0
        end
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


function Photo:permutate()
    self.level.permutate(self.objects)
    
    local c = 0
    for i = 1,#self.objects do
        if self.objects[i].hasMutated then
            c = c + 1
        end
    end

    -- none of these are found
    self.missingMutations = c
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

    self:render(canvasToDraw, self.outOfGuesses < 0)
    love.graphics.origin()
    camera()

    love.graphics.draw(self.canvases[canvasToDraw], self.x, self.y)

    if self.outOfGuesses > 0 then
        love.graphics.setColor(1, 1, 1, tweens.sineInOut(self.outOfGuesses)/2)
        love.graphics.rectangle("fill", self.x, self.y, 1400, 950)
        love.graphics.setColor(0, 0, 0, tweens.sineInOut(math.min(self.outOfGuesses*2, 1)))
        fontManager.set("handwriting", 128)

        local text = "Out of Guesses"
        if self.missingMutations == 0 then
            text = "All Changes Found"
        end
        love.graphics.printf(text, self.x, 600 - tweens.sineInOut(math.min(self.outOfGuesses*2, 1))*50, 1400, "center")
    end

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

function Photo:update(dt, gal)
    if self.outOfGuesses >= 0 then
        self.outOfGuesses = math.min(self.outOfGuesses + dt, 1)

        if self.outOfGuesses == 1 then
            gal:nextPhoto()
        end
    end
end

function Photo:drawFinds(col, ox, oy, drawMissing)
    local canvasToDraw = math.floor(((timer*5) + self.findImage) % 2) + 1

    -- love.graphics.draw(nextImages[canvasToDraw], self.x + 1500 -10, self.y + 5*(125+35) + 10)


    love.graphics.setLineWidth(4)
    --if #self.finds == 0 then return end


    for i = 1, #self.finds do
        local x = ox + (125+35)*((i-1) % col)
        local y = oy + math.floor((i-1)/col)*(125+35) + 10

        local object = self.objects[self.finds[i][1]]
        local image = (object.images and object.images[canvasToDraw]) or nil
        
        local scale = (image and math.min(125/image:getWidth(), 125/image:getHeight())) or 0

        if self.finds[i][2] == "correct" then

        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end

        love.graphics.draw(findImages.outline[canvasToDraw], x - 10, y - 10)

        if image then
            love.graphics.draw(image, x, y, 0, scale, scale)
        end

        love.graphics.setColor(1, 1, 1)


        if findImages[self.finds[i][2]] then
            love.graphics.draw(findImages[self.finds[i][2]][canvasToDraw], x - 10, y - 10)
        end
    end

    if not drawMissing then
        love.graphics.setColor(1, 1, 1)
        for j = 1, self.missingMutations do
            local i = j + #self.finds

            local x = ox + (125+35)*((i-1) % col)
            local y = oy + math.floor((i-1)/col)*(125+35) + 10


            love.graphics.draw(findImages.outline[canvasToDraw], x - 10, y - 10)
            love.graphics.draw(findImages.unknown[canvasToDraw], x - 10, y - 10)
        end
    else
        local current = 1
        for j = 1, self.missingMutations do
            local i = j + #self.finds

            local x = ox + (125+35)*((i-1) % col)
            local y = oy + math.floor((i-1)/col)*(125+35) + 10


            local object
            for i = current, #self.objects do
                if self.objects[i].hasMutated and not self.objects[i].found then
                    object = self.objects[i]

                    current = i+1
                    break

                end
            end


            local image = (object.images and object.images[canvasToDraw]) or nil
            
            local scale = (image and math.min(125/image:getWidth(), 125/image:getHeight())) or 0

            love.graphics.setColor(0.5, 0.5, 0.5)

            love.graphics.draw(findImages.outline[canvasToDraw], x - 10, y - 10)

            if image then

                love.graphics.draw(image, x, y, 0, scale, scale)
            end
            love.graphics.setColor(1, 1, 1)

            love.graphics.draw(findImages.miss[canvasToDraw], x - 10, y - 10)

        end
    end



    -- Draw the next button also shhhh

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