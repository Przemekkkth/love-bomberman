require 'love.gamesettings'

Block = Object:extend()
Block.repr = "'#'"

function Block:new(game, images, row_num, col_num)
    self.GAME = game
    self.y_offset = Y_OFFSET

    -- Position in level matrix
    self.row = row_num
    self.col = col_num

    -- Coordinates of Block
    self.x = self.col * SIZE
    self.y = (self.row * SIZE) + self.y_offset

    -- Attributes
    self.passable = false

    -- Block image
    self.image_list = images
    self.image_index = 1
    self.image = self.image_list[self.image_index]
end

function Block:update()
    
end

function Block:draw(offset)
    love.graphics.draw(self.image.spritesheet, self.image.quad, self.x - offset, self.y, 0, SCALE_FACTOR, SCALE_FACTOR)
end