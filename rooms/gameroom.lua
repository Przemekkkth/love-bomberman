require 'objects.bomberman'
GameRoom = Object:extend()

function GameRoom:new()
    bomberman:generate_level()
end

function GameRoom:update(dt)
    bomberman:update()
    bomberman:input()
end

function GameRoom:draw()
    bomberman:draw()
end