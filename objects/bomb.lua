require 'love.gamesettings'
require 'love.objects.explosion'

Bomb = Object:extend()
Bomb.repr = "'!'"

function Bomb:new(game, image_list, row_num, col_num)
    self.GAME = game
    -- Level Matrix Position
    self.row = row_num
    self.col = col_num

    -- Coordinates
    self.x = self.col * SIZE
    self.y = (self.row * SIZE) + Y_OFFSET

    self.index = 1
    self.image_list = image_list
    self.image = self.image_list[self.index]

    --  Bomb Attributes
    self.bomb_counter = 1
    self.bomb_timer = 12
    self.passable = true

    --  Animation settings
    self.anim_length = #self.image_list
    self.anim_frame_time = 175
    self.anim_timer = love.timer.getTime() * 1000

    self.sound = love.audio.newSource('assets/sfx/plantbomb.wav', 'static')
    self.sound:play()
    self:insert_bomb_into_grid()
end

function Bomb:update()
    self:animate()
    self:planted_bomb_player_collision()
    if self.bomb_counter == self.bomb_timer then
        self:explode()
    end
end

function Bomb:draw(offset)
    love.graphics.draw(self.image.spritesheet, self.image.quad, self.x - offset, self.y, 0, SCALE_FACTOR, SCALE_FACTOR)
end

function Bomb:animate()
    local current_time = love.timer.getTime() * 1000

    if current_time - self.anim_timer >= self.anim_frame_time then
        self.index = self.index + 1
        if self.index >= self.anim_length then
            self.index = 1
        end
        
        self.image = self.image_list[self.index]
        self.anim_timer = current_time
        self.bomb_counter = self.bomb_counter + 1
    end
end


function Bomb:planted_bomb_player_collision()
    if not self.passable then
        return
    end

    if not (self.x < self.GAME.player.x + SIZE 
        and self.GAME.player.x < self.x + SIZE 
        and self.y < self.GAME.player.y + SIZE 
        and self.GAME.player.y < self.y + SIZE) then
            self.passable = false
    end 
end

--[[Removes the bomb object from the level matrix]]
function Bomb:remove_bomb_from_grid()
    self.GAME.level_matrix[self.row + 1][self.col + 1] = '_'
    self.GAME.player.bombs_planted = self.GAME.player.bombs_planted - 1
    for index, value in ipairs(self.GAME.groups.bomb) do
        if self == value then
            table.remove(self.GAME.groups.bomb, index)
        end
    end
end

--[[Destroy the bomb, and remove from the level matrix]]
function Bomb:explode()
    self:remove_bomb_from_grid()
    local explosion = Explosion(self.GAME, self.GAME.ASSETS.explosions, "centre", self.GAME.player.power, self.row, self.col, SIZE)
    table.insert(self.GAME.groups.explosion, explosion)
end

--[[Adds the bomb object to the level matrix]]
function Bomb:insert_bomb_into_grid()
    self.GAME.level_matrix[self.row + 1][self.col + 1] = Bomb.repr
    self.GAME.player.bombs_planted = self.GAME.player.bombs_planted + 1
    --self.GAME:print_level_matrix()
end