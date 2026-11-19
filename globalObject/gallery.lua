Gallery = {}
Gallery.__index = Gallery

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
    __call = function(self, size)
        return self:new(size)
    end
})


function Gallery:new(size, timeScale)
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

    obj.timeScale = timeScale or 1

    setmetatable(obj, {
        __index = Gallery,
    })

    obj.timeRemaining = ((obj.pictures[obj.currentPhoto] and obj.pictures[obj.currentPhoto].level.time) or 60) * obj.timeScale
    obj.lastTimeRemaining = 0
    
    obj:render()

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
            self.timeRemaining = self.pictures[self.currentPhoto].level.time * self.timeScale
        end
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

        for i = 1, #self.pictures do
            local photo = self.pictures[i]
            photo.x = 65 - (self.visualPhoto-i)*1920
        end
    end

    -- edge case haha
    if self.visualPhoto < 1 and phase == "spotting" then
        local photo = self.pictures[#self.pictures]
        photo.x = 65 - (self.visualPhoto)*1920
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

                photo:drawFinds()
            end
        end
    end
end