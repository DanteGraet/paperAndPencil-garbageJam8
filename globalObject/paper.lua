-- hey it's the paper (& pencil from the theme)

Paper = {}
Paper.__index = Paper


local pencilWidth = 0
local erasorWidth = 0

setmetatable(Paper, {
    __call = function(self, width, height)
        return self:new(scaleType, width, height)
    end
})


function Paper:new(scaleType, width, height)
    local obj = {}

    obj.canvas = love.graphics.newCanvas(width, height)

    -- 0 is closed, 1 is open
    obj.openingTimer = 0

    obj.isDrawing = false
    obj.erase = false
    obj.lastPoint = {0, 0}      -- x, y position

    return obj
end

function Paper:startDraw(erase)
    local mx, my = love.mouse.getPosition() -- TODO: wrap in camera
    self.erase = erase  -- true or false, for black or white colour
    self.lastPoint = {mx, my}
    self.isDrawing = true
end


function Paper:updates(dt)
    
    if self.isDrawing then
        local mx, my = love.mouse.getPosition() -- TODO: wrap in camera

        love.graphics.setCanvas(self.canvas)
        love.graphics.setLineWidth(pencilWidth)
    end
end