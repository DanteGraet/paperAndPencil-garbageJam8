-- hey it's the paper (& pencil from the theme)
-- Prehapse do velocity stuff to make erase larger (QOL)

ObjectManager = {}
ObjectManager.__index = ObjectManager


setmetatable(ObjectManager, {
    __call = function(self)
        return self:new(width)
    end
})


local function pickRandom(kvTable)
    local keyList = {}
    for key, value in pairs(kvTable) do
        table.insert(keyList, key)
    end

    return kvTable[keyList[math.random(1, #keyList)]]
end


function ObjectManager:new()
    local obj = {}

    obj.objects = {}
    obj.taggedList = {}


    setmetatable(obj, {
        __index = ObjectManager,
    })


    return obj
end


function ObjectManager:flush()
    self.objects = {}
    self.taggedList = {}
end

function ObjectManager:load(filePath, name, tags)
    local obj = love.filesystem.load(filePath)()

    self.objects[name] = obj

    if tags then
        for i = 1, #tags do
            tag = tags[i]

            if not self.taggedList[tag] then
                self.taggedList[tag] = {}
            end

            table.insert(self.taggedList[tag], obj)
            
        end
    end
end

function ObjectManager:getRandom(tag)
    if tag ~= nil then
        return pickRandom(self.taggedList[tag])
    else
        return pickRandom(self.objects)
    end
end

function ObjectManager:get(name)
    return self.objects[name]
end