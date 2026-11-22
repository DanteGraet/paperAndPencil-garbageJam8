local g = {}

local notebook = {}
local photo
local gallery
local difficulty
local lastFrameCanvas

local fadeImage = love.graphics.newImage("assets/ui/fade.png")

function closeNotebook()
    if notebook.isOpen then
        notebook:setOpen(false) -- this fucntion dont work for some reason
    end
end

function g.load(diff, lf)
    difficulty = diff or 0

    camera = Camera("fit", 1920, 1080)
    timer = 0
    phase = "drawing"

    if difficulty ~= 0 then
        lastFrameCanvas = lf

        notebook = Notebook(difficultyScale[difficulty].pages)
        notebook.isOpen = false

        gallery = Gallery(difficultyScale[difficulty].photos, difficultyScale[difficulty].timeMult, difficulty)
    else
        -- run the toutorial
        local img = love.graphics.newImage("object/background/controls.png")
        notebook = Notebook(2)

        love.graphics.setCanvas(notebook.pages[2].canvas)
        love.graphics.origin()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(img, 50, 50)
        love.graphics.setCanvas()

        notebook.isOpen = false


        gallery = Gallery(1, 1, 0)
    end

    love.mouse.setVisible(true)

    audioManager.setTargets({
        always =    1,
        draw =      1,
        guess =     0,
        piano =     1,
        stress =    0,
    })
end

function g.resize()
    camera:resize()
end

function g.update(dt)
    notebook:update(dt)
    gallery:update(dt)
    timer = timer + dt
end

function g.keypressed(key)
    if key == "space" then
        notebook:setOpen()
    -- elseif key == "t" then
    --     gallery:nextPhoto()
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
    if notebook.isOpen == true then
        --if phase == "drawing" then
        if button == 1 then
            notebook:endDraw(false)
        elseif button == 2 then
            notebook:endDraw(true)
        end
    -- end
    end

    if button == 1 then
        gallery:mousereleased(x, y, notebook.isOpen)
    end
end


function g.wheelmoved(x, y)
    notebook:wheelmoved(x, y)
end

function g.draw()
    camera()
    love.graphics.setBackgroundColor(73/255, 142/255, 145/255)
    love.graphics.setColor(1,1,1)


    -- if phase == "drawing" then
    --     photo:draw()
    -- elseif phase == "spotting" then
    --     photo:drawWithScaleBonus()
    -- end

    gallery:draw()

    notebook:draw()

    if gallery.visualPhoto < 0 and phase == "drawing" then
        if lastFrameCanvas then
            love.graphics.draw(lastFrameCanvas, -1920 -gallery.visualPhotoSine * 1920, 0)
        end
    end

    
    if camera.offsetX > 65 then
        love.graphics.setColor(73/255, 142/255, 145/255)
        
        love.graphics.draw(fadeImage, -40, -10, 0, 1, 1100)
        love.graphics.rectangle("fill", -camera.offsetX - 38, -10, camera.offsetX, 1100)

        love.graphics.draw(fadeImage, 1920+40, -10, 0, -1, 1100)
        love.graphics.rectangle("fill", 1920+38, -10, camera.offsetX, 1100)
    end
end

return g