Camera = {}
Camera.__index = Camera


setmetatable(Camera, {
    __call = function(self, scaleType, width, height, anchor)
        return self:new(scaleType, width, height, anchor)
    end
})


function Camera:new(scaleType, width, height, anchor)
    local obj = {}

    obj.scaleType = scaleType   or "none"
    obj.width =     width       or 1920
    obj.height =    height      or 1080
    obj.anchor =    anchor      or {0, 0}
    obj.x = 0
    obj.y = 0

    setmetatable(obj, {
        __index = Camera,
        __call = function(self)
            return self:translate()
        end
    })

    obj:resize()

    return obj
end


function Camera:translatePosition(x, y)
    local offsetX, offsetY = self.offsetX or 0, self.offsetY or 0

    local translatedX = x / self.scale - offsetX
    local translatedY = y / self.scale - offsetY

    return translatedX, translatedY
end


function Camera:setBoundries(minX, minY, maxX, maxY)
    local dx = maxX - minX
    local dy = maxY - minY

    local averageX = (minX + maxX) / 2
    local averageY = (minY + maxY) / 2

    g.mainCamera.width = dx
    g.mainCamera.height = dy
    g.mainCamera.anchor = {-averageX / dx + 0.5, -averageY / dy + 0.5}
    g.mainCamera:resize()   -- The resize actually just updates the scale
end


function Camera:resize()
    local scaleX, scaleY = love.graphics.getWidth() / self.width, love.graphics.getHeight() / self.height

    if self.scaleType == "none" then
        self.scale = 1
    elseif self.scaleType == "fill" then
        self.scale = math.max(scaleX, scaleY)
    elseif self.scaleType == "fit" then
        self.scale = math.min(scaleX, scaleY)
    else
        error("scale type 'none', 'fill', or 'fit' expected. Got " .. self.scaleType)
    end

    if self.scaleType == "none" then
        self.offsetX, self.offsetY = 0, 0
    else
        self.offsetX = ((love.graphics.getWidth() / self.scale) - self.width) / 2
        self.offsetY = ((love.graphics.getHeight() / self.scale) - self.height) / 2
    end

    self.offsetX = self.offsetX + love.graphics.getWidth() * self.anchor[1] / scaleX
    self.offsetY = self.offsetY + love.graphics.getHeight() * self.anchor[2] / scaleY
end

function Camera:getOffset()
    return self.offsetX, self.offsetY
end


function Camera:getScale()
    return self.scale
end


function Camera:translate()
    love.graphics.origin()

    love.graphics.scale(self.scale, self.scale)

    love.graphics.translate(self.offsetX or 0, self.offsetY or 0)
end