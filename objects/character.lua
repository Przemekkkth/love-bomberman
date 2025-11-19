require 'love.objects.bomb'

Character = Object:extend()

function Character:new(game, image_dict, row_num, col_num)
    self.GAME = game

    -- Level Matrix Position
    self.row_num = row_num
    self.col_num = col_num

    self:set_player(image_dict)
    self.lives = 3
    self.score = 0
end

function Character:input()
    if input:pressed('ESCAPE') then
        love.event.quit()
    end

    if input:pressed('LEFT') or input:down('LEFT') then
        self:move('walk_left')
    elseif input:pressed('RIGHT') or input:down('RIGHT') then
        self:move('walk_right')
    elseif input:pressed('UP') or input:down('UP') then
        self:move('walk_up')
    elseif input:pressed('DOWN') or input:down('DOWN') then
        self:move('walk_down')
    end

    if input:pressed('BOMB') then
        local row = math.floor((self.y + SIZE/2 - Y_OFFSET)/SIZE)
        local col = math.floor((self.x + SIZE/2)/SIZE)
        if self.GAME.level_matrix[row+1][col+1] == '_' and self.bombs_planted < self.bomb_limit then
            local bomb = Bomb(self.GAME, self.GAME.ASSETS.bomb['bomb'], row, col)
            table.insert(self.GAME.groups.bomb, bomb)
        end
    end

    if input:pressed('DETONATE') and self.remote and #self.GAME.groups.bomb > 0 then
        self.GAME.groups.bomb[#self.GAME.groups.bomb]:explode()
    end
end

function Character:update()
    if self.invincibility == false then
        if #self.GAME.groups.explosion or #self.GAME.groups.fireball and self.flame_pass == false then
            self:deadly_collisions(self.GAME.groups.explosion)
            self:deadly_collisions(self.GAME.groups.fireball)
        end
    end

    --Perform collision detection with enemies
    self:deadly_collisions(self.GAME.groups.enemy)

    -- play death animation
    if self.action == 'dead_anim' then
        self:animate(self.action)
    end

    if not self.invincibility then
        return
    end

    if love.timer.getTime() - self.invincibility_timer >= 20000 then
        self.invincibility = false
        self.invincibility_timer = nil
    end
end

function Character:draw(offset)
    love.graphics.draw(self.image.spritesheet, self.image.quad, self.x - offset, self.y, 0, SCALE_FACTOR, SCALE_FACTOR)
    --love.graphics.setColor(1, 0, 0)
    --love.graphics.rectangle("line", self.x - offset, self.y, SIZE, SIZE)
    love.graphics.setColor(1, 1, 1)
end

--[[Handle the movement and animations of the character]]
function Character:move(action)
    --  if player not alive, do not move
    if not self.alive then
        return
    end

    --  Check if the action is different to the current self.action, reset the index num to 0
    if action ~= self.action then
        self.action = action
        self.index = 1
    end

    local direction = {walk_left = -self.speed, walk_right = self.speed, walk_up = -self.speed, walk_down = self.speed}

    --  Change the player x and y coords based on the action argument
    if action == "walk_left" or action == "walk_right" then
        self.x = self.x + direction[action]
    elseif action == "walk_up" or action == "walk_down" then
        self.y = self.y + direction[action]
    end

    if love.timer.getTime() * 1000 - self.walk_sound_timer >= 200 then
        if self.action == 'walk_left' or self.action == 'walk_right' then
            self.GAME.ASSETS.sounds['walk_lr.wav']:play()
        elseif self.action == 'walk_up' or self.action == 'walk_down' then
            self.GAME.ASSETS.sounds['walk_ud.wav']:play()
        end
        self.walk_sound_timer = love.timer.getTime() * 1000
    end

    --
    self:animate(action)
    --
    -- Snap the player to grid coordinates, making navigation easier
    self:snap_to_grid(action)
    -- Check if x, y position is iwthin game area
    self:play_area_restriction(SIZE, (COLS - 1) * SIZE, Y_OFFSET + SIZE, ((ROWS-1) * SIZE) + Y_OFFSET)

    self:collision_detection_items(self.GAME.groups.hard_block)

    if self.wall_hack == false then
        self:collision_detection_items(self.GAME.groups.soft_block)
    end

    if self.bomb_hack == false then
        self:collision_detection_items(self.GAME.groups.bomb)
    end

    -- Update the Game Camera X Pos with player x Position
    self.GAME:update_x_camera_offset_player_position(self.x)
end

function Character:animate(action)
    local current_time = love.timer.getTime() * 1000

    if current_time - self.anim_time_set >= self.anim_time then
        self.index = self.index + 1
        if self.index >= #self.image_dict[action] then
            self.index = 1
            if self.action == "dead_anim" then
                self:reset_player()
                return
            end

        end
        
        self.image = self.image_dict[action][self.index]
        self.anim_time_set = current_time
    end
end

function Character:collision_detection_items(item_list)
    for _, item in ipairs(item_list) do
        local isCollision = self.x < item.x + SIZE and item.x < self.x + SIZE and self.y < item.y + SIZE and item.y < self.y + SIZE
        if isCollision and item.passable == false then
            if self.action == "walk_right" then
                if self.x + SIZE > item.x then
                    self.x = item.x - SIZE
                    return
                end
            end
            if self.action == "walk_left" then
                if self.x < item.x + SIZE then
                    self.x = item.x + SIZE
                    return
                end
            end
            if self.action == "walk_up" then
                if self.y < item.y + SIZE then
                    self.y = item.y + SIZE
                    return
                end
            end
            if self.action == "walk_down" then
                if self.y + SIZE > item.y then
                    self.y = item.y - SIZE
                end
            end
        end
    end
end

function Character:trigger_detection_items(item_list)
    for _, item in ipairs(item_list) do
        local isCollision = self.x < item.x + SIZE and item.x < self.x + SIZE and self.y < item.y + SIZE and item.y < self.y + SIZE
        if isCollision then
            if self.action == "walk_right" then
                if self.x + SIZE > item.x then
                    return true
                end
            end
            if self.action == "walk_left" then
                if self.x < item.x + SIZE then
                    return true
                end
            end
            if self.action == "walk_up" then
                if self.y < item.y + SIZE then
                    return true
                end
            end
            if self.action == "walk_down" then
                if self.y + SIZE > item.y then
                    return true
                end
            end
        end
    end
    return false
end

--[[Snap the player to grid coordinates, making navigation easier]]
function Character:snap_to_grid(action)
    local x_pos = self.x % SIZE
    local y_pos = (self.y - Y_OFFSET) % SIZE
    if action == "walk_down" or action == "walk_up" then
        if x_pos <= SNAP_SIZE then
            self.x = self.x - x_pos
        end
        if x_pos >= SIZE - SNAP_SIZE then
            self.x = self.x + (SIZE - x_pos)
        end
    elseif action == "walk_left" or action == "walk_right" then
        if y_pos <= SNAP_SIZE then
            self.y = self.y - y_pos
        end
        if y_pos >= SIZE - SNAP_SIZE then
            self.y = self.y + (SIZE - y_pos)
        end
    end
end

--[[Check player coords to ensure remains within play area]]
function Character:play_area_restriction(left_x, right_x, top_y, bottom_y)
    if self.x < left_x then
        self.x = left_x
    elseif self.x > right_x then
        self.x = right_x
    elseif self.y < top_y then
        self.y = top_y
    elseif self.y > bottom_y then
        self.y = bottom_y
    end
end

function Character:set_player_position()
    self.x = self.col_num * SIZE
    self.y = (self.row_num * SIZE) + Y_OFFSET
end

function Character:set_player_images()
    self.image = self.image_dict[self.action][self.index]
end

function Character:set_player(image_dict)
    self:set_player_position()
    self.alive = true
    self.speed = 3
    self.bomb_limit = 2
    self.remote = false
    self.power = 1
    self.wall_hack = false
    self.bomb_hack = false
    self.flame_pass = false
    self.invincibility = false
    self.invincibility_timer = nil
    self.action = 'walk_right'
    self.bombs_planted = 0
    self.index = 1
    self.anim_time = 150
    self.anim_time_set = love.timer.getTime() * 1000
    self.image_dict = image_dict
    self.walk_sound_timer = love.timer.getTime() * 1000
    self:set_player_images()
end

function Character:reset_player()
    self.lives = self.lives - 1
    if self.lives <= 0 then
        self.GAME:stop_music()
        gotoRoom('Title')
        return
    end

    self.GAME:regenerate_stage()
    self:set_player(self.image_dict)
end

function Character:deadly_collisions(group)
    if not self.alive then
        return
    end  

    if self:trigger_detection_items(group) then
        self.action = 'dead_anim'
        self.alive = false
--      self.GAME.bg_music.stop()
--      self.GAME.bg_music_special.stop()
        self.GAME.ASSETS.sounds['dead.wav']:play()

    end
end

--[[Update the player score]]
function Character:update_score(score)
    self.score = self.score + score
end
