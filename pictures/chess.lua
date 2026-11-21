local level = {}

-- viewing time in secconds
level.time = 45

local missingPeices = {}
local board = {}

local objectManager = ObjectManager()

function level.loadObjects()
    objectManager:flush()

    objectManager:load("object/chess/chessPiece.lua", "chessPiece")
end

local function posToCords(x, y)
    local nx = 100*(x) + 250
    local ny = 100*(y-0.5) + 75

    return nx, ny
end

local function removeRandom(t)
    local i = math.random(1, #t)
    table.insert(missingPeices, t[i])
    table.remove(t, i)
end

local function getPos(piece)
    local pieceType = piece:sub(1, 1)
    local colour = piece:sub(2, 2)

    local x, y = math.random(1, 8), math.random(1, 8)

    if pieceType == "K" then
        y = (math.random(1, 10) == 1 and 2) or 1
    end
    if pieceType == "R" then
        if math.random(1, 2) == 1 then
            y = 1
        end
    end
    if pieceType == "N" then
        local x2, y2 = math.random(1, 8), math.random(1, 8)
        if math.abs(x - 4.5) > math.abs(x2 - 4.5) then
            x = x2
        end
        if math.abs(y - 4.5) > math.abs(y2 - 4.5) then
            y = y2
        end
    end
    if pieceType == "P" then
        y = math.max(y - math.random(1, 8), 2)
    end

    if colour == "w" then
        y = 9 - y
    end

    return x, y
end

local function nextPeice(pieces, board)
    local i = math.random(1, #pieces[1])
    local p = pieces[1][i]

    local x, y = getPos(p)
    local obj

    if board[x][y] == "" then
        board[x][y] = p
        local nx, ny = posToCords(x, y)
        obj = objectManager:get("chessPiece"):new(objectManager, nx, ny, p, 100)
    else
        table.insert(missingPeices, p)
    end

    table.remove(pieces[1], i)
    if #pieces[1] == 0 then
        table.remove(pieces, 1)
    end

    return obj
end


function level.generateObjects()
    local o = {}
    board = {}

    for x = 1, 8 do
        table.insert(board, {})
        for y = 1, 8 do
            board[x][y] = ""
        end
    end

    local whitePeices = {
        {"Kw"},     -- King
        {"Qw", "Rw", "Rw"},         -- Major pieces
        {"Bw", "Bw", "Nw", "Nw"},         -- Minor
        {"Pw", "Pw", "Pw", "Pw", "Pw", "Pw", "Pw", "Pw"},         -- Pawns
    }
    for i = 1, math.random(1, 2) do
        removeRandom(whitePeices[2])
    end
    for i = 1, math.random(2, 3) do
        removeRandom(whitePeices[3])
    end
    for i = 1, math.random(3, 5) do
        removeRandom(whitePeices[4])
    end
    local blackPeices = {
        {"Kb"},     -- King
        {"Qb", "Rb", "Rb"},         -- Major pieces
        {"Bb", "Bb", "Nb", "Nb"},         -- Minor
        {"Pb", "Pb", "Pb", "Pb", "Pb", "Pb", "Pb", "Pb"},         -- Pawns
    }
    for i = 1, math.random(1, 2) do
        removeRandom(blackPeices[2])
    end
    for i = 1, math.random(2, 3) do
        removeRandom(blackPeices[3])
    end
    for i = 1, math.random(2, 5) do
        removeRandom(blackPeices[4])
    end

    --if #whitePeices > then
    local obj
    for i = 1, 16 do
        if #whitePeices > 0 then
            obj = nextPeice(whitePeices, board)
            if obj then
                table.insert(o, obj)
            end
        end

        if #blackPeices > 0 then
            obj = nextPeice(blackPeices, board)
            if obj then
                table.insert(o, obj)
            end
        end
    end

  
    return o, nil, love.graphics.newImage("object/background/chess.png")
end

function level.permutate(objects)
    local changes = {}

    local choices = {}
    for i = 1,#objects do
        if objects[i].permutate and objects[i].x > 0 and objects[i].x < 1400 then
            table.insert(choices, i)
        end
    end

    local changesToMake = math.random(3, 5)
    for i = 1, math.min(16, #choices) do        --16 attempts
        if #missingPeices > 0 and  math.random(1, 3) == 1 then 
            local obj = nextPeice({missingPeices}, board)
            obj.hasMutated = true

            table.insert(objects, obj)
            changesToMake = changesToMake - 1
        else
            local r = math.random(1, #choices)
            local obj = objects[choices[r]]

            if math.random(1, 4) == 1 then
                obj.variant = "blank"

                obj.hasMutated = true
                changesToMake = changesToMake - 1
            else
                local i = math.random(1, #missingPeices)

                if missingPeices[i] ~= obj.variant then
                    obj.variant = missingPeices[i]
                    obj:updateImage()
                    changesToMake = changesToMake - 1
                end
            end

        end

        if changesToMake <= 0 then
            break
        end
    end

    return changes
end

return level