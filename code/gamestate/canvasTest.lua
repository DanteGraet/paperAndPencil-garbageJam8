local g = {}

local notebook = {}
function g.load()
    notebook = Notebook(3)
end

function g.update(dt)
    notebook:update(dt)
end

function g.keypressed(key)
    if key == "space" then
        notebook:setOpen()
    end
end

function g.mousepressed(x, y, button)
    if button == 1 then
        notebook:startDraw(x, y, false)
    elseif button == 2 then
        notebook:startDraw(x, y, true)
    end
end

function g.mousereleased(x, y, button)
    if button == 1 then
        notebook:endDraw(false)
    elseif button == 2 then
        notebook:endDraw(true)
    end
end

function g.wheelmoved(x, y)
    notebook:wheelmoved(x, y)
end

function g.draw()
    love.graphics.setColor(1,1,1)
    notebook:draw()
end

return g