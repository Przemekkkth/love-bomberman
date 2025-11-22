Special = Object:extend()
Special.repr = "'s'"

function Special:new(game, image, name, row_num, col_num)
    self.GAME = game
    self.name = name

    self.row = row_num
    self.col = col_num

    self.x = self.col * SIZE
    self.y = (self.row * SIZE) + Y_OFFSET

    self.image = image
    self.power_up_activate = {bomb_up = function(player) self:bomb_up_special(player) end,
                              fire_up = function(player) self:fire_up_special(player) end,
                              speed_up = function(player) self:speed_up_special(player) end,
                              wall_hack = function(player) self:wall_hack_special(player) end,
                              remote = function(player) self:remote_special(player) end,
                              bomb_pass = function(player) self:bomb_hack_special(player) end,
                              flame_pass = function(player) self:flame_pass_special(player) end,
                              invincible = function(player) self:invincible_special(player) end,
                              exit = function(player) self:end_stage(player) end}
    self.GAME.level_matrix[self.row + 1][self.col + 1] = Special.repr

    if self.name == 'exit' then
        self.score = 1000
    else
        self.score = 500    
    end
end

function Special:update()
    local isCollidedWithPlayer = self.x < self.GAME.player.x + SIZE and 
                                 self.GAME.player.x < self.x + SIZE and 
                                 self.y < self.GAME.player.y + SIZE and self.GAME.player.y < self.y + SIZE
    if isCollidedWithPlayer then
        self.power_up_activate[self.name](self.GAME.player)
        self.GAME.player:update_score(self.score)
        if self.name == 'exit' then
            self.GAME:stop_music()
            self.GAME.level = self.GAME.level + 1
            gotoRoom('StageRoom')
            return
        end
        self.GAME.ASSETS.sounds['special.wav']:play()
        self:destroy()
    end
end

function Special:draw(x_offset)
    love.graphics.draw(self.image.spritesheet, self.image.quad, self.x - x_offset, self.y, 0, SCALE_FACTOR, SCALE_FACTOR)
end

function Special:destroy()
    for index, value in ipairs(self.GAME.groups.special) do
        if value == self then
            table.remove(self.GAME.groups.special, index)
        end
    end

    self.GAME.level_matrix[self.row + 1][self.col + 1] = '_'
end

--[[Increase the player's bomb limit]]
function Special:bomb_up_special(player)
    player.bomb_limit = player.bomb_limit + 1
end

--[[Increase the Bombs Power]]
function Special:fire_up_special(player)
    player.power = player.power + 1
end

--[[Increase the speed of the player]]
function Special:speed_up_special(player)
    player.speed = player.speed + 1
end

--[[Turn on the player wall hack]]
function Special:wall_hack_special(player)
    player.wall_hack = true
end

--[[Turn on the remote detonate ability]]
function Special:remote_special(player)
    player.remote = true
end

--[[Turn on the ability to ignore bomb blasts]]
function Special:bomb_hack_special(player)
    player.bomb_hack = true
end

--[[Turn on the ability to ignore bomb blasts]]
function Special:flame_pass_special(player)
    player.flame_pass = true
end

--[[Turn on the players invincibility]]
function Special:invincible_special(player)
    player.invincibility = true
    player.invincibility_timer = love.timer.getTime() * 1000
end

function Special:end_stage()
    if #self.GAME.groups.enemy > 0 then
        return
    end

    self.GAME:next_stage()
end

--[[Action to take is special item is hit by an explosion]]
function Special:hit_by_explosion()
    local enemies = {}
    for i=1, 10 do
        table.insert(enemies, SPECIAL_CONNECTIONS[self.name])
    end

    self.GAME:insert_enemies_into_level(self.GAME.level_matrix, enemies)
end