require 'gamesettings'
require 'objects.scoring'

Enemy = Object:extend()

function Enemy:new(game, image_dict, type, row_num, col_num)
    self.GAME = game
    self.type = type

    -- Attributes (dependent on our enemy type)
    self.speed = ENEMIES[self.type].speed
    self.wall_hack = ENEMIES[self.type].wall_hack
    self.chase_player = ENEMIES[self.type].chase_player
    self.LoS = ENEMIES[self.type].LoS * SIZE
    self.see_player_hack = ENEMIES[self.type].see_player_hack

    self.row = row_num
    self.col = col_num

    self.x = self.col * SIZE
    self.y = (self.row * SIZE) + Y_OFFSET

    self.destroyed = false
    self.direction = 'left'
    self.dir_mvmt = {
        left = -self.speed, 
        right = self.speed, 
        up = -self.speed, 
        down = self.speed
    }
    self.change_dir_timer = love.timer.getTime() * 1000
    self.dir_time = 4000

    self.index = 1
    self.action = 'walk_'..self.direction
    self.image_dict = image_dict
    self.anim_frame_time = 100
    self.anim_timer = love.timer.getTime() * 1000

    self.image = self.image_dict[self.action][self.index]

    self.start_pos = {
        self.x + SIZE/2,
         self.y + SIZE/2
    }
    self.end_pos = {
        self.GAME.player.x + SIZE/2, 
        self.GAME.player.y + SIZE/2
    }
end

function Enemy:update()
    self:move()
    self:animate()
    self:update_line_of_sight_with_player()
    if self:trigger_detection_items(self.GAME.groups.fireball) and not self.destroyed then
        self:destroy()
        self.destroyed = true
    end
end

function Enemy:draw(offset)
    love.graphics.draw(self.image.spritesheet, self.image.quad, self.x - offset, self.y, 0, SCALE_FACTOR, SCALE_FACTOR)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1,1,1)
end

--[[Method that incorporates all movement conditions to enable the enemy to move around]]
function Enemy:move()
    if self.destroyed then
        return
    end

    -- Move enemy along the x or y axis, dependent on move direction
    local move_direction = self.action:match('_(.+)')
    if move_direction == 'left' or move_direction == 'right' then
        self.x = self.x + self.dir_mvmt[move_direction]
    else
        self.y = self.y + self.dir_mvmt[move_direction]
    end

    local directions = {
        "left",
        "right", 
        "up", 
        "down"
    }

    self:new_direction(self.GAME.groups.hard_block, directions)

    if self.wall_hack == false then
        self:new_direction(self.GAME.groups.soft_block, directions)
    end

    self:new_direction(self.GAME.groups.bomb, directions)

    if self.chase_player then
        local blocked = false
    
        if self:check_LoS_distance() then
            blocked = true
        elseif self:intersecting_items_with_LoS(self.GAME.groups.hard_block, self.start_pos, self.end_pos) then
            blocked = true
        elseif self:intersecting_items_with_LoS(self.GAME.groups.soft_block, self.start_pos, self.end_pos) and not self.see_player_hack then
            blocked = true
        elseif self:intersecting_items_with_LoS(self.GAME.groups.bomb, self.start_pos, self.end_pos) and not self.see_player_hack then
            blocked = true
        end
    
        if not blocked then
            self:chase_the_player()
        end
    end
    
    self:change_directions(directions)
end

function Enemy:collision_detection_items(item_list)
    for _, item in ipairs(item_list) do
        local isCollision = self.x < item.x + SIZE and item.x < self.x + SIZE and self.y < item.y + SIZE and item.y < self.y + SIZE
        if isCollision and item.passable == false then
            if self.action == "walk_right" then
                if self.x + SIZE > item.x then
                    self.x = item.x - SIZE
                    return 'right'
                end
            end
            if self.action == "walk_left" then
                if self.x < item.x + SIZE then
                    self.x = item.x + SIZE
                    return 'left'
                end
            end
            if self.action == "walk_up" then
                if self.y < item.y + SIZE then
                    self.y = item.y + SIZE
                    return 'up'
                end
            end
            if self.action == "walk_down" then
                if self.y + SIZE > item.y then
                    self.y = item.y - SIZE
                    return 'down'
                end
            end
        end
    end
    return nil
end

function Enemy:trigger_detection_items(item_list)
    for _, item in ipairs(item_list) do
        local isCollision = self.x < item.x + SIZE and item.x < self.x + SIZE and self.y < item.y + SIZE and item.y < self.y + SIZE
        if isCollision and item.passable == false then
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

function Enemy:new_direction(item_list, directions)
    local dir = self:collision_detection_items(item_list)
    if dir then
        for index, value in ipairs(directions) do
            if dir == value then
                table.remove(directions, index)
            end
            
            if #directions > 0 then
                local new_direction = directions[love.math.random(1, #directions)]
                self.action = 'walk_'..new_direction
            end
        end
    end
end

--[[Randomly change directions after a set amount of time elapsed]]
function Enemy:change_directions(directions)
    local current_time = love.timer.getTime() * 1000
    if current_time - self.change_dir_timer < self.dir_time then
        return
    end

    -- if enemy coordinates do not align with the grid coordinates
    if (self.x % SIZE) ~= 0 or ((self.y - Y_OFFSET) % SIZE) ~= 0 then
        return
    end

    --local row = math.floor((self.y - Y_OFFSET) /)
    local row = math.floor((self.y - Y_OFFSET) / SIZE)
    local col = math.floor(self.x / SIZE)

    --  If cell at row/column is not a 4 way intersection, return out of the method
    if row % 2 == 0 and col % 2 == 0 then
        return
    end

    if self.wall_hack == false then
        self:determine_if_direction_valid(directions, row + 1, col + 1)
    end

    local new_direction = directions[love.math.random(1, #directions)]
    self.direction = new_direction
    self.action = 'walk_'..self.direction
    self.change_dir_timer = current_time
end

--[[Check the 4 directions to determine if move is possible]]
function Enemy:determine_if_direction_valid(directions, row, col)
    if self.GAME.level_matrix[row - 1][col] ~= '_' then
        for index, value in ipairs(directions) do
            if value == 'up' then
                table.remove(directions, index)
            end
        end
    end

    if self.GAME.level_matrix[row + 1][col] ~= '_' then
        for index, value in ipairs(directions) do
            if value == 'down' then
                table.remove(directions, index)
            end
        end
    end

    if self.GAME.level_matrix[row][col - 1] ~= '_' then
        for index, value in ipairs(directions) do
            if value == 'left' then
                table.remove(directions, index)
            end
        end
    end

    if self.GAME.level_matrix[row][col + 1] ~= '_' then
        for index, value in ipairs(directions) do
            if value == 'right' then
                table.remove(directions, index)
            end
        end
    end

    -- if directions list empty, input "left"
    if #directions == 0 then
        table.insert(directions, 'left')
    end

    return
end

--[[Cycle through the enemy animation images]]
function Enemy:animate()
    local current_time = love.timer.getTime() * 1000
    if current_time - self.anim_timer >= self.anim_frame_time then
        self.index = self.index + 1
        if self.destroyed and self.index == #self.image_dict[self.action] then
            for index, value in ipairs(self.GAME.groups.enemy) do
                if self == value then
                    table.remove(self.GAME.groups.enemy, index)
                end
            end
        end
        self.index = self.index % #self.image_dict[self.action] + 1
        self.image = self.image_dict[self.action][self.index]
        self.anim_timer = current_time
    end
end

--[[Deactivate the enemy when killed]]
function Enemy:destroy()
    self.destroyed = true
    self.index = 1
    self.action = 'death'
    self.image = self.image_dict[self.action][self.index]
    self.GAME.player:update_score(SCORES[self.type])
    Scoring(self.GAME, SCORES[self.type], self.x, self.y)
end

function Enemy:update_line_of_sight_with_player()
    self.start_pos = {self.x + SIZE/2, self.y + SIZE/2}
    self.end_pos = {self.GAME.player.x + SIZE/2, self.GAME.player.y + SIZE/2}
end

--[[Change the direction towards the player if in line of sight]]
function Enemy:chase_the_player()
    local enemy_col = math.floor(self.start_pos[1] / SIZE)
    local enemy_row = math.floor(self.start_pos[2] / SIZE)

    local player_col = math.floor(self.end_pos[1] / SIZE)
    local player_row = math.floor(self.end_pos[2] / SIZE)

    if enemy_col > player_col and ((self.y - Y_OFFSET) % SIZE) + SIZE / 2 == math.floor(SIZE / 2) then
        self.action = 'walk_left'
    elseif enemy_col < player_col and ((self.y - Y_OFFSET) % SIZE) + SIZE / 2 == math.floor(SIZE / 2) then
        self.action = 'walk_right'
    elseif enemy_row > player_row and (self.x % SIZE) + SIZE / 2 == math.floor(SIZE / 2) then
        self.action = 'walk_up'
    elseif enemy_row < player_row and (self.x % SIZE) + SIZE / 2 == math.floor(SIZE / 2) then
        self.action = 'walk_down'
    end

    -- Update the enemy char change direction timer
    self.change_dir_timer = love.timer.getTime() * 1000
end

--[[Return a True or False, if dist between player and enemy is less than LoS attribute]]
function Enemy:check_LoS_distance()
    local x_dist = math.abs(self.end_pos[1] - self.start_pos[1])
    local y_dist = math.abs(self.end_pos[2] - self.start_pos[2])

    if x_dist > self.LoS or y_dist > self.LoS then
        return true
    end

    return false
end

function Enemy:intersecting_items_with_LoS(group, start_pos, end_pos)
    for _, item in ipairs(group) do
        if self:rect_intersects_line(item.x, item.y, SIZE, SIZE, start_pos, end_pos) then
            return true
        end
    end
    return false
end

function Enemy:rect_intersects_line(rx, ry, rw, rh, p1, p2)
    local x1, y1 = rx, ry
    local x2, y2 = rx + rw, ry
    local x3, y3 = rx + rw, ry + rh
    local x4, y4 = rx, ry + rh

    return self:line_intersects_line(p1, p2, {x1, y1}, {x2, y2}) or
           self:line_intersects_line(p1, p2, {x2, y2}, {x3, y3}) or
           self:line_intersects_line(p1, p2, {x3, y3}, {x4, y4}) or
           self:line_intersects_line(p1, p2, {x4, y4}, {x1, y1})
end

function Enemy:line_intersects_line(p1, p2, p3, p4)
    local x1, y1 = p1[1] or p1.x, p1[2] or p1.y
    local x2, y2 = p2[1] or p2.x, p2[2] or p2.y
    local x3, y3 = p3[1] or p3.x, p3[2] or p3.y
    local x4, y4 = p4[1] or p4.x, p4[2] or p4.y

    local denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if denom == 0 then 
        return false 
    end

    local t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom
    local u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom

    return (t >= 0 and t <= 1) and (u >= 0 and u <= 1)
end