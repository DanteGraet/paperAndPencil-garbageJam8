-- Notebook stores multiple papers

-- I can't be bother to import quindoc yet so...
local function sign(x)
    return (x > 0 and 1) or (x < 0 and -1) or 0
end


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
        table.insert(obj.pages, Paper(50, 50))    -- 5050 is default for now A4is is default so who cares?
    end

    obj.currentPage = 1


    setmetatable(obj, {
        __index = Notebook,
    })


    return obj
end

function Notebook:wheelmoved(x, y)      -- i would wheelMoved but consistency or somethin
    self:endDraw()
    self.currentPage = self.currentPage + sign(y)

    if self.currentPage > #self.pages then
        self.currentPage = 1
    elseif self.currentPage < 1 then
        self.currentPage = #self.pages
    end
end

function Notebook:startDraw(mx, my, erase)
    self.pages[self.currentPage]:startDraw(mx, my, erase)
end

function Notebook:endDraw(mx, my, erase)
    self.pages[self.currentPage]:endDraw(mx, my, erase)
end


function Notebook:update(dt)
    self.pages[self.currentPage]:update(dt)
end

function Notebook:draw()
    -- draw the current one for now but draw all if time is > 0 and < 2
    self.pages[self.currentPage]:draw()
end