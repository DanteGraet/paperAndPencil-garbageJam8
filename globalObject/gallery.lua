Gallery = {}
Gallery.__index = Gallery

local frameImages = {
    love.graphics.newImage("assets/ui/frame1.png"),
    love.graphics.newImage("assets/ui/frame2.png")
}

local nextImages = {
    love.graphics.newImage("assets/ui/next1.png"),
    love.graphics.newImage("assets/ui/next2.png")
}


local grades = {
    {"S", 1},
    {"A", 0.85},
    {"B", 0.7},
    {"C", 0.6},
    {"D", 0.5},
    {"F", 0},
}

local clockImages = {
    clock = {
        love.graphics.newImage("assets/ui/clock1.png"),
        love.graphics.newImage("assets/ui/clock2.png"),
    },
    hand = {
        love.graphics.newImage("assets/ui/hand1.png"),
        love.graphics.newImage("assets/ui/hand2.png"),
    }
}

setmetatable(Gallery, {
    __call = function(self, size, timeScale, difficulty)
        return self:new(size, timeScale, difficulty)
    end
})


function Gallery:new(size, timeScale, difficulty)
    math.randomseed(os.time(), love.timer.getTime())

    local obj = {}

    local pictureTypes = love.filesystem.getDirectoryItems("pictures")
    obj.pictures = {}
    for i = 1, size do
        local n = math.random(1, #pictureTypes)
        local picture = Photo(65 + 1920*(i-1), 65, pictureTypes[n])

        table.insert(obj.pictures, picture)

        if #pictureTypes > 1 then
            table.remove(pictureTypes, i)
        end
        -- remove the picture type later TODO
    end

    obj.currentPhoto = 1
    obj.visualPhoto = 0
    obj.visualPhotoSine = 0

    obj.timeScale = timeScale or 1
    obj.difficulty = difficulty

    setmetatable(obj, {
        __index = Gallery,
    })

    obj.timeRemaining = ((obj.pictures[obj.currentPhoto] and obj.pictures[obj.currentPhoto].level.time) or 60) * obj.timeScale
    obj.lastTimeRemaining = 0
    
    obj:render()
    

    --[[
        1400 x  950
        140     95          - / 10
        560     380         - * 4
        1120                - * 2
        1170                - + 50  (spacing)
        1210                - + 40 (boarderr o 15)

        
    ]]
    -- local height = (380 + 50) * #obj.pictures - 50 + 40
    -- obj.resultsY = (1080-850)/2
    -- obj.resultsX = (1080-850)/2
    -- obj.resultsCanvas = {
    --     love.graphics.newCanvas(1210, height),
    --     love.graphics.newCanvas(1210, height)
    -- }

    phase = "drawing"

    return obj
end

function Gallery:render(pictureNo)
    local no = pictureNo or self.currentPhoto

    if self.pictures[no] then
        self.pictures[no]:render(1)
        self.pictures[no]:render(2)
    end
end

function Gallery:nextPhoto()
    -- if self.pictures[self.currentPhoto] then
    --     local photo = self.pictures[self.currentPhoto]
    --     local spacing = 50
    --     local totalPhotoWidth = (280 + spacing) * #self.pictures - spacing

    --     local x = 20 + ((phase == "spotting" and 1400 * 4/10 + 50) or 0)
    --     local y = 20 + (380 + 50) * (self.currentPhoto - 1)

    --     love.graphics.origin()
    --     love.graphics.setCanvas(self.resultsCanvas[1])
    --     love.graphics.draw(photo.canvases[1], x, y, 0, 4/10, 4/10)

    --     love.graphics.setColor(photo.frameColour)
    --     love.graphics.draw(frameImages[1], x - 50*4/10, y - 50*4/10, 0, 4/10, 4/10)

    --     love.graphics.setCanvas(self.resultsCanvas[2])
    --     love.graphics.draw(photo.canvases[2], x, y, 0, 4/10, 4/10)
    --     love.graphics.setColor(photo.frameColour)
    --     love.graphics.draw(frameImages[1], x - 50*4/10, y - 50*4/10, 0, 4/10, 4/10)

    --     love.graphics.setCanvas()
    -- end

    self.currentPhoto = self.currentPhoto + 1
    self:render()


    if self.currentPhoto > #self.pictures + 1 and phase ~= "spotting" then
        phase = "spotting"
        self.currentPhoto = 1
        self.visualPhoto = 0
    end

    if self.pictures[self.currentPhoto] then
        if phase == "spotting" then
            if self.pictures[self.currentPhoto] then
                self.pictures[self.currentPhoto]:permutate()
            end
        else
            self.lastTimeRemaining = self.timeRemaining
            self.timeRemaining = (self.pictures[self.currentPhoto].level.time or 60) * self.timeScale
        end

    elseif phase == "spotting" then
        -- Save to highscore
        local total = 0
        for i = 1,#self.pictures do
            local photo = self.pictures[i]
            local score, miss, totalMods = photo:getScore()
            total = total + score
        end


        local percent = math.floor(total/3 * 100)
        local current = highscores:sub(self.difficulty, self.difficulty)
        local override = true

        for i = 1,#grades do
            if grades[i][1] == current then
                break
            end

            if total/3 >= grades[i][2] then
                -- we have not yet found a grade this good, set it as the highscore
                highscores = highscores:sub(1, self.difficulty - 1) .. grades[i][1] .. highscores:sub(self.difficulty + 1)
                break
            end
        end

        tut.generateTextList()
    end
end

function Gallery:mousereleased(x, y)
    if phase == "spotting" then
        if self.pictures[self.currentPhoto] then
            self.pictures[self.currentPhoto]:addToFinds(x, y)
        end
    end
end

function Gallery:update(dt)
    if phase == "drawing" then
        self.timeRemaining = self.timeRemaining - dt
        if self.timeRemaining < 0 then 
            self:nextPhoto()
        end
    end

    -- in thoeryu thus works cause current photo dont go down
    if self.visualPhoto < self.currentPhoto then
        self.visualPhoto = math.min(self.visualPhoto + dt, self.currentPhoto)

        self.visualPhotoSine = math.floor(self.visualPhoto) + tweens.sineInOut(self.visualPhoto % 1)

        for i = 1, #self.pictures do
            local photo = self.pictures[i]
            photo.x = 65 - (self.visualPhotoSine-i)*1920
        end
    end


    -- edge case haha
    if self.visualPhoto < 1 and phase == "spotting" then
        local photo = self.pictures[#self.pictures]
        photo.x = 65 - (self.visualPhotoSine)*1920
    end
end


function Gallery:draw()
    local clockToDraw = math.floor((timer*5) % 2) + 1

    for i = math.floor(self.visualPhoto), math.ceil(self.visualPhoto) do
        local photo = self.pictures[i]

        -- if i == 0 and phase == "spotting" then
        --     photo = self.pictures[#self.pictures]
        -- end

        if photo then
            if phase == "drawing" or i == 0 then
                photo:draw()

                local time = (i ~= self.currentPhoto and self.lastTimeRemaining) or self.timeRemaining
                local angle = time/60*math.pi*2 - math.pi/2
                
                local c = 0
                local ox, oy = 0, 0 
                if time < 10 then
                    c = (1-time/10)/2
                end

                if time < 5 then
                    local r = math.random() * math.pi * 2
                    local d = math.random() * (5-time)
                    ox = math.cos(r)*d
                    oy = math.sin(r)*d
                end
                love.graphics.setColor(0+c, 0, 0)
                love.graphics.draw(clockImages.clock[clockToDraw], photo.x + 1400+100 + ox, 1030 - 367 + oy)
                love.graphics.draw(clockImages.hand[clockToDraw], photo.x +305/2 + 1400+100 +ox, 1030 - 367+214.5+oy, angle, 1, 1, 305/2, 214.5)
                love.graphics.setColor(1, 1, 1)

            elseif phase == "spotting" then
                photo:drawWithScaleBonus()

                photo:drawFinds(2, photo.x + 1500, photo.y)
                love.graphics.draw(nextImages[clockToDraw], photo.x + 1500 -10, photo.y + 5*(125+35) + 10)
            end
        else
            if i == #self.pictures + 1 and i == math.ceil(self.visualPhoto) and  phase == "spotting" then
                local sine = tweens.sineInOut(self.visualPhoto - self.currentPhoto)
                self:displayScore(1920 * sine)
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(nextImages[clockToDraw], 65 + 1500 -10 + 1920 * sine, 65 + 5*(125+35) + 10)

            elseif i == #self.pictures + 2 and phase == "spotting" then
                local sine = tweens.sineInOut(self.visualPhoto - self.currentPhoto)
                love.graphics.translate(1920 * sine, 0)

                love.graphics.draw(nextImages[clockToDraw], 65 + 1500 -10 - 1920, 65 + 5*(125+35) + 10)
                self:displayScore(-1920)
                tut.draw(false)

                if sine == 0 then
                    gamestateManager.setGamestate("titleScreen")
                end
                love.graphics.translate(-1920 * sine, 0)

            else
                --love.graphics.draw(nextImages[clockToDraw], 65 + 1500 -10, 65 + 5*(125+35) + 10)
            end
        end
    end
end

function Gallery:displayScore(ox)
    local total = 0

    for i = 1,#self.pictures do
        love.graphics.setColor(1, 1, 1)

        local photo = self.pictures[i]
        local y = photo.y + (125+35) * (i-1)
        local x = (65)
        local maX = #photo.finds * (125+35) + 65

        photo:drawFinds(15, x + ox, y)

        love.graphics.setColor(0, 0, 0)

        fontManager.set("handwriting", 125)
        local score, miss, totalMods = photo:getScore()
        love.graphics.print(math.floor(score *100) .. "%", maX + ox, y)

        fontManager.set("handwriting", 50)
        love.graphics.print((miss or totalMods) .. " missed!", maX + ox, y + 90)

        total = total + score
    end

    local gradeX = 65
    local gradeY = 65 + (125+35) * (5)
    local grade = "-"
    local percent = math.floor(total/3 * 100)

    for i = 1,#grades do
        if total/3 > grades[i][2] then
            grade = grades[i][1]
            break
        end
    end

    fontManager.set("handwriting", 150)
    love.graphics.print("Total " .. percent .. "% (" .. grade .. ")", gradeX + ox, gradeY)
end