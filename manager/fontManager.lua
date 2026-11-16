fontManager = {}

local fonts = {}
local fontLookUp = {}


function fontManager.loadFont(location, name)
    fontLookUp[name] = location
end


function fontManager.get(name, size)
    if not (size and size) then
        error("Font Manager expected name and size got " .. name .. " " .. size)
    end

    -- create the fonttable if required
    if not fonts[name] then
        if fontLookUp[name] then
            fonts[name] = {}
        else
            error(name .. " is not a valid loaded font name")
        end
    end

    -- create the font size if required
    local sizeInt = math.floor(size)

    if not fonts[name][sizeInt] then
        fonts[name][sizeInt] = love.graphics.newFont(fontLookUp[name], sizeInt)
    end

    return fonts[name][sizeInt]
end


function fontManager.set(name, size)
    love.graphics.setFont(fontManager.get(name, size))
end