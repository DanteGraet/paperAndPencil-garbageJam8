-- hey it's the paper (& pencil from the theme)
-- Prehapse do velocity stuff to make erase larger (QOL)

Paper = {}
Paper.__index = Paper


local pencilWidth = 3
local eraserWidth = 30

setmetatable(Paper, {
    __call = function(self, width, height)
        return self:new(width, height)
    end
})


function Paper:new(x, y, width, height)
    local obj = {}

    obj.x = x
    obj.y = y

    -- Width and height to somewhat mathc a4 paper (210 x 300  (*5) insead of 210 x 297)
    obj.width = width or 1500
    obj.height = height or 1050

    obj.canvas = love.graphics.newCanvas(width or 1500, height or 1050)

    -- 0 is closed, 1 is open and 2 is not infornt or something
    obj.openingTimer = 1


    obj.isDrawing = false
    obj.erase = false
    obj.lastPoint = {0, 0}      -- x, y position


    setmetatable(obj, {
        __index = Paper,
    })

    obj:reset()

    return obj
end

function Paper:reset()
    love.graphics.setCanvas(self.canvas)
    love.graphics.origin()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    love.graphics.setCanvas()
end

function Paper:startDraw(mx, my, erase)
    local mx, my = love.mouse.getPosition() -- TODO: wrap in camera
    self.erase = erase  -- true or false, for black or white colour
    self.lastPoint = {mx - self.x, my - self.y}
    self.isDrawing = true
end

function Paper:endDraw(erase)
    if erase ~= nil and erase == self.erase then
        self.isDrawing = false
    else
        self.isDrawing = false
    end
end

function Paper:update(dt)
    
    if self.isDrawing == true then
        local mx, my = love.mouse.getPosition() -- TODO: wrap in camera
        local editWidth = (self.erase and eraserWidth) or pencilWidth

        love.graphics.setCanvas(self.canvas)
        love.graphics.origin()


        if self.erase then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0, 0, 0)
        end

        love.graphics.setLineWidth(editWidth)

        love.graphics.line(self.lastPoint[1], self.lastPoint[2], mx - self.x, my - self.y)
        love.graphics.circle("fill", self.lastPoint[1], self.lastPoint[2], editWidth/2)
        love.graphics.circle("fill", mx - self.x, my - self.y, editWidth/2)
        self.lastPoint = {
            mx - self.x,
            my - self.y
        }

        love.graphics.setCanvas()
    end

end

function Paper:draw()
    if self.openingTimer == 1 then
        love.graphics.draw(self.canvas, self.x, self.y)
    end

    if self.isDrawing and self.erase then
        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(1)
        love.graphics.circle("line", self.lastPoint[1] + self.x, self.lastPoint[2] + self.x, eraserWidth/2)
    end
end