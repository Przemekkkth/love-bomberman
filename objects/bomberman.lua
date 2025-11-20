require 'objects.assets'
require 'objects.game'
BomberMan = Object:extend()

function BomberMan:new()
    self.ASSETS = Assets()
    self.GAME = Game(self, self.ASSETS)
end

function BomberMan:input()
    self.GAME:input()
end

function BomberMan:update()
    self.GAME:update()
end

function BomberMan:draw()
    self.GAME:draw()
end

function BomberMan:reset()
    self.ASSETS = Assets()
    self.GAME = Game(self, self.ASSETS)
end

function BomberMan:generate_level()
    self.GAME:generate_level()
end