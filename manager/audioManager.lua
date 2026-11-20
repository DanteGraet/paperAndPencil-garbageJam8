-- ripped (and shrunk) from https://github.com/DanteGraet/ASVGC-25/blob/main/BoteGame/templateLib/audioManager.lua

audioManager = {}

function audioManager.playSound(sound, pitchChange)
    local tempSound

    if settings.SFX == 0 then
        return
    end

    --create the sound from either a table (pick random) or sound
    if type(sound) == "table" then
        tempSound = sound[math.random(1,#sound)]:clone()
    else
        tempSound = sound:clone()
    end

    -- modify pitch
    local pitch = (pitchChange or 0.05)/2
    tempSound:setPitch(1 + math.random(-pitch*100, pitch*100)/100)

    -- modify volume
    local subVolume = settings.SFX/2
    local volume = subVolume
    tempSound:setVolume(volume)

    tempSound:play()
end


local loopingSounds = {}
function audioManager.newLoopingSound(name, sound, catagory, volume)
    loopingSounds[name] = {}

    --create the sound from either a table (pick random) or sound
    if type(sound) == "table" then
        loopingSounds[name].sound = sound[math.random(1,#sound)]:clone()
    else
        loopingSounds[name].sound = sound:clone()
    end

    -- modify volume
    local subVolume = (volume or 1) * settings.SFX/2

    local volume = subVolume
    loopingSounds[name].volume = volume

    loopingSounds[name].sound:setVolume(volume)
    loopingSounds[name].sound:setLooping(true)
    loopingSounds[name].sound:play()
end


function audioManager.modifyLoopingSound(name, data)
    if not loopingSounds[name] then
        return
    end
    for key, value in pairs(data) do
        loopingSounds[name][key] = value

        if key == "volume" or key == "catagory" then
            local subVolume = (value or 1) * settings.SFX/2

            local volume = subVolume
            loopingSounds[name].volume = volume
            loopingSounds[name].sound:setVolume(volume)

            --print(name, volume, value)
        elseif key == "pitch" then
            local subVolume = value or 1
            loopingSounds[name].sound:setPitch(subVolume)
        elseif key == "speed" then
            local subVolume = value or 1
            loopingSounds[name].sound:set(subVolume)
        end
    end
end


function audioManager.removeLoopingSound(name)
    if loopingSounds[name] and loopingSounds[name].sound then 
        loopingSounds[name].sound:stop()
        loopingSounds[name] = nil
    end
end





--music = {} --table for music functions and variables


local musicTracks = {}
local musicTargets = {}
local crossFadeSpeed = 1
local masterTrack


function audioManager.unloadBackgroundMusic()
    if musicTracks then
        for i = 1, #musicTracks do
            musicTracks[i].track:stop()
        end
    end

    musicTracks = {} --this MUST be nil and not empty table!! for now.
    musicTargets = {} --this MUST be nil and not empty table!! for now.
end


function audioManager.addBackgroundTrack(path, name, target)
    musicTracks[name] = love.audio.newSource(path, "static")
    musicTracks[name]:setVolume(0.0001)
    musicTargets[name] = target or 1

    if not masterTrack then
        masterTrack = name
    end
end


function audioManager.beBackgroundQuite(dt, abrupt)
    if musicTargets then
        for key, value in pairs(musicTargets) do
            musicTargets[key] = 0
        end

        if abrupt then
            for key, value in pairs(musicTracks) do
                musicTracks[key]:setVolume(0.001)
            end
        end
    end
end

function audioManager.setTargets(data)
    for key, value in pairs(data) do
        if musicTargets[key] then
            musicTargets[key] = value
        end
    end
end


function audioManager.manageBackground(dt)
    if musicTracks[masterTrack] then
        if settings.music == 0 then
            if musicTracks[masterTrack]:isPlaying() then
                for key, value in pairs(musicTracks) do
                    musicTracks[key]:stop()
                end
            end
        else

            if not musicTracks[masterTrack]:isPlaying() then
                for key, value in pairs(musicTracks) do
                    musicTracks[key]:play()
                end
            end

            for key, value in pairs(musicTracks) do
                local target = musicTargets[key] * 0.5 * settings.music/4
                local current = musicTracks[key]:getVolume()
                local diff = target - current
                
                musicTracks[key]:setVolume(quindoc.clamp(current + quindoc.sign(diff) * dt * crossFadeSpeed, 0.001,1))
            end
        end
    end
end