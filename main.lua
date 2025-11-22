require 'gamesettings'
Object = require 'libraries.Classic'
Input = require 'libraries.Input'

require 'objects.bomberman'
bomberman = BomberMan()

require 'rooms.title'
require 'rooms.gameroom'
require 'rooms.stage'


function love.load(arg)
    input = Input()

    input:bind('left',   'LEFT')
    input:bind('right',  'RIGHT')
    input:bind('up',     'UP')
    input:bind('down',   'DOWN')
    input:bind('escape', 'ESCAPE')
    input:bind('space', 'BOMB')
    input:bind('z', 'DETONATE')
    input:bind('e', 'ENTER')
    input:bind('return', 'ENTER')
    input:bind('enter', 'ENTER')
    input:bind('n', 'NEXT_LEVEL')
    input:bind('backspace', 'TITLE')

    current_room = nil
    gotoRoom('Title')
end

function love.update(dt)
    if current_room then 
        current_room:update(dt) 
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(WINDOW_SIZE_SCALE)
    if current_room then 
        current_room:draw() 
    end
    love.graphics.pop()
end

function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/FPS
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        --bomberman:input()

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

function gotoRoom(room_type, ...)
    current_room = _G[room_type](...)
end