require 'love.gamesettings'
Title = Object:extend()

TITLE_SCREEN_IMG = love.graphics.newImage('assets/images/startscreen.png')
POINTER_IMG = love.graphics.newImage("assets/images/pointer.png")

function Title:new()
    self.point_position = {{460, 685}, {460, 750}}
    self.point_pos = 1
    self.ASSETS = bomberman.ASSETS
    self.music = self.ASSETS.music['BM-Title-Screen.wav']
    self.music:setLooping(true)
    self.music:play()
end

function Title:update(dt)
    if input:released('UP') then
        self.point_pos = self.point_pos - 1
        if self.point_pos < 1 then
            self.point_pos = 2
        end
    elseif input:released('DOWN') then
        self.point_pos = self.point_pos + 1
        if self.point_pos > 2 then
            self.point_pos = 1
        end
    elseif input:released('ENTER') then
        self.music:stop()
        if self.point_pos == 1 then
            bomberman:reset()
            gotoRoom('StageRoom')
        elseif self.point_pos == 2 then
            gotoRoom('StageRoom')
        end
    end
end

function Title:draw()
    love.graphics.draw(TITLE_SCREEN_IMG)
    love.graphics.draw(POINTER_IMG, self.point_position[self.point_pos][1], self.point_position[self.point_pos][2])
end