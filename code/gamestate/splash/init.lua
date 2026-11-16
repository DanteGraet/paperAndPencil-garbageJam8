local nextGameState = "test"

local textList = {
    string.upper("Jaraph"),
}
local image
local font 

local timer

local width = love.graphics.getWidth()
local height = love.graphics.getHeight()

local function resize()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
end


local function load()
    love.mouse.setVisible(false)

    timer = 0
    image = love.graphics.newImage("code/gameState/splash/jaraph.png")
    font = love.graphics.newFont("code/gameState/splash/fontBlack.ttf", 512 + 256)
end

local function unload()
    love.mouse.setVisible(true)
end


local function update(dt)
    timer = timer + dt
    if timer >= 5.5 then
        if nextGameState then
            gamestateManager.setGamestate(nextGameState)
        end
    end

    if love.keyboard.isDown("space", "escape") then
        gamestateManager.setGamestate(nextGameState)
    end
end

local function sineOut(percent)
    return (math.sin((percent/2)*math.pi))
end

local function draw()
    local scaleAll = math.min(width/1920, height/1080)
    local scaleAlleY = height/1080
    love.graphics.translate(width/2, height/2)

    if font then
        love.graphics.setFont(font)
        love.graphics.setColor(104/255, 171/255, 197/255)

        local cps = 10
        local legnth = timer*cps
        local text = " "
        if legnth > cps then
            text = string.sub(textList[1], 0, math.floor(legnth)-cps)
        end
        local textScaleX = width/font:getWidth(text)
        local textScaleY = 1--height/(font:getHeight(text))
        if legnth < 100 then
            local ox = font:getWidth(text)*math.min(textScaleX, scaleAlleY)
            love.graphics.print(text, math.max(width/2 - ox, -width/2), -75*scaleAlleY, 0, math.min(textScaleX, scaleAlleY), scaleAlleY, 0, font:getHeight(text)/2)
        end

        if legnth > #textList[1] + cps then 
            legnth = legnth - 10
        end
        
        if legnth > #textList[1] + cps and legnth < #textList[1] + cps*2 then
            local r = math.pow((legnth  - (#textList[1] + cps)), 3)
            love.graphics.circle("fill", 0, 0, r)
        end

        local p = 1- math.max((-math.pow((((legnth-(#textList[1] + cps*2))/50*cps) - 2), 3) + 1)/50*cps, 0)
        local r = math.sqrt((width/2)*(width/2) + (height/2)*(height/2))* (1-p)
        local cX, cY = 78*p, -182*p

        if legnth >= #textList[1] + cps*2 then
            love.graphics.circle("fill", cX*scaleAll*0.5, cY*scaleAll*0.5, r)
        end

        love.graphics.setColor(1, 1, 1, sineOut(math.min(timer, 1)))
        love.graphics.draw(image, 0, 70 - sineOut(math.min(timer, 1))*70, 0, scaleAll*0.5, scaleAll*0.5, image:getWidth()/2, image:getHeight()/2)

        if legnth >= #textList[1] + cps*2 then
            love.graphics.setColor(0,0,0)
            love.graphics.setLineWidth(1024)

            love.graphics.circle("line", cX*scaleAll*0.5, cY*scaleAll*0.5, r + 1024/2)
        end
    end
end


return {
    load = load,
    unload = unload,
    resize = resize,
    update = update,
    draw = draw,

    isFirst = true,
    noTransform = true,
}