Vector2 = {}
Vector2.__index = Vector2


setmetatable(Vector2, {
    __call = function(self, scaleType, width, height, anchor)
        return self:new(scaleType, width, height, anchor)
    end
})


function Vector2:new(x, y)
    local obj = {}

    obj.x = x
    obj.y = y

    setmetatable(obj, {
        __call = function(self)
            return self.x, self.y
        end,

        __add = function(a, b)
            return Vector2:new(a.x + b.x, a.y + b.y)
        end,

        __sub = function(a, b)
            return Vector2(a.x - b.x, a.y - b.y)
        end,

        __unm = function(a)
            return Vector2(-a.x, -a.y)
        end,

        __mul = function(a, b)
            if type(a) == "number" then
                return Vector2(b.x * a, b.y * a)
            elseif type(b) == "number" then
                return Vector2(a.x * b, a.y * b)
            else
                return a.x * b.x + a.y * b.y
            end
        end,

        __len = function(a)
            return math.sqrt(a.x * a.x + a.y * a.y)
        end
    })

    return obj
end
