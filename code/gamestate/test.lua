local g = {}

function g.load()
    print("LAODING")
end

function g.update()

end

function g.draw()
    love.graphics.setColor(1,1 ,1)
    love.graphics.circle("fill", 100, 100, 100)
end

return g