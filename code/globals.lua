fontManager.loadFont("assets/Handwriting1-Regular.ttf", "handwriting")

difficultyScale = {
    {name = "Easy"        , photos = 2, pages = 2, timeMult = 1.5},
    {name = "Normal"      , photos = 3, pages = 3, timeMult = 1},
    {name = "Hard"        , photos = 3, pages = 3, timeMult = 0.8},
    {name = "Extra"       , photos = 4, pages = 4, timeMult = 1},
    {name = "Deficiency"  , photos = 3, pages = 2, timeMult = 1},
    {name = "Diabolical"  , photos = 5, pages = 3, timeMult = 0.9},
    {name = "Good luck"   , photos = 5, pages = 2, timeMult = 0.7},
}

-- load highscores & settings
highscores = "-------"

local i = 1
if love.filesystem.getDirectoryItems("hiscore.jt") then    -- yes it's just a lua file 
    highscores = love.filesystem.read("hiscore.jt") or "-------"
end


settings = {
    SFX = 2,
    music = 2
}

if love.filesystem.getDirectoryItems("settings.jt") then
    local s = love.filesystem.read("settings.jt")
    
    if s then
        settings.SFX = s:sub(1, 1) or 2
        settings.music = s:sub(2, 2) or 2
    end
end

-- looad other globals
tut = love.filesystem.load("code/gamestate/titleScreen/text.lua")()

audio = {
    draw = love.audio.newSource("assets/audio/draw.ogg", "static"),
    erase = love.audio.newSource("assets/audio/erase.ogg", "static"),
}

audioManager.addBackgroundTrack("assets/audio/music/always.ogg" ,"always"   ,1)
audioManager.addBackgroundTrack("assets/audio/music/draw.ogg"   ,"draw"     ,0)
audioManager.addBackgroundTrack("assets/audio/music/guess.ogg"  ,"guess"    ,0)
audioManager.addBackgroundTrack("assets/audio/music/piano.ogg"  ,"piano"    ,.75)
audioManager.addBackgroundTrack("assets/audio/music/stress.ogg" ,"stress"   ,0)

addEvent("update", audioManager.manageBackground, 1)

function love.quit()
    love.filesystem.write("hiscore.jt", highscores)
    love.filesystem.write("settings.jt", settings.SFX .. settings.music)
end