Scoring = Object:extend()
Scoring.score_bonus = 0

function Scoring:new(game, score, xpos, ypos)
    Scoring.score_bonus = Scoring.score_bonus + 1
    self.GAME = game
    
    if Scoring.score_bonus < 1 then
        self.score = score
    else
        self.score = 2 * score
    end

    self.time = love.timer.getTime() * 1000

    self.x = xpos
    self.y = ypos

   self.image = self.GAME.ASSETS.score_images[100][1]
   table.insert(self.GAME.groups.scoring, self) 
end

function Scoring:update()
    local current_time = love.timer.getTime() * 1000
    if current_time - self.time >= 1000 then
        Scoring.score_bonus = Scoring.score_bonus - 1
        for index, value in ipairs(self.GAME.groups.scoring) do
            if value == self then
                table.remove(self.GAME.groups.scoring, index)
            end
        end
    end
end

function Scoring:draw(x_offset)
    love.graphics.draw(self.image.spritesheet, self.image.quad, self.x - x_offset, self.y, 0, self.image.scaleX, self.image.scaleY)
end
