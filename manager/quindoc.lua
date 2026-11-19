quindoc = {}
drawDebugRuler = false
if love.graphics then
    debug = love.graphics.newFont(16)
end

--Some stuff that i wished the math library had, and also some lazy tools.

function quindoc.pythag(x,y)
    return math.sqrt(x^2+y^2)
end

function quindoc.round(num,digits)
    num = num * 10^(digits or 0)
    num = math.floor(num + 0.5)
    num = num / 10^(digits or 0)
    return num
end

function quindoc.sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

function quindoc.numberLength(num)
    if num > 0 then
        return math.floor(math.log10(num)+1)
    else 
        return 1
    end
end

function quindoc.clamp(val, min, max)
    return math.max(min, math.min(val, max))
end