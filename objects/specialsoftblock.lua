require 'objects.specials'

SpecialSoftBlock = SoftBlock:extend()

function SpecialSoftBlock:new(game, images, row_num, col_num, special_type)
    SpecialSoftBlock.super.new(self, game, images, row_num, col_num)

    self.special_type = special_type
end

function SpecialSoftBlock:place_special_block()
    local special_cell = Special(self.GAME, self.GAME.ASSETS.specials[self.special_type][1], self.special_type, self.row, self.col)
    self.GAME.level_matrix[self.row][self.col] = SoftBlock.repr
    table.insert(self.GAME.groups.special, special_cell)
end

function SpecialSoftBlock:destroy()
    SpecialSoftBlock.super.destroy(self)
    self:place_special_block()
end