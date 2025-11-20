require 'gamesettings'

InfoPanel = Object:extend()

function InfoPanel:new(game, images)
    self.GAME = game
    self.images = images

    self.black_nums = self.images.numbers_black

    self:set_timer()

    self.player_lives_left_word = self.images.left_word
    self.score_image = self:update_score_image(self.GAME.player.score)
end

function InfoPanel:set_timer()
    self.time_total = STAGE_TIME
    self.timer_start = love.timer.getTime() * 1000
    self.time = 200

    self.time_image = self:update_time_image()
    self.time_word_image = self.images.time_word
end

function InfoPanel:update_score_image(score)
    local score_images = {}
    if score == 0 then
        table.insert(score_images, self.black_nums[0])
        table.insert(score_images, self.black_nums[0])
    else
        local score_string = tostring(score)
        for i = 1, #score_string do
            local digit = tonumber(score_string:sub(i, i))
            table.insert(score_images, self.black_nums[digit])
        end
    end

    return score_images
end

function InfoPanel:update_time_image()
    local timeString = tostring(self.time)
    local images = {}

    for i = 1, #timeString do
        local digit = tonumber(timeString:sub(i, i))
        table.insert(images, self.black_nums[digit])
    end

    return images
end

function InfoPanel:update()
    self.score_image = self:update_score_image(self.GAME.player.score)
    if self.time == 0 then
        return
    end

    local current_time = love.timer.getTime() * 1000
    if current_time - self.timer_start >= 1000 then
        self.timer_start = current_time
        self.time = self.time - 1
        self.time_image = self:update_time_image()
        if self.time == 0 then
            local enemies = {}
            for i=1, 10 do
                table.insert(enemies, SPECIAL_CONNECTIONS[self.name])
            end
            self.GAME.insert_enemies_into_level(self.GAME.level_matrix, 'pontan')
        end
    end
end

function InfoPanel:draw()
    love.graphics.draw(self.images.data.spritesheet, self.time_word_image, 32, 32, 0, SCALE_FACTOR / 2, SCALE_FACTOR / 2)
    local len = #self.time_image

    if len == 3 then
        start_x = 192
    elseif len == 2 then
        start_x = 224
    else
        start_x = 256
    end

    for i, image in ipairs(self.time_image) do
        love.graphics.draw(image[1].spritesheet, image[1].quad, start_x + (32 * (i - 1)), 32, 0, SCALE_FACTOR / 2, SCALE_FACTOR / 2)
    end

    start_x = (math.floor(SCREENWIDTH / 2) + 64) - (#self.score_image * 32)
    for i, image in ipairs(self.score_image) do
        love.graphics.draw(image[1].spritesheet, image[1].quad, start_x + (32 * (i - 1)), 32, 0, SCALE_FACTOR / 2, SCALE_FACTOR / 2)
    end

    love.graphics.draw(self.images.data.spritesheet, self.player_lives_left_word, 1032, 32, 0, SCALE_FACTOR / 2, SCALE_FACTOR / 2)
    
    love.graphics.draw(self.images.data.spritesheet, self.black_nums[self.GAME.player.lives][1].quad, 1184, 32, 0, SCALE_FACTOR / 2, SCALE_FACTOR / 2)
end
