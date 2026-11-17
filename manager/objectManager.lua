objectManager = {}

local objects = {}
local taggedList = {}

local function pickRandom(kvTable)
    local keyList = {}
    for key, value in pairs(kvTable) do
        table.insert(keyList, key)
    end

    return kvTable[keyList[math.random(1, #keyList)]]
end

function objectManager.flush()
    objects = {}
    taggedList = {}
end

function objectManager.load(filePath, name, tags)
    print(filePath)
    local obj = love.filesystem.load(filePath)()

    objects[name] = obj

    if tags then
        for i = 1, #tags do
            tag = tags[i]
            taggedList[i] = objects[name]
        end
    end
end

function objectManager.getRandom(tag)
    if tag ~= nil then
        return pickRandom(taggedList[tag])
    else
        return pickRandom(objects)
    end
end