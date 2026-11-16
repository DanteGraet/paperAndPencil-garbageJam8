local g = {}

local paper = {}
function g.load()
    paper = Paper(50, 50)
end

function g.update(dt)
    paper:update(dt)
end

function g.mousepressed(x, y, button)
    if button == 1 then
        paper:startDraw(x, y, false)
    elseif button == 2 then
        paper:startDraw(x, y, true)
    end
end

function g.mousereleased(x, y, button)
    if button == 1 then
        paper:endDraw(false)
    elseif button == 2 then
        paper:endDraw(true)
    end
end

function g.draw()
    love.graphics.setColor(1,1,1)
    paper:draw()
end

return g