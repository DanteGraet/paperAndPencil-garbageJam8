local level = {}

-- viewing time in secconds
level.time = 60

function level.loadObjects()
    objectManager.flush()

    objectManager.load("object/chess/chessPiece.lua", "chessPiece")
end


function level.generateObjects()
    local o = {}

    for x = 1,5 do
        for y = 1, 3 do
            local obj = objectManager.getRandom():new(-50 + x*250, -25 + y*250)

            -- only using sx for consistantcy or something
            obj.sx = 250/(obj.ox*2)
            obj.sy = 250/(obj.ox*2)

            obj.r = math.random(-100, 100)/200

            table.insert(o, obj)
        end
    end

    return o
end


return level