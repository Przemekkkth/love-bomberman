require 'love.objects.block'

HardBlock = Block:extend()
HardBlock.repr = "'+'"

function HardBlock:new(game, images, row_num, col_num)
    HardBlock.super.new(self, game, images, row_num, col_num)
end