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
    -- "Hope you're notes are good",
    -- "Take your time",
    -- "10 guesses max",
    -- "3-5 changes I think",
    -- 'love.graphics.printf(self.splash, x, 610, 1920, "center")',
    -- "forghetti spaghetti",
    -- "last minute notes?",
    -- "Did you get that",
    -- "Geez another text",
    -- "Could be doin' anything else",
    "Click the objects that have changed",
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
    },
    background = love.graphics.newImage("assets/ui/clock3.png"),
}

setmetatable(Gallery, {
    __call = function(self, size, timeScale, difficulty)
        return self:new(size, timeScale, difficulty)
    end
})

local function getPictureTypes(difficulty)
    local pictureTypes = love.filesystem.getDirectoryItems("pictures")

    for i = #pictureTypes, 1, -1 do
        local t = pictureTypes[i]
        if difficulty <= 1 then
            if t == "chess.lua" then
                table.remove(pictureTypes, i)
            end
        end
    end

    return pictureTypes
end

function Gallery:new(size, timeScale, difficulty)
    math.randomseed(os.time(), love.timer.getTime())

    local obj = {}

    obj.pictures = {}
    if difficulty ~= 0 then
        local pictureTypes = getPictureTypes(difficulty)
        for i = 1, size do
            local n = math.random(1, #pictureTypes)
            local picture = Photo(65 + 1920*(i-1), 65, pictureTypes[n])

            table.insert(obj.pictures, picture)

            table.remove(pictureTypes, n)

            -- reset picture types if required
            if #pictureTypes == 0 then
                pictureTypes = getPictureTypes(difficulty)
            end
            -- remove the picture type later TODO
        end
    else
        local picture = Photo(65 , 65, "tutorial")
        table.insert(obj.pictures, picture)
    end

    obj.currentPhoto = 0
    obj.visualPhoto = -1
    obj.visualPhotoSine = 0

    obj.timeScale = timeScale or 1
    obj.difficulty = difficulty

    obj.splash = splash[math.random(1, #splash)]

    obj.nextCollider = RectangularCollider(65 + 1500 - 10, 65 + 5*(125+35), 305, 145)

    --photo.x + 1500 -10, photo.y + 5*(125+35) + 10

    setmetatable(obj, {
        __index = Gallery,
    })

    obj.timeRemaining = math.huge
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

local function saveScore(self)
            -- Save to highscore
    if self.difficulty > 0 then
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
    end

end

function Gallery:nextPhoto()
    self.currentPhoto = self.currentPhoto + 1
    self:render()

    if phase == "spotting" then
        if self.pictures[self.currentPhoto] then
            self.pictures[self.currentPhoto]:permutate()
        else
            closeNotebook()
            saveScore(self)
            tut.generateTextList()
        end

    elseif phase == "drawing" then
        if self.pictures[self.currentPhoto] then
            self.nextCollider = RectangularCollider(65 + 1500 - 10, 65 + 5*(125+35) - 160, 305, 305)
            audioManager.setTargets({
                always =    1,
                draw =      1,
                guess =     0,
                piano =     1,
                stress =    0,
            })

            self.lastTimeRemaining = self.timeRemaining
            self.timeRemaining = math.max((self.pictures[self.currentPhoto].level.time or 60) * self.timeScale, 60)

        elseif self.currentPhoto > #self.pictures + 1 then
            phase = "spotting"
            self.currentPhoto = 1
            self.visualPhoto = 0

            self.pictures[self.currentPhoto]:permutate()

            audioManager.setTargets({
                always =    1,
                draw =      0,
                guess =     1,
                piano =     0.5,
                stress =    0,
            })

        elseif self.currentPhoto == #self.pictures + 1 then
            self.lastTimeRemaining = self.timeRemaining
            self.timeRemaining = math.huge

            self.nextCollider = RectangularCollider(65 + 1500 - 10, 65 + 5*(125+35), 305, 145)
            
        else
            print("Why is current photo 0?")
        end
    else
        print("Bad phase, " .. phase)
    end
end

function Gallery:mousereleased(x, y, notebookOpen)
    if phase == "spotting" and (not notebookOpen) then
        if self.pictures[self.currentPhoto] then
            self.pictures[self.currentPhoto]:addToFinds(x, y)
        end
    end

    local p  = self.pictures[self.currentPhoto]
    local finds = 1
    if p and phase == "spotting" then
        finds = #p.finds 
    end

    if self.currentPhoto == self.visualPhoto and finds > 0 and self.nextCollider:checkCollision(camera:translatePosition(x, y)) then
        self:nextPhoto()
        closeNotebook()
        audioManager.playSound(audio.click, 0.2)
    end
end

local dodgeFlipFlop = false
function Gallery:update(dt)
    if phase == "drawing" then
        self.timeRemaining = self.timeRemaining - dt

        if self.timeRemaining < 10 and dodgeFlipFlop == false then
            local stressFade = math.min(1-(self.timeRemaining - 5)/ 5, 1)
            audioManager.setTargets({
                always =    0.5,
                draw =      1,
                guess =     0,
                piano =     1,
                stress =    stressFade,
            })
            if stressFade == 1 then
                dodgeFlipFlop = true
            end
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


    if self.pictures[self.currentPhoto] then
        self.pictures[self.currentPhoto]:update(dt, self)
    end


    -- edge case haha
    if self.visualPhoto < 0 and phase == "spotting" then
        local photo = self.pictures[#self.pictures]
        photo.x = 65 - (self.visualPhotoSine)*1920
    end
end


local function drawClock(x, y, time, scale, clockToDraw)
    local angle = time/60*math.pi*2 - math.pi/2
    local ox, oy = 0, 0

    local halfWidth, halfHeight = 305/2, 214.5
    
    if time < 5 then
        local r = math.random() * math.pi * 2
        local d = math.random() * (5-time) * 3
        ox = math.cos(r)*d
        oy = math.sin(r)*d
    end
    local finalX, finalY = x + ox + halfWidth, y + oy + halfHeight

    if scale == 1.2 then
        scale = 1.1
    end

    local gBonus = 0
    if time > 30 then
        gBonus = tweens.sineInOut(quindoc.clamp((time - 30) /30, 0, 1)) * 0.2
    end
    local outsideColour = {0.8 - gBonus, 0.8, 0.8}

    love.graphics.setColor(outsideColour)
    love.graphics.circle("fill", finalX, finalY, 148 * scale)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(clockImages.background, finalX, finalY, 0, scale, scale, halfWidth, halfHeight)

    local c = 0
    if time < 10 then
        c = (1-time/10)/2
    end
    love.graphics.setColor(0+c, 0, 0)

    love.graphics.draw(clockImages.clock[clockToDraw], finalX, finalY, 0,     scale, scale, halfWidth, halfHeight)
    love.graphics.draw(clockImages.hand[clockToDraw],  finalX, finalY, angle, scale, scale, halfWidth, halfHeight)
end


-- Holey Spaghetti Imma forghetti how this works
function Gallery:draw()
    local nextScale = 1
    
    if self.nextCollider:checkCollision(camera:translatePosition(love.mouse.getPosition())) then
        if love.mouse.isDown(1) then
            nextScale = 0.9
        else
            nextScale = 1.2
        end
    end


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
                drawClock(photo.x + 1400+100, 1030 - 367, time, nextScale, clockToDraw)

                love.graphics.setColor(0, 0, 0)
                fontManager.set("handwriting", 256 - 64)
                love.graphics.printf(i .. "/" .. #self.pictures, photo.x + 1450, 65, 390, "center")

                fontManager.set("handwriting", 64)
                love.graphics.printf("Notebook", photo.x + 1450, 65 + 128+32, 390, "center")
                love.graphics.printf("(SPACE)",  photo.x + 1450, 65 + 128+96, 390, "center")


                love.graphics.setColor(1, 1, 1)


            elseif phase == "spotting" then
                photo:drawWithScaleBonus()

                photo:drawFinds(2, photo.x + 1500, photo.y)
                local m
                if #photo.finds > 0 then
                    local img = nextImages[clockToDraw]
                    love.graphics.draw(img, photo.x + 1500 -10 + img:getWidth()/2, photo.y + 5*(125+35) + 10 + img:getHeight()/2, 0, nextScale, nextScale, img:getWidth()/2, img:getHeight()/2)
                    m = 4
                end

                if #photo.finds + (photo.missingMutations or 0) <= 8 then
                    m = m or 5
                    
                    y = m*(125+35) + 10 + 32 + 16
                    
                    love.graphics.setColor(0, 0, 0)
                    fontManager.set("handwriting", 64)
                    love.graphics.printf("Notebook", photo.x + 1450, y + 32, 390, "center")
                    love.graphics.printf("(SPACE)",  photo.x + 1450, y + 96, 390, "center")

                    love.graphics.setColor(1, 1, 1)
                end
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

            elseif not ((phase == "drawing" and i > 0) or (phase == "spotting" and i == 0)) and i < 1 then 
                fontManager.set("handwriting", 128)
                love.graphics.setColor(0, 0, 0)

                local x = sine * 1920
                if self.currentPhoto == 1 then
                    x = - (1-sine)*1920
                end

                love.graphics.printf("Draw what you see", x, 500, 1920, "center")
                fontManager.set("handwriting", 48)
                love.graphics.printf("Be quick, there's a time limit", x, 610, 1920, "center")

                love.graphics.setColor(1, 1, 1)
                local img = nextImages[clockToDraw]
                love.graphics.draw(nextImages[clockToDraw], x + 65 + 1500 -10 + img:getWidth()/2, 65 + 5*(125+35) + 10+ img:getHeight()/2, 0, nextScale, nextScale, img:getWidth()/2, img:getHeight()/2)

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
        local maX = (#photo.finds + photo.missingMutations) * (125+35) + 65

        photo:drawFinds(15, x + ox, y, true)

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