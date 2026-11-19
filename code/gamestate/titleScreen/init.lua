fontManager.loadFont("assets/QuindocahLite.ttf", "quindocha")

local g = {}

local notebook = {}
-- tut is persistant caus why not

function g.load()
    notebook = Notebook(3)
    notebook.isOpen = false

    camera = Camera("fit", 1920, 1080)
    timer = 0

    love.mouse.setVisible(true)

end

function g.resize()
    camera:resize()
end

function g.update(dt)
    tut.update(dt, notebook.isOpen)
    notebook:update(dt)
    timer = timer + dt
end

function g.keypressed(key)
    if key == "space" then
        notebook:setOpen()
    end
end

function g.mousepressed(x, y, button)
    tut.nextLine()

    if button == 1 then
        notebook:startDraw(x, y, false)
    elseif button == 2 then
        notebook:startDraw(x, y, true)
    end
end

function g.mousereleased(x, y, button)
    if notebook.isOpen == true then
        --if phase == "drawing" then
        if button == 1 then
            notebook:endDraw(false)
        elseif button == 2 then
            notebook:endDraw(true)
        end
    else
        tut.click()
    end
end


function g.wheelmoved(x, y)
    notebook:wheelmoved(x, y)
end

function g.draw(skipCamera)
    if skipCamera ~= true then
        camera()
    end
    love.graphics.setBackgroundColor(73/255, 142/255, 145/255)

    love.graphics.setColor(0, 0, 0)
    --fontManager.set("quindocha", 128)
    --love.graphics.print("Jot the Difference", 64, 64)
    tut.draw(notebook.isOpen)


    love.graphics.setColor(1,1,1)
    notebook:draw()
end

return g