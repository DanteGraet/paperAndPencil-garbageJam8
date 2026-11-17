-- Photo stores multiple papers

-- I can't be bother to import quindoc yet so...
local function sign(x)
    return (x > 0 and 1) or (x < 0 and -1) or 0
end


Photo = {}
Photo.__index = Photo

fontManager.loadFont("assets/QuindocahLite.ttf", "quindocha")

setmetatable(Photo, {
    __call = function(self, x, y, level)
        return self:new(x, y, level)
    end
})


function Photo:new(x, y, level)
    math.randomseed(os.time(), love.timer.getTime())
    local obj = {}

    obj.level = love.filesystem.load("pictures/" .. level .. ".lua")()
    obj.objects = {}
    obj.changes = {}

    obj.x = x
    obj.y = y

    obj.canvases = {
        love.graphics.newCanvas(1400, 950),
        love.graphics.newCanvas(1400, 950)
    }

    setmetatable(obj, {
        __index = Photo,
    })


    obj.level.loadObjects()
    obj.objects = obj.level.generateObjects()

    obj:render(1)
    obj:render(2)

    return obj
end

function Photo:render(canvasNo)
    love.graphics.setCanvas(self.canvases[canvasNo])
    love.graphics.origin()
    love.graphics.clear(1, 1, 1)

    for i = 1, #self.objects do
        local object = self.objects[i]
        love.graphics.setColor(1,1,1)
        object:draw(canvasNo)
    end

    love.graphics.setCanvas()
end


function Photo:permutate(count)
    print("MUtating")

    self.changes = self.level.permutate(self.objects, count or 3)

    self:render(1)
    self:render(2)
end


function Photo:draw()
    local canvasToDraw = math.floor((timer*5) % 2) + 1
    love.graphics.draw(self.canvases[canvasToDraw], self.x, self.y)

    -- CHEAT PLEASE REMOVE LATER
    if DEV == true and love.keyboard.isDown("lshift") then
        love.graphics.setColor(1,0, 0)
        for i = 1,#self.changes do
            local c = self.changes[i]
            love.graphics.circle("line", c[1], c[2], c[3])
        end
        love.graphics.setColor(1,1,1)
    end
end