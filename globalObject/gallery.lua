Gallery = {}
Gallery.__index = Gallery


setmetatable(Gallery, {
    __call = function(self, size)
        return self:new(size)
    end
})


function Gallery:new(size)
    math.randomseed(os.time(), love.timer.getTime())

    local obj = {}

    local pictureTypes = love.filesystem.getDirectoryItems("pictures")
    obj.pictures = {}
    for i = 1, size do
        local n = math.random(1, #pictureTypes)
        local picture = Photo(65 + 1920*(i-1), 65, pictureTypes[n])

        table.insert(obj.pictures, picture)
        -- remove the picture type later TODO
    end

    obj.currentPhoto = 1
    obj.visualPhoto = 0

    setmetatable(obj, {
        __index = Gallery,
    })

    obj.timeRemaining = obj.pictures[obj.currentPhoto].level.time
    
    obj:render()

    phase = "drawing"

    return obj
end

function Gallery:render(pictureNo)
    local no = pictureNo or self.currentPhoto

    if self.pictures[no] then
        self.pictures[no]:render(1)
        self.pictures[no]:render(2)
        print(no, "renderd")
    end
end

function Gallery:nextPhoto()
    print("time")

    self.currentPhoto = self.currentPhoto + 1
    self:render()

    if self.currentPhoto > #self.pictures then
    --    phase = "spotting"
    end
end


function Gallery:update(dt)
    self.timeRemaining = self.timeRemaining - dt
    if self.timeRemaining < 0 then 
        self:nextPhoto()
    end

    -- in thoeryu thus works cause current photo dont go down
    if self.visualPhoto < self.currentPhoto then
        self.visualPhoto = math.min(self.visualPhoto + dt, self.currentPhoto)

        for i = 1, #self.pictures do
            local photo = self.pictures[i]
            photo.x = 65 - (self.visualPhoto-i)*1920
        end
    end
end


function Gallery:draw()
    for i = math.floor(self.visualPhoto), math.ceil(self.visualPhoto) do
        local photo = self.pictures[i]
        if photo then
            if phase == "drawing" then
                photo:draw()
            elseif phase == "spotting" then
                photo:drawWithScaleBonus()
            end
        end
    end
end