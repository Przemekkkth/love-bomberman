require 'gamesettings'
require 'objects.character'
require 'objects.hardblock'
require 'objects.softblock'
require 'objects.assets'
require 'objects.enemy'
require 'objects.specialsoftblock'
require 'objects.infopanel'

Game = Object:extend()

function Game:new(main, assets)
    self.MAIN = main
    self.ASSETS = assets
    self.level = 1
    self:generate_level()
    self.level_info = InfoPanel(self, self.ASSETS)
    self.bg_music = self.ASSETS.music['BM-Main-BGM.wav']
    self.bg_music:setLooping(true)
    self.bg_music_special = self.ASSETS.music["BM-Power-Up-Get.wav"]
    self.stage_ending_music = self.ASSETS.music["BM-Stage-Clear.wav"] 
end

function Game:input()
    self.player:input()
end

function Game:update()
    if #self.groups.enemy == 0 and not self.stage_ending_music:isPlaying() then
        self:play_stage_ending_music()
    end

    for _, items in pairs(self.groups) do
        for _, item in pairs(items) do
            item:update()
        end    
    end

    self.level_info:update()
end

function Game:draw()
    love.graphics.setColor(GREY)
    love.graphics.rectangle('fill', 0, 0, SCREENWIDTH, love.graphics:getHeight())
    love.graphics.setColor(1, 1, 1)

    for row_num = 0, COLS - 1 do
        for col_num = 0, ROWS - 1 do
            love.graphics.draw(self.ASSETS.background['background'][1].spritesheet, self.ASSETS.background['background'][1].quad, (row_num * SIZE) - self.camera_x_offset, col_num * SIZE + Y_OFFSET, 0, SCALE_FACTOR, SCALE_FACTOR)
        end
    end

    for  _, item in pairs(self.groups.hard_block) do
        item:draw(self.camera_x_offset)
    end

    for  _, item in pairs(self.groups.bomb) do
        item:draw(self.camera_x_offset)
    end

    for  _, item in pairs(self.groups.explosion) do
        item:draw(self.camera_x_offset)
    end

    for  _, item in pairs(self.groups.fireball) do
        item:draw(self.camera_x_offset)
    end

    for  _, item in pairs(self.groups.soft_block) do
        item:draw(self.camera_x_offset)
    end

    for  _, item in pairs(self.groups.special) do
        item:draw(self.camera_x_offset)
    end

    for  _, item in pairs(self.groups.player) do
        item:draw(self.camera_x_offset)
    end

    for  _, item in pairs(self.groups.enemy) do
        item:draw(self.camera_x_offset)
    end

    for  _, item in pairs(self.groups.scoring) do
        item:draw(self.camera_x_offset)
    end

    self.level_info:draw()
end

--[[Generate the basic level matrix]]
function Game:generate_level_matrix(rows, cols)
    local matrix = {}
    for row = 0, rows do
        local line = {}
        for col = 0, cols do
            table.insert(line, '_')
        end
        table.insert(matrix, line) 
    end

    self:insert_hard_blocks_into_matrix(matrix)
    self:insert_soft_blocks_into_matrix(matrix)
    self:insert_power_up_into_matrix(matrix, self.level_special)
    self:insert_power_up_into_matrix(matrix, 'exit')
    self:insert_enemies_into_level(matrix)

    return matrix
end

--[[Inserts all of the Hard Barrier Blocks into the level matrix]]
function Game:insert_hard_blocks_into_matrix(matrix)
    for row_num, row in ipairs(matrix) do
        for col_num, col in ipairs(row) do
            if row_num == 1 or row_num == #matrix or
               col_num == 1 or col_num == #row or
               ( (row_num - 1) % 2 == 0 and (col_num - 1) % 2 == 0) then
               
                local hard_block = HardBlock(
                    self,
                    self.ASSETS.hard_block["hard_block"],
                    row_num - 1,
                    col_num - 1
                )

                matrix[row_num][col_num] = HardBlock.repr
                table.insert(self.groups.hard_block, hard_block)
            end
        end
    end
end

--[[Randomly insert soft blocks into the level matrix]]
function Game:insert_soft_blocks_into_matrix(matrix)
    for row_num, row in ipairs(matrix) do
        for col_num, col in ipairs(row) do
            if row_num == 1 or row_num == #matrix or
                col_num == 1 or col_num == #row or
                ( (row_num - 1) % 2 == 0 and (col_num - 1) % 2 == 0) then
                -- skip hard block positions (borders + even coords)
            elseif (row_num >= 3 and row_num <= 5) and (col_num >= 2 and col_num <= 4) then
                -- skip player spawn area (rows 2-4, cols 1-3 in Python → shifted +1 in Lua)
            else
                -- pick randomly between "@" and "_"
                local choices = {"@", "_", "_", "_"}
                local idx = math.random(1, #choices)
                local cell = choices[idx]

                if cell == "@" then
                    cell = SoftBlock(
                        self,
                        self.ASSETS.soft_block["soft_block"],
                        row_num - 1,
                        col_num - 1
                    )
                    matrix[row_num][col_num] = SoftBlock.repr
                    table.insert(self.groups.soft_block, cell)
                end
            end
        end
    end
end

function Game:insert_power_up_into_matrix(matrix, special)
    local power_up = special
    local valid = false
    local row
    local col
    while not valid do
        row = love.math.random(0, ROWS-1)
        col = love.math.random(0, COLS-1)

        if row == 0 or row == #matrix - 1 or col == 0 or col == #matrix[1] - 1 then
        elseif row % 2 == 0 and col % 2 == 0 then
        elseif row >= 2 and row <= 4 and col >= 1 and col <= 3 then
        elseif matrix[row + 1][col + 1] ~= '_' then
            valid = true
        end
    end
    local cell = SpecialSoftBlock(self, self.ASSETS.soft_block['soft_block'], row, col, power_up)
    matrix[row + 1][col + 1] = SoftBlock.repr
    table.insert(self.groups.soft_block, cell)
end

--[[Randomly insert enemies into the level, using level matrix for valid locations]]
function Game:insert_enemies_into_level(matrix, enemies)
    local pl_col = self.player.col_num
    local pl_row = self.player.row_num
    local enemy_name_list --= enemies or self:select_enemies_to_spawn()
    if enemies ~= nil then
        enemy_name_list = enemies
    else
        enemy_name_list = self:select_enemies_to_spawn()
    end

    -- Load balloms
    for index, enemy_name in ipairs(enemy_name_list) do
        local valid_choice = false
        while not valid_choice do
            local row = love.math.random(1, ROWS-1)
            local col = love.math.random(1, COLS-1)

            -- Check if this row/col within 3 blocks of the player
            if math.random(row - pl_row) <= 3 and math.random(col - pl_col) <= 3 then
                
            elseif matrix[row][col] == '_' then
                valid_choice = true
                table.insert(self.groups.enemy, Enemy(self, self.ASSETS.enemies[enemy_name], enemy_name, row, col) )
            end
        end
    end
end

function Game:print_level_matrix()
    for _, row in pairs(self.level_matrix) do
        local string = ''
        for _, col in pairs(row) do
            string = string..col..','
        end
        print(string)
    end
end

--[[Updates the camera x position per the player x position]]
function Game:update_x_camera_offset_player_position(player_x_pos)
    if player_x_pos >= SCREENWIDTH/2 - SIZE and player_x_pos <= SCREENWIDTH then
        self.camera_x_offset = player_x_pos - (SCREENWIDTH/2 - SIZE)
    end
end

--[[Restart a stage/level]]
function Game:regenerate_stage()
    self.groups.hard_block = {}
    self.groups.soft_block = {}
    self.groups.bomb = {}
    self.groups.explosion = {}
    self.groups.fireball = {}
    self.groups.enemy = {}

    self.level_matrix = {}
    self.level_matrix = self:generate_level_matrix(ROWS, COLS)
    self.camera_x_offset = 0
end

--[[Generate a list of enemies to spawn]]
function Game:select_enemies_to_spawn()
    local enemies_list = {}
    local enemies = {[0] = 'ballom', [1] = 'ballom', [2] = 'onil', [3] = 'dahl', [4] = 'minvo', [5] = 'doria', 
                     [6] = 'ovape', [7] = 'pass', [8] = 'pontan'}

    if self.level <= 8 then
        self:add_enemies_to_list(8, 2, 0, enemies, enemies_list)
    elseif self.level <= 17 then
        self:add_enemies_to_list(7, 2, 1, enemies, enemies_list)
    elseif self.level <= 26 then
        self:add_enemies_to_list(6, 3, 1, enemies, enemies_list)
    elseif self.level <= 35 then
        self:add_enemies_to_list(5, 3, 2, enemies, enemies_list)    
    elseif self.level <= 45 then
        self:add_enemies_to_list(4, 4, 2, enemies, enemies_list) 
    else
        self:add_enemies_to_list(3, 4, 4, enemies, enemies_list) 
    end

    return enemies_list
end

function Game:add_enemies_to_list(num_1, num_2, num_3, enemies, enemies_list)
    for num = 1, num_1 do
        table.insert(enemies_list, 'ballom')
    end

    for num = 1, num_2 do
        table.insert(enemies_list, enemies[self.level % 9 + 1])
    end

    for num = 1, num_3 do
        table.insert(enemies_list, enemies[love.math.random(3, #enemies)])
    end
end

function Game:select_a_special()
    local specials = {'speed_up', 'bomb_up', 'fire_up', 'wall_hack', 'remote', 'bomb_pass', 'flame_pass', 'invincible'}
    local power_up 
    if self.level == 4 then
        power_up = 'speed_up'
    elseif self.level == 1 then
        power_up = 'bomb_up'
    elseif self.player.bomb_limit <= 2 or self.player.power <= 2 then
        local sub_specials = {'bomb_up', 'fire_up'}
        power_up = sub_specials[love.math.random(1, #sub_specials)]
    else
        if self.player.wall_hack then
            for index, value in ipairs(specials) do
                if value == 'wall_hack' then
                    table.remove(specials, index)
                end
            end
        elseif self.player.remote_detonate then
            for index, value in ipairs(specials) do
                if value == 'remote' then
                    table.remove(specials, index)
                end
            end
        elseif self.player.bomb_hack then
            for index, value in ipairs(specials) do
                if value == 'bomb_pass' then
                    table.remove(specials, index)
                end
            end
        elseif self.player.flame_hack then
            for index, value in ipairs(specials) do
                if value == 'flame_pass' then
                    table.remove(specials, index)
                end
            end
        elseif self.player.bomb_limit == 10 then
            for index, value in ipairs(specials) do
                if value == 'flame_pass' then
                    table.remove(specials, index)
                end
            end
        elseif self.player.power == 10 then
            for index, value in ipairs(specials) do
                if value == 'fire_up' then
                    table.remove(specials, index)
                end
            end   
        end

        power_up = specials[love.math.random(1, #specials)]
    end

    return power_up
end

--[[Increase the stage level number, and selects a new level special]]
function Game:new_stage()
    self.level = self.level + 1
    self.level_special = self:select_a_special()
    self.player:set_player_position()
    self:regenerate_stage()
end

function Game:play_bg_music()
    self.bg_music:play()
    self.bg_music_special:stop()
    self.stage_ending_music:stop()
end

function Game:play_music_special()
    self.bg_music:stop()
    self.bg_music_special:play()
    self.stage_ending_music:stop()
end

function Game:play_stage_ending_music()
    self.bg_music:stop()
    self.bg_music_special:stop()
    self.stage_ending_music:play()
end

function Game:stop_music()
    self.bg_music:stop()
    self.bg_music_special:stop()
    self.stage_ending_music:stop()
end

function Game:generate_level()
    -- Camera Offset
    self.camera_x_offset = 0
    self.groups = {hard_block = {}, soft_block = {}, player = {}, bomb = {}, explosion = {}, fireball = {}, enemy = {}, special = {}, scoring = {}}
    self.player = Character(self, self.ASSETS.player_char, 3, 2)
    table.insert(self.groups.player, self.player)
    self.level_special = self:select_a_special()
    self.level_matrix = self:generate_level_matrix(ROWS, COLS)
    if self.level_info then
        self.level_info:set_timer()
    end
    
    --self:print_level_matrix()
end