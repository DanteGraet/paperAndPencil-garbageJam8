fontManager.loadFont("assets/Handwriting1-Regular.ttf", "handwriting")

difficultyScale = {
    {name = "Easy"        , photos = 2, pages = 2, timeMult = 1.5},
    {name = "Normal"      , photos = 3, pages = 3, timeMult = 1},
    {name = "Hard"        , photos = 3, pages = 3, timeMult = 0.8},
    {name = "Extra"       , photos = 4, pages = 4, timeMult = 1},
    {name = "Deficiency"  , photos = 3, pages = 2, timeMult = 1},
    {name = "Diabolical"  , photos = 5, pages = 3, timeMult = 1.5},
    {name = "Good luck"   , photos = 5, pages = 2, timeMult = 1},
}

-- load highscores & settings
highscores = "-------"

local i = 1
if love.filesystem.getDirectoryItems("hiscore.jt") then    -- yes it's just a lua file 
    highscores = love.filesystem.read("hiscore.jt") or "-------"
end

tut = love.filesystem.load("code/gamestate/titleScreen/text.lua")()

function love.quit()
    
    love.filesystem.write("hiscore.jt", highscores)
end