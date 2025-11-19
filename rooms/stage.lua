require 'love.gamesettings'

StageRoom = Object:extend()

function StageRoom:new()
    self.GAME = bomberman.GAME
    self.ASSETS = bomberman.ASSETS
    self.image = self.ASSETS.stage_word
    self.stage_num = self.GAME.level
    self.time = 2800
    self.timer = love.timer.getTime() * 1000
    self.music = self.ASSETS.music['BM-Stage-Start.wav']
    self.music:play()
end

function StageRoom:update(dt)
    local current_time = love.timer.getTime() * 1000
    if current_time - self.timer > self.time then
        self.music:stop()
        bomberman.GAME:play_bg_music()
        gotoRoom("GameRoom")
    end
end

function StageRoom:draw()
    love.graphics.draw(self.ASSETS.data.spritesheet, self.image, SCREENWIDTH / 2 - 6*SIZE, SCREENHEIGHT / 2 - SIZE, 0, SCALE_FACTOR, SCALE_FACTOR)
    local stage_word_list = self:generate_stage_number_image()
    if #stage_word_list then
        for idx, value in ipairs(stage_word_list) do
            local xpos = SCREENWIDTH / 2 + idx * SIZE
            local ypos = SCREENHEIGHT / 2 - SIZE
            love.graphics.draw(self.ASSETS.data.spritesheet, value[1].quad, xpos, ypos, 0, SCALE_FACTOR, SCALE_FACTOR)
        end
    end

end

function StageRoom:generate_stage_number_image()
    local num_imgs = {}

    local num_str = tostring(self.stage_num)

    for i = 1, #num_str do
        local digit = tonumber(num_str:sub(i, i))
        table.insert(num_imgs, self.ASSETS.numbers_white[digit])
    end

    return num_imgs
end
