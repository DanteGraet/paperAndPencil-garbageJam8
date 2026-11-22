fontManager.loadFont("assets/QuindocahLite.ttf", "quindocha")

local g = {}

local notebook = {}
-- tut is persistant caus why not



function g.load()
    notebook = Notebook(3)
    notebook.isOpen = false

    camera = Camera("fit", 1920, 1080)
    timer = 10

    love.mouse.setVisible(true)

    audioManager.setTargets({
        always =    1,
        draw =      0,
        guess =     0,
        piano =     0.75,
        stress =    0,
    })


end


function g.resize()
    camera:resize()
end


function g.update(dt)
    tut.update(dt, notebook.isOpen)
    notebook:update(dt)
    timer = timer + dt

    if timer > 30 then
        timer = math.random(5, 20)

        local tracks = {
            always =    1,
            draw =      0,
            guess =     0,
            piano =     0,
            stress =    0,
        }

        local enum = {"always", "draw", "guess", "piano", "stress"}

        local force
        for i = 1, math.random(0, 2) do
            local c = math.random(1, #enum)

            tracks[enum[c]] = force or (math.random(1, 4) / 4)

            if enum[c] == "always" then
                force = 1
            end

            table.remove(enum, c)
        end

        audioManager.setTargets(tracks)
    end

    floatingStuff.update(dt)
end

function g.keypressed(key)
    if key == "space" then
        notebook:setOpen()
    end
end

function g.mousepressed(x, y, button)
    if not notebook.isOpen then
        tut.nextLine()
    end

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
        floatingStuff.draw()

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