-- hey it's the paper (& pencil from the theme)
-- Prehapse do velocity stuff to make erase larger (QOL)

local function sigmoid(x)
    return 1 / ( 1 + math.pow(2.7, -x))
end

Paper = {}
Paper.__index = Paper


local paperColour = {1, 1, .9}
local penColour   = {.3, .3, .3}
local pencilWidth = 3
local eraserWidth = 60

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
    -- ok mesh is a new thing to me but i want it so shush
    -- https://gist.github.com/Clemapfel/e7c1731f0d1cdbd60433e67ae107b325
    obj.mesh = love.graphics.newMesh({
        -- posX     posY        uv      colour
        {0,         0,          0,0,    1,1,1},
        {obj.width, 0,          1,0,    1,1,1},
        {obj.width, obj.height, 1,1,    1,1,1},
        {0,         obj.height, 0,1,    1,1,1},
    }, "fan", "dynamic")
    obj.mesh:setTexture(obj.canvas)

    -- 0 is closed, 1 is open and 2 is not infornt or something
    obj.openingTimer = 1
    obj.isOpen = true

    obj.isDrawing = false
    obj.erase = false
    obj.lastPoint = {0, 0}      -- x, y position
    obj.vStore = {}


    setmetatable(obj, {
        __index = Paper,
    })

    obj:reset()

    return obj
end

function Paper:reset()
    love.graphics.setCanvas(self.canvas)
    love.graphics.origin()
    love.graphics.setColor(paperColour)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    love.graphics.setCanvas()
end

function Paper:mark(text, x, y, limit, align)
    love.graphics.setCanvas(self.canvas)
    love.graphics.origin()
    love.graphics.setColor(penColour)
    love.graphics.printf(text, x, y, limit or 1500, align or "left")

    love.graphics.setCanvas()
end

function Paper:startDraw(mx, my, erase)
    local mx, my = camera:translatePosition(love.mouse.getPosition())
    self.erase = erase  -- true or false, for black or white colour
    self.lastPoint = {mx - self.x, my - self.y}
    self.isDrawing = true

    if erase then
        audioManager.newLoopingSound("draw", audio.erase, catagory, 1)
    else
        audioManager.newLoopingSound("draw", audio.draw, catagory, 1)
    end

    self.vStore = {}
end

function Paper:endDraw(erase)
    if erase ~= nil and erase == self.erase then
        self.isDrawing = false
    else
        self.isDrawing = false
    end

    audioManager.removeLoopingSound("draw")
end


function Paper:update(dt)
    if self.isDrawing == true then
        local mx, my = camera:translatePosition(love.mouse.getPosition())
        local editWidth = (self.erase and eraserWidth) or pencilWidth
        love.graphics.setColor((self.erase and paperColour) or penColour)

        love.graphics.setCanvas(self.canvas)
        love.graphics.origin()

        love.graphics.setLineWidth(editWidth)

        love.graphics.line(self.lastPoint[1], self.lastPoint[2], mx - self.x, my - self.y)
        love.graphics.circle("fill", self.lastPoint[1], self.lastPoint[2], editWidth/2)
        love.graphics.circle("fill", mx - self.x, my - self.y, editWidth/2)

        local vx = (mx - self.x - self.lastPoint[1])
        local vy = (my - self.y - self.lastPoint[2])
        local v = math.max(math.sqrt(vx * vx + vy * vy) / dt, (self.lastPoint[3] or 0) *dt)

        table.insert(self.vStore, v)
        if #self.vStore > 5 then
            table.remove(self.vStore, 1)
        end

        local vol = 0
        for i = 1,#self.vStore do
            vol = vol + self.vStore[i]
        end
        vol = vol / #self.vStore

        audioManager.modifyLoopingSound("draw", {volume = math.min(vol / 1000, 1), pitch = math.max((sigmoid(vol/10000)) * 6 - 3, 1)})

        self.lastPoint = {
            mx - self.x,
            my - self.y,
        }

        love.graphics.setCanvas()
    end

    --self.openingTimer = self.openingTimer + dt -- should just apporach target

    if self.isOpen then
        self.openingTimer = math.min(self.openingTimer + dt*3, 1)
    else
        self.openingTimer = math.max(self.openingTimer - dt*3, 0)
    end

    local sine = math.cos(self.openingTimer * math.pi / 2)

    -- https://love2d.org/wiki/Mesh:setVertexAttribute
    self.mesh:setVertexAttribute(1, 1, 0 - self.width/10 * (sine), sine * self.height)
    self.mesh:setVertexAttribute(2, 1, self.width + self.width/10 * (sine), sine * self.height)

    for i = 1, self.mesh:getVertexCount() do
        self.mesh:setVertexAttribute(i, 3, 1-sine/2, 1-sine/2, 1-sine/2)
    end
end

function Paper:draw()
    love.graphics.draw(self.mesh, self.x, self.y)

    if self.isDrawing and self.erase then
        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(1)
        love.graphics.circle("line", self.lastPoint[1] + self.x, self.lastPoint[2] + self.x, eraserWidth/2)
    end
end