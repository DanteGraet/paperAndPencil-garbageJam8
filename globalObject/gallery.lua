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

local splash = {
    "Hope you're notes are good",
    "Take your time",
    "10 guesses max",
    "3-5 changes I think",
    'love.graphics.printf(self.splash, x, 610, 1920, "center")',
    "forghetti spaghetti",
    "last minute notes?",
    "Did you get that",
    "Geez another text",
    "Could be doin' anything else",
}


local grades = {
    {"S", 0.99},
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

    obj.splash = splash[math.random(1, #splash)]

    obj.nextCollider = RectangularCollider(65 + 1500 - 10, 65 + 5*(125+35), 305, 145)

    --photo.x + 1500 -10, photo.y + 5*(125+35) + 10

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

        audioManager.setTargets({
            always =    1,
            draw =      0,
            guess =     1,
            piano =     0.5,
            stress =    0,
        })
    end

    if self.pictures[self.currentPhoto] then
        if phase == "spotting" then
            if self.pictures[self.currentPhoto] then
                self.pictures[self.currentPhoto]:permutate()
            end
        else
            audioManager.setTargets({
                always =    1,
                draw =      1,
                guess =     0,
                piano =     1,
                stress =    0,
            })

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


        local percent = math.floor(total/#self.pictures * 100)
        local current = highscores:sub(self.difficulty, self.difficulty)
        local override = true

        for i = 1,#grades do
            if grades[i][1] == current then
                break
            end

            if total/#self.pictures >= grades[i][2] then
                -- we have not yet found a grade this good, set it as the highscore
                highscores = highscores:sub(1, self.difficulty - 1) .. grades[i][1] .. highscores:sub(self.difficulty + 1)
                break
            end
        end

        audioManager.setTargets({
            always =    0.5,
            draw =      0,
            guess =     1,
            piano =     0,
            stress =    0,
        })

        tut.generateTextList()

    else
        self.lastTimeRemaining = self.timeRemaining
        self.timeRemaining = 3 * self.timeScale
    end
end

function Gallery:mousereleased(x, y)
    if phase == "spotting" then
        if self.pictures[self.currentPhoto] then
            self.pictures[self.currentPhoto]:addToFinds(x, y)
        end
    end

    if self.currentPhoto == self.visualPhoto and self.nextCollider:checkCollision(camera:translatePosition(x, y)) then
        self:nextPhoto()
        audioManager.playSound(audio.click, 0.2)
    end
end

local dodgeFlipFlop = false
function Gallery:update(dt)
    if phase == "drawing" then
        self.timeRemaining = self.timeRemaining - dt

        if self.timeRemaining < 10 and dodgeFlipFlop == false then
            audioManager.setTargets({
                always =    0.5,
                draw =      1,
                guess =     0,
                piano =     1,
                stress =    1,
            })
            dodgeFlipFlop = true
        end
        if self.timeRemaining < 0 then 
            self:nextPhoto()
            dodgeFlipFlop = false
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


-- Holey Spaghetti Imma forghetti how this works
function Gallery:draw()
    local nextScale = (self.nextCollider:checkCollision(camera:translatePosition(love.mouse.getPosition())) and 1.2) or 1
    if love.mouse.isDown(1) and nextScale == 1.2 then  nextScale = 0.9 end

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

                love.graphics.setColor(0, 0, 0)
                fontManager.set("handwriting", 128)
                love.graphics.printf(i .. "/" .. #self.pictures, photo.x - 65*2, 65, 1920, "right")

                fontManager.set("handwriting", 38)
                love.graphics.printf("Toggle notebook (SPACE)", photo.x - 65*2, 65 + 100, 1920, "right")
                love.graphics.printf("Next page (SCROLL)", photo.x - 65*2, 65 + 100 + 38, 1920, "right")
                love.graphics.printf("Draw (LMB)", photo.x - 65*2, 65 + 100+38*2, 1920, "right")
                love.graphics.printf("Erase (RMB)", photo.x - 65*2, 65 + 100+38*3, 1920, "right")

                love.graphics.setColor(1, 1, 1)


            elseif phase == "spotting" then
                photo:drawWithScaleBonus()

                photo:drawFinds(2, photo.x + 1500, photo.y)
                local img = nextImages[clockToDraw]
                love.graphics.draw(img, photo.x + 1500 -10 + img:getWidth()/2, photo.y + 5*(125+35) + 10 + img:getHeight()/2, 0, nextScale, nextScale, img:getWidth()/2, img:getHeight()/2)
            end
        else
            local sine = tweens.sineInOut(self.visualPhoto - self.currentPhoto)
            if i == #self.pictures + 1 and i == math.ceil(self.visualPhoto) and  phase == "spotting" then
                
                self:displayScore(1920 * sine)
                love.graphics.setColor(1, 1, 1)
                local img = nextImages[clockToDraw]
                love.graphics.draw(nextImages[clockToDraw], 65 + 1500 -10 + 1920 * sine+ img:getWidth()/2, 65 + 5*(125+35) + 10+ img:getHeight()/2, 0, nextScale, nextScale, img:getWidth()/2, img:getHeight()/2)

            elseif i == #self.pictures + 2 and phase == "spotting" then
                
                love.graphics.translate(1920 * sine, 0)

                local img = nextImages[clockToDraw]
                love.graphics.draw(nextImages[clockToDraw], 65 + 1500 -10 - 1920+ img:getWidth()/2, 65 + 5*(125+35) + 10+ img:getHeight()/2, 0, nextScale, nextScale, img:getWidth()/2, img:getHeight()/2)
                self:displayScore(-1920)
                tut.draw(false)

                if sine == 0 then
                    gamestateManager.setGamestate("titleScreen")
                end
                love.graphics.translate(-1920 * sine, 0)

            else
                --love.graphics.draw(nextImages[clockToDraw], 65 + 1500 -10, 65 + 5*(125+35) + 10)
            end

            if (phase == "drawing" and i > 0) or (phase == "spotting" and i == 0) then
                fontManager.set("handwriting", 128)
                love.graphics.setColor(0, 0, 0)

                local x = sine * 1920
                if phase == "spotting" then
                    x = - (1-sine)*1920
                end

                love.graphics.printf("Spot the difference", x, 500, 1920, "center")
                fontManager.set("handwriting", 48)
                love.graphics.printf(self.splash, x, 610, 1920, "center")

                love.graphics.setColor(1, 1, 1)
                local img = nextImages[clockToDraw]
                love.graphics.draw(nextImages[clockToDraw], x + 65 + 1500 -10 + img:getWidth()/2, 65 + 5*(125+35) + 10+ img:getHeight()/2, 0, nextScale, nextScale, img:getWidth()/2, img:getHeight()/2)

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
    local percent = math.floor(total/#self.pictures * 100)

    for i = 1,#grades do
        if total/#self.pictures > grades[i][2] then
            grade = grades[i][1]
            break
        end
    end

    fontManager.set("handwriting", 150)
    love.graphics.print("Total " .. percent .. "% (" .. grade .. ")", gradeX + ox, gradeY)
end