SoftBlock = Block:extend()
SoftBlock.repr = "'@'"

function SoftBlock:new(game, images, row_num, col_num)
    SoftBlock.super.new(self, game, images, row_num, col_num)
    self.index = 1
    self.anim_timer = love.timer.getTime() * 1000
    self.anim_frame_time = 50
    self.destroyed = false
end

function SoftBlock:update()
    if self.destroyed then
        local current_time = love.timer.getTime() * 1000
        if current_time - self.anim_timer > self.anim_frame_time then
            self.index = self.index + 1
            if self.index >= #self.image_list then
                for index, value in ipairs(self.GAME.groups.soft_block) do
                    if self == value then
                        table.remove(self.GAME.groups.soft_block, index)
                    end
                end
                return
            end
    
            self.image = self.image_list[self.index]
            self.anim_timer = current_time
        end

        for index, enemy in ipairs(self.GAME.groups.enemy) do
            local isCollidedWithSoftBlock = self.x < enemy.x + SIZE and 
                                            enemy.x < self.x + SIZE and 
                                            self.y < enemy.y + SIZE and enemy.y < self.y + SIZE
            if enemy.destroyed or not isCollidedWithSoftBlock then
            else
                enemy:destroy()
            end
        end

        local isCollidedWithPlayer = self.x < self.GAME.player.x + SIZE and 
                                     self.GAME.player.x < self.x + SIZE and 
                                     self.y < self.GAME.player.y + SIZE and self.GAME.player.y < self.y + SIZE
        if isCollidedWithPlayer then
            self.GAME.player.alive = false
            self.GAME.player.action = 'dead_anim'
        end
    end
end

--[[If soft block has been destroyed, change the destroyed boolean to True, and set the timer]]
function SoftBlock:destroy()
    if not self.destroyed then
        self.anim_timer = love.timer.getTime() * 1000
        self.destroyed = true
        self.GAME.level_matrix[self.row + 1][self.col + 1] = '_'
    end
end
