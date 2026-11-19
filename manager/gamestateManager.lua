local gamestateFolder = "code/gamestate/"
local initialGamestate = "splash"
local eventPriority = 0

gamestateManager = {}
local gamestate = {}
local scheduledGamestate

function gamestateManager.setGamestate(name, ...)
    scheduledGamestate = {name, {...}}
end


function gamestateManager.getGamestate()
    return gamestate._name
end

function gamestateManager.get()
    return gamestate
end



local function createEventFunctions()
    for key, value in pairs(gamestate) do
        if type(value) == "function" and not gamestateManager[key] then

            gamestateManager[key] = function(a, b, c, d, e, f)
                if gamestate[key] then 
                    return gamestate[key](a, b, c, d, e, f)
                end
            end

            addEvent(key, gamestateManager[key], eventPriority)
        end
    end
end


function gamestateManager.update(dt)
    if scheduledGamestate then
        if gamestate.unload then gamestate.unload() end

        gamestate = require(gamestateFolder .. scheduledGamestate[1])

        createEventFunctions()

        gamestate._name = key

        if gamestate.load then
            gamestate.load(unpack(scheduledGamestate[2]))
        end

        scheduledGamestate = nil
    end

    if gamestate then
        return gamestate.update(dt)
    end
end


addEvent("update", gamestateManager.update, eventPriority)

gamestateManager.setGamestate(initialGamestate)