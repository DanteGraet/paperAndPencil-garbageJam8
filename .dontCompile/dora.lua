--                                                                                                                        
--                                                                            *,,*/####(*,,*                          
--                                                                        *,*%&(**,,,**#&@@@&/,*                      
--                                                                      **/**////////////*,/@@@&**                    
--                                                                     ,(**/////////(.(/////*/@@@%,                   
--                                                                    */,///////,.,@@@@%/////**@@@%,                  
--                                                                   .***/////*.........*/////*#@@@/,                 
--                                                                   /(**/////,.........*/////*#@@@/,                 
--                                                                   ./&,///////,.....,//////**@@#,*                  
--              /*,,**///**,*/                                        *&@**/////////////////,,,/                      
--          *,*&@#*,,*****,*#@@#*/                                     *@@@/,*////////*,,**                           
--       /,(@&**//////////////**&@#*                                    /*//**,**/,                                   
--     .,(@@**/////////*%@%/////*,&@#*                                                                                
--     ,#@&,///////,...&@@@&//////,%@@*.                                                                              
--     *@@(*//////..........,/////*/@@@*                                                                              
--    (/@@(*//////,.........*/////*/@@@(*                                                                             
--     *@@@**///////,.....*//////**&#**                             ,                                                 
--     //@@@(,//////////////////*,*                               ,,.                                                 
--      **@@@@#,*////////**,,/.                                 .                                                     
--        **///***,**/                                                                                                
--                                                                                                                    
--                                                                         *                                          
--                                                                       **                                           
--                                                                   *,/                                              
--                                        ,*,*                 **,/                                                   
--                                                //****/*                                                            
--                                                                                                                    
--                                                            ../**                                                   
--                                                                                                                                
--                                                                                                                                
--                                                                                                                                
--
--                     ┌─┐┬ ┬┌─┐┌─┐┬─┐  ┌─┐┬─┐┬┌┬┐┬┌┬┐┬┬  ┬┌─┐  ┌─┐─┐ ┬┌─┐┬  ┌─┐┬─┐┌─┐┬─┐
--                     └─┐│ │├─┘├┤ ├┬┘  ├─┘├┬┘│││││ │ │└┐┌┘├┤   ├┤ ┌┴┬┘├─┘│  │ │├┬┘├┤ ├┬┘
--                     └─┘└─┘┴  └─┘┴└─  ┴  ┴└─┴┴ ┴┴ ┴ ┴ └┘ └─┘  └─┘┴ └─┴  ┴─┘└─┘┴└─└─┘┴└─
                                           

dora = {
    isOpen = false,
}

local exclusionList = {
    _G,
    _VERSION,
    arg,
    assert,
    bit,
    collectgarbage,
    coroutine,
    dofile,
    gcinfo,
    getfenv,
    getmetatable,
    io,
    ipairs,
    jit,
    load,
    loadfile,
    loadstring,
    love,
    math,
    module,
    newproxy,
    next,
    os,
    package,
    pairs,
    pcall,
    print,
    rawequal,
    rawget,
    rawset,
    require,
    select,
    setfenv,
    setmetatable,
    string,
    table,
    tonumber,
    tostring,
    type,
    unpack,
    VERSION,
    xpcall,
}

local currentPath = {}
local currentTable
local search = ""
local edit = false
local text = ""
local currentRawTable
local scroll = 1
local fontSize = 16
local font = love.graphics.newFont(fontSize)
local selected = 0

local defaultPrint = print
local function print(text)
    defaultPrint("[Dora_SPE]: " .. text )
end

local function getPathString(path)
    local path = currentPath
    local string = "_G"
    for i = 1,#path do
        string = string .. "/" .. path[i]
    end

    return string
end

local function noQuantumEntanglememt(table)
    local temp = {}
    for key, value in pairs(table) do
        if type(table[key]) == "table" then
            temp[key] = noQuantumEntanglememt(table[key])
        else
            temp[key] = value
        end
    end

    return temp
end

local function getSelectedAtY(y)
    local fontHeight = font:getHeight()
    local mouseLocation = math.floor(y/fontHeight)
    
    if mouseLocation <= 1 then
        mouseLocation = mouseLocation - 1
    else
        mouseLocation = mouseLocation  - 2 + scroll
    end

    local count = 1
    for i = scroll, #currentTable do
        local t = currentTable[i]

        if string.find(string.lower(tostring(t.name)), string.lower(search)) then
        else
            mouseLocation = mouseLocation + 1
        end

        if mouseLocation == i then
            return mouseLocation
        end


        count = count + 1
    end

    return mouseLocation
end

local function getRawTable(path, currentTable)
    local currentTable = currentTable or _G

    if path and #path >= 1 then
        local newTable = currentTable[path[1]]
        table.remove(path, 1)
        
        return getRawTable(path, newTable)
    end

    return currentTable
end

local function getCurrentTable(path, currentTable)
    currentRawTable = getRawTable(noQuantumEntanglememt(path), currentTable)
    local finalTable = {}

    for key, value in pairs(currentRawTable) do
        
        for i = 1,#exclusionList do
            if currentRawTable[key] == exclusionList[i] then
                goto skipItem
            end
        end

        local tableEntry = {
            name = key,
            data = value,
            type = type(value)
        }
        table.insert(finalTable, tableEntry)

        ::skipItem::
    end

    local sortFunction = function(a, b)
        return a.name < b.name
    end

    table.sort(finalTable, sortFunction)

    return finalTable
end

function dora.keypressed(key)
    if key == "d" and love.keyboard.isDown("lctrl") then
        dora.isOpen = not dora.isOpen
        dora.load()
        return true
    end

    if dora.isOpen then
        if key == "backspace" then
            if edit == true then
                text = string.sub(text, 0, #text-1)
            else
                search = string.sub(search, 0, #search-1)
            end
        elseif key == "return" and edit then
            if currentTable[selected].type == "string" then
                currentRawTable[currentTable[selected].name] = text
                currentTable[selected].data = text
                print("Text: " .. currentTable[selected].name .. " -> " .. text)
            elseif currentTable[selected].type == "number" then
                if tonumber(text) then
                    currentRawTable[currentTable[selected].name] = tonumber(text)
                    currentTable[selected].data = tonumber(text)
                    print("Number: " .. currentTable[selected].name .. " -> " .. text)
                else
                    print(currentTable[selected].name .. " must be a number")
                end
            else
                print("Welp I have not coded in that data type yet so :(")
            end

            edit = false
        elseif key == "escape" then
            if edit == true then 
                edit = false
                search = ""
            elseif #currentPath >= 1 then
                table.remove(currentPath, #currentPath)
                dora.load()
            else
                dora.isOpen = false
            end
        end

    end

    return dora.isOpen
end

function dora.textinput(key)
    if dora.isOpen then
        if edit == true then
            text = text .. key
        else
            search = search .. key
        end

        scroll = 1
    end

    return dora.isOpen
end

function dora.wheelmoved(x, y)
    if dora.isOpen then

        if love.keyboard.isDown("lctrl") then
            fontSize = quindoc.clamp(fontSize + y, 1, 32)
            font = love.graphics.newFont(fontSize)
            dora.load()
        else
            scroll = quindoc.clamp(scroll - y, 1, #currentTable)
        end

        return true
    end

    return false
end

function dora.mousepressed(x, y)
    if dora.isOpen then
        edit = false
        selected = getSelectedAtY(y)
        if selected < 0 then
            scroll = 1
            table.remove(currentPath, #currentPath)
            dora.load()
            return true
        end
        if selected == 0 then
            return true
        end

        if currentTable[selected] then
            if currentTable[selected].type == "table" then
                scroll = 1
                search = ""
                table.insert(currentPath, currentTable[selected].name)
                dora.load()
            elseif currentTable[selected].type == "boolean" then
                currentRawTable[currentTable[selected].name] = not currentRawTable[currentTable[selected].name]
            elseif currentTable[selected].type == "function" then
                if love.keyboard.isDown("lctrl") then
                    local result = currentRawTable[currentTable[selected].name]()
                    print(currentTable[selected].name .. "() -> " .. tostring(result))
                else
                    print("Hold [lctrl] to run function " .. currentTable[selected].name)
                end

            else
                text = tostring(currentRawTable[currentTable[selected].name])
                edit = true
                print("Editing: " .. currentTable[selected].name .. " (" .. text .. ")")
            end
        end

        return true
    end

    return false
end

function dora.draw()
    love.graphics.origin()
    love.graphics.setColor(0, 0, 0, .5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setFont(font)
    love.graphics.setColor(1,1,1,1)
    local fontHeight = font:getHeight()

    love.graphics.print(getPathString())
    love.graphics.print("Search: " .. search, 0, fontHeight)

    local count = 1

    for i = scroll, #currentTable do
        local t = currentTable[i]

        if string.find(string.lower(tostring(t.name)), string.lower(search)) then

            local valueText
            local valueType = type(t.data)

            if valueType == "function" then
                valueText = "function"
            elseif valueType == "boolean" then
                valueText = (t.data and "true") or "false"
            elseif valueType == "table" then
                valueText = "{table}"
            else
                valueText = tostring(t.data)
            end

            if edit and i == selected then
                valueText = text
            end

            love.graphics.print(t.name .. " : " .. valueText, fontHeight, (count+1)*fontHeight)

            count = count + 1
        end
    end

   -- if scroll > count then
   --     scroll = count
   -- end
end


function dora.load()
    currentTable = getCurrentTable(currentPath)
end

dora.load()

addEvent("draw",            function() if dora.isOpen then dora.draw(); return true end end,                 10)
addEvent("keypressed",      function(key) 
                                if love.keyboard.isDown("lctrl") and key == "d" then
                                    dora.isOpen = not dora.isOpen
                                    return true
                                elseif dora.isOpen then 
                                    dora.keypressed(key)
                                    return true 
                                end 
                            end,     -10)
addEvent("textinput",       function(text) if dora.isOpen then dora.textinput(text); return true end end,    -10)
addEvent("wheelmoved",      function(x, y) if dora.isOpen then dora.wheelmoved(x, y); return true end end,   -10)
addEvent("mousepressed",    function(x, y) if dora.isOpen then dora.mousepressed(x, y); return true end end, -10)