require 'objects.fireball'

Explosion = Object:extend()
Explosion.repr = "'e'"

function Explosion:new(game, image_dict, image_type, power, row_num, col_num)
    self.GAME = game

    -- Level Matrix Position
    self.row_num = row_num
    self.col_num = col_num

    -- Sprite Coordinates
    self.y = (self.row_num * SIZE) + Y_OFFSET
    self.x = self.col_num * SIZE

    -- Explosion image and animations
    self.index = 1
    self.anim_frame_time = 75
    self.anim_timer = love.timer.getTime() * 1000

    self.image_dict = image_dict
    self.image_type = image_type

    self.image = self.image_dict[self.image_type][self.index]
    
    -- Strength
    self.power = power
    self.passable = false

    self:calculate_explosive_path()
    self.GAME.level_matrix[self.row_num + 1][self.col_num + 1] = Explosion.repr
    self.sound = love.audio.newSource('assets/sfx/explosion.wav', 'static')
    self.sound:play()
end

function Explosion:update()
    self:animate()
end

function Explosion:draw(offset)
    love.graphics.draw(self.image.spritesheet, self.image.quad, self.x - offset, self.y, 0, SCALE_FACTOR, SCALE_FACTOR)
end

function Explosion:animate()
    local current_time = love.timer.getTime() * 1000
    if current_time - self.anim_timer > self.anim_frame_time then
        self.index = self.index + 1
        if self.index >= #self.image_dict[self.image_type] then
            self:remove_from_grid()
            return
        end

        self.image = self.image_dict[self.image_type][self.index]
        self.anim_timer = current_time
    end
end

--[[Explode adjacent cells, dependent on power and available cells]]
function Explosion:calculate_explosive_path()
    --                        left  right up    down
    local valid_directions = {true, true, true, true}
    for power_cell = 0, self.power - 1 do
        -- Get a list of the 4 directions, tuple of cell values
        local directions = self:calculate_direction_cells(power_cell)
        --  Check the cells in each direction per the directions list above
        for ind, dir in ipairs(directions) do
            -- if the corrseponding direction in valid_directions list is false, skip
            if valid_directions[ind] then
                --  If the current cellbeing checked is an empty cell, check the next cell in that direction
                --  to determine type of image to display, whether it is a mid or end 
                if self.GAME.level_matrix[ dir[1] + 1][ dir[2] + 1] == '_' then
                    --  if the end of the power range, use the end piece
                    if power_cell == self.power - 1 then
                        local fireball = FireBall(self.GAME, self.image_dict[dir[5]], dir[1], dir[2], dir[5])
                        table.insert(self.GAME.groups.fireball, fireball)
                    --  Check if the next cell in sequence is a barrier, use end piece if true,
                    --  and change valid directions to False
                    elseif self.GAME.level_matrix[dir[3] + 1][dir[4] + 1] == HardBlock.repr then
                        local fireball = FireBall(self.GAME, self.image_dict[dir[5]], dir[1], dir[2], dir[5])
                        table.insert(self.GAME.groups.fireball, fireball)
                        valid_directions[ind] = false
                    --  if next cell in sequence is not a barrier, and not the end of the flame power, use mid image
                    else
                        local fireball = FireBall(self.GAME, self.image_dict[dir[6]], dir[1], dir[2], dir[6])
                        table.insert(self.GAME.groups.fireball, fireball)
                    end
                --  If the current cell being checked is not empty, but is a bomb, detonate the bomb
                elseif self.GAME.level_matrix[dir[1] + 1][dir[2] + 1] == Bomb.repr then
                    for i=#self.GAME.groups.bomb, 1, -1 do
                        if self.GAME.groups.bomb[i].x == dir[2]*SIZE and self.GAME.groups.bomb[i].y == (dir[1]*SIZE + Y_OFFSET) then
                            self.GAME.groups.bomb[i]:explode()
                        end
                    end
                    valid_directions[ind] = false
                -- If the current cell being checked is not empty, but is a soft block - destroy it.
                elseif self.GAME.level_matrix[dir[1] + 1][dir[2] + 1] == SoftBlock.repr then
                    for i=#self.GAME.groups.soft_block, 1, -1 do
                        if self.GAME.groups.soft_block[i].x == dir[2]*SIZE and self.GAME.groups.soft_block[i].y == (dir[1]*SIZE + Y_OFFSET) then
                            self.GAME.groups.soft_block[i]:destroy()
                        end
                    end
                    valid_directions[ind] = false
                
                elseif self.GAME.level_matrix[dir[1] + 1][dir[2] + 1] == Special.repr then
                    for i=#self.GAME.groups.special, 1, -1 do
                        if self.GAME.groups.special[i].x == dir[2]*SIZE and self.GAME.groups.special[i].y == (dir[1]*SIZE + Y_OFFSET) then
                            self.GAME.groups.special[i]:hit_by_explosion()
                        end
                    end
                    valid_directions[ind] = false
                -- If the current cell being checked is not an empty cell, or a bomb, or a soft, or a special    
                else
                    valid_directions[ind] = false
                end
            end
        end
    end
end

--[[Returns a list of the four cells in the up and down, left and right directions]]
function Explosion:calculate_direction_cells(cell)
    local left = { 
        self.row_num, self.col_num - (cell + 1),  -- Check cell immediate left
        self.row_num, self.col_num - (cell + 2),  -- Check cell left of that
        "left_end",
        "left_mid"
    }
    local right = { 
        self.row_num, self.col_num + (cell + 1),  -- Check cell immediate right
        self.row_num, self.col_num + (cell + 2),  -- Check cell right of that
        "right_end", 
        "right_mid"
    }
    local up    = { 
        self.row_num - (cell + 1), self.col_num,  -- Check cell immediate up
        self.row_num - (cell + 2), self.col_num,  --  Check cell above that
        "up_end", 
        "up_mid" 
    }
    local down  = { 
        self.row_num + (cell + 1), 
        self.col_num,  -- Check cell immediate down
        self.row_num + (cell + 2), self.col_num,  -- Check cell below that
        "down_end", 
        "down_mid"}

    return {left, right, up, down}
end

--[[Removes the explosion object from the level matrix]]
function Explosion:remove_from_grid()
    self.GAME.level_matrix[self.row_num + 1][self.col_num + 1] = '_'
    for index, value in ipairs(self.GAME.groups.explosion) do
        if self == value then
            table.remove(self.GAME.groups.explosion, index)
        end
    end
end