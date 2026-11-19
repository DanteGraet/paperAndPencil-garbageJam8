local textList = {}

local timer = 0
local linesToDraw = 1
local charToDraw = 0

local function start(difficulty)
    local canvas = love.graphics.newCanvas(1920, 1080)

    love.graphics.setCanvas(canvas)
    love.graphics.origin()
    local g = gamestateManager.get()
    g.draw(true)
    love.graphics.setCanvas()

    gamestateManager.setGamestate("test", difficulty, canvas)
end

local function generateTextList()
    textList = {
        {
            x = 32, y = 32, size = 128, interact = false, speed = 0.05,
            text = "Jot the Difference"
        },
        {
            x = 32, y = 32+128, size = 64, interact = false, speed = 0.05,
            text = "(SPACE) toggle notebook"
        },
        {
            x = 32, y = 32+128*1.5, size = 64, interact = false, speed = 0.02,
            text = "(SCROLL) next page"
        },
        {
            x = 32, y = 32+128*2, size = 64, interact = false, speed = 0.02,
            text = "(RMB) draw"
        },
        {
            x = 32, y = 32+128*2.5, size = 64, interact = false, speed = 0.02,
            text = "(LMB) erase"
        },
        {
            x = 32, y = 32+128*3, size = 64, interact = false, speed = 0.02,
            text = "Draw what you see"
        },

        {
            x = 32, y = 1080 - 32 - 64, size = 64, interact = true, speed = 0.02,
            text = "--O-- Music"
        },
        {
            x = 32, y = 1080 - 32 - 128, size = 64, interact = true, speed = 0.02,
            text = "--O-- SFX"
        },


    }

    local displayCount = math.min(math.max(#highscores + 10, 3), #difficultyScale)

    table.insert(textList,
        {
            x = 1530, y = 1080 - 32 - 64 * (displayCount+1), size = 64, interact = false, speed = 0.03,
            text = "Play:"
        }
    )

    for i = 1, displayCount do
        local suff = ""
        if highscores[i] then
            suff = " (" ..  highscores[i] .. ")"
        end
        table.insert(textList,
        {
            x = 1545, y = 1080 - 32 - 64 * (displayCount-i+1), size = 64, interact = start, data = i, speed = 0.01,
            text = difficultyScale[i].name .. suff
        })
    end

    -- Add colliders
    for i = 1,#textList do
        local t = textList[i]
        if t.interact then
            local font = fontManager.get("quindocha", t.size)
            local width = font:getWidth(t.text .. "   .")
            local height = font:getHeight(t.text)

            t.collider = RectangularCollider:new(t.x, t.y, width, height *0.7)
        end
    end
end

local text = {}

function text.update(dt, isNotebookOpen)
    if not textList[linesToDraw] then
        return
    end
    timer = timer - dt

    local current = textList[linesToDraw].text
    if timer <= 0 then
        charToDraw = charToDraw + 1

        timer = timer + textList[linesToDraw].speed

        if charToDraw > #current and isNotebookOpen == false then
            linesToDraw = linesToDraw + 1
            timer = timer + 0.5
            charToDraw = 0
        end
    end
end

function text.nextLine()
    linesToDraw = linesToDraw + 1
    charToDraw = 0
end

function text.click()
    local mx, my = camera:translatePosition(love.mouse.getPosition())

    for i = 1, linesToDraw do
        local t = textList[i]
        if t then
            if t.interact and t.collider:checkCollision(mx, my) == true then
               t.interact(t.data) 
            end
        end
    end
end

function text.draw(isNotebookOpen)
    local mx, my = camera:translatePosition(love.mouse.getPosition())

    for i = 1, linesToDraw do
        local t = textList[i]
        if t then
            local text = textList[i].text
            local pref = ""
            if isNotebookOpen == false and t.interact and t.collider:checkCollision(mx, my) == true then
                pref = "X "
                if love.mouse.isDown(1) then
                    pref = "x "
                end
            end

            if i == linesToDraw then
                text = text:sub(0, charToDraw)
            end

            fontManager.set("quindocha", t.size)
            love.graphics.print(pref .. text, t.x, t.y)
        end
    end
end


generateTextList()

return text