-- Notebook stores multiple papers

-- I can't be bother to import quindoc yet so...
local function sign(x)
    return (x > 0 and 1) or (x < 0 and -1) or 0
end

local pencilImage = {
    love.graphics.newImage("assets/ui/pencil1.png"),
    love.graphics.newImage("assets/ui/pencil2.png")
}


Notebook = {}
Notebook.__index = Notebook



setmetatable(Notebook, {
    __call = function(self, size)
        return self:new(size)
    end
})


function Notebook:new(size)
    local obj = {}

    obj.pages = {}
    for i = 1, size do
        local page = Paper(15, 15)   -- 5050 is default for now A4is is default so who cares?
        fontManager.set("quindocha", 32)
        page:mark(size - i + 1 .. "/" .. size, 16, 16)
        table.insert(obj.pages, page) 
    end

    obj.currentPage = size
    obj.isOpen = false

    setmetatable(obj, {
        __index = Notebook,
    })

    obj:setOpen(false)
    obj:updatePageVisibility(false)
    obj:update(1)

    return obj
end

function Notebook:setOpen(isOpen)
    self.isOpen = isOpen or not self.isOpen

    self:endDraw(nil, nil, true)    
    self:endDraw(nil, nil, false)

    if self.isOpen == true then
        self:updatePageVisibility()
    else
        self:updatePageVisibility(false)
    end

    love.mouse.setVisible(not self.isOpen)
end
 
function Notebook:updatePageVisibility(isVisible)
    if isVisible ~= nil then
        for i = 1,#self.pages do
            local page = self.pages[i]
            page.isOpen = isVisible
        end
    else
        for i = 1,#self.pages do
            local page = self.pages[i]
            if i <= self.currentPage then
                page.isOpen = true
            else
                page.isOpen = false
            end
        end
    end
end

function Notebook:wheelmoved(x, y)      -- i would wheelMoved but consistency or somethin
    if self.isOpen == false then return end

    self:endDraw()
    self.currentPage = self.currentPage + sign(y)

    if self.currentPage > #self.pages then
        self.currentPage = 1
    elseif self.currentPage < 1 then
        self.currentPage = #self.pages
    end

    self:updatePageVisibility()
end

function Notebook:startDraw(mx, my, erase)
    if self.isOpen == false then return end

    self.pages[self.currentPage]:startDraw(mx, my, erase)
end

function Notebook:endDraw(mx, my, erase)
    --if self.isOpen == false then return end

    self.pages[self.currentPage]:endDraw(mx, my, erase)
end


function Notebook:update(dt)
    -- um they actually all have to update their drawing timer
    for i = 1, #self.pages do
        self.pages[i]:update(dt)
    end
end

function Notebook:draw()
    -- draw the current one for now but draw all if time is > 0 and < 2
    for i = 1,#self.pages do
        local page = self.pages[i]
        page:draw()
    end

    local frame =  math.floor((timer*5) % 2) + 1
    local mx, my = camera:translatePosition(love.mouse.getPosition())
    if self.isOpen then
        love.graphics.setColor(1,1,1)
        if self.pages[self.currentPage].isDrawing == true then
            if self.pages[self.currentPage].erase == true then
                love.graphics.draw(pencilImage[frame], mx, my, (frame-1.5) / 4, -1, -1)
            else
                love.graphics.draw(pencilImage[frame], mx, my, (frame-1.5) / 4, 1, 1, 50, 51)
            end
        else
            love.graphics.draw(pencilImage[frame], mx - 50, my - 51)
        end
    end
--    self.pages[self.currentPage]:draw()
end