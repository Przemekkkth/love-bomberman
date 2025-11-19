require 'love.gamesettings'

FireBall = Object:extend()
FireBall.repr = "'f'"

function FireBall:new(game, image_list, row_num, col_num, direction)
    self.GAME = game
    self.row_num = row_num
    self.col_num = col_num

    self.x = self.col_num * SIZE
    self.y = (self.row_num * SIZE) + Y_OFFSET

    self.index = 1
    self.anim_frame_time = 75
    self.anim_timer = love.timer.getTime() * 1000
    self.image_list = image_list
    self.image = self.image_list[self.index]
    self.passable = false
    self.direction = direction
end

function FireBall:update()
    self:animate()
end

function FireBall:draw(offset)
    if self.direction == 'right_end' or self.direction == 'down_end' then
        love.graphics.draw(self.image.spritesheet, self.image.quad, self.x - offset - SIZE, self.y - SIZE, math.pi, SCALE_FACTOR, SCALE_FACTOR, SIZE / 2, SIZE / 2)
    else
        love.graphics.draw(self.image.spritesheet, self.image.quad, self.x - offset, self.y, 0, SCALE_FACTOR, SCALE_FACTOR)
    end
end

function FireBall:animate()
    local current_time = love.timer.getTime() * 1000
    if current_time - self.anim_timer > self.anim_frame_time then
        self.index = self.index + 1
        if self.index >= #self.image_list then
            self:remove_from_grid()
            return
        end

        self.image = self.image_list[self.index]
        self.anim_timer = current_time
    end
end

--[[Removes the explosion object from the level matrix]]
function FireBall:remove_from_grid()
    self.GAME.level_matrix[self.row_num + 1][self.col_num + 1] = '_'
    for index, value in ipairs(self.GAME.groups.fireball) do
        if self.row_num == value.row_num and self.col_num == value.col_num then
            table.remove(self.GAME.groups.fireball, index)
        end
    end
end