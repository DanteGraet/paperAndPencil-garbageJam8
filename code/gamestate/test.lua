local g = {}

local notebook = {}
local photo

function g.load()
    notebook = Notebook(3)
    photo = Photo(65, 65, "grid")

    camera = Camera("fit", 1920, 1080)
    timer = 0

    photo:render(1)
end

function g.resize()
    camera:resize()
end

function g.update(dt)
    notebook:update(dt)
    timer = timer + dt
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
    camera()
    love.graphics.setBackgroundColor(73/255, 142/255, 145/255)
    love.graphics.setColor(1,1,1)
    photo:draw()

    notebook:draw()
end

return g