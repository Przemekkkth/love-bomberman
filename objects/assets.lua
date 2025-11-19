require 'love.gamesettings'
Assets = Object:extend()

function Assets:new()
    self.data = {}
    self.data.spritesheet = self:load_sprite_sheet('assets/images', 'spritesheet.png')
    self.data.spritesheet:setFilter('nearest', 'nearest')

    self.player_char = self:load_sprite_range(PLAYER, self.data.spritesheet)
    self.hard_block  = self:load_sprite_range(HARD_BLOCK, self.data.spritesheet)
    self.soft_block  = self:load_sprite_range(SOFT_BLOCK, self.data.spritesheet)
    self.background  = self:load_sprite_range(BACKGROUND, self.data.spritesheet)
    self.bomb        = self:load_sprite_range(BOMB, self.data.spritesheet)
    self.explosions  = self:load_sprite_range(EXPLOSIONS, self.data.spritesheet)
    self.ballom      = self:load_sprite_range(BALLOM, self.data.spritesheet)
    self.enemies = {ballom = self:load_sprite_range(BALLOM, self.data.spritesheet),
                    onil = self:load_sprite_range(ONIL, self.data.spritesheet),
                    dahl   = self:load_sprite_range(DAHL, self.data.spritesheet),
                    minvo   = self:load_sprite_range(MINVO, self.data.spritesheet),
                    doria   = self:load_sprite_range(DORIA, self.data.spritesheet),
                    ovape   = self:load_sprite_range(OVAPE, self.data.spritesheet),
                    pass   = self:load_sprite_range(PASS, self.data.spritesheet),
                    pontan   = self:load_sprite_range(PONTAN, self.data.spritesheet)}
    self.specials = self:load_sprite_range(SPECIALS, self.data.spritesheet)
    self.time_word = self:load_sprites(self.data.spritesheet, 4*ASSET_GRID_SIZE, 13*ASSET_GRID_SIZE, 4*ASSET_GRID_SIZE, ASSET_GRID_SIZE)
    self.left_word = self:load_sprites(self.data.spritesheet, 0*ASSET_GRID_SIZE, 13*ASSET_GRID_SIZE, 4*ASSET_GRID_SIZE, ASSET_GRID_SIZE)

    self.numbers_black = self:load_sprite_range(NUMBERS_BLACK, self.data.spritesheet, ASSET_GRID_SIZE, ASSET_GRID_SIZE, ASSET_GRID_SIZE, ASSET_GRID_SIZE, true)
    self.numbers_white = self:load_sprite_range(NUMBERS_WHITE, self.data.spritesheet, ASSET_GRID_SIZE, ASSET_GRID_SIZE, ASSET_GRID_SIZE, ASSET_GRID_SIZE, true)
    self.score_images = self:load_sprite_range(SCORE_IMAGES, self.data.spritesheet,   ASSET_GRID_SIZE, ASSET_GRID_SIZE, ASSET_GRID_SIZE, 0.5 * ASSET_GRID_SIZE, false)
    self.stage_word = self:load_sprites(self.data.spritesheet, 0, 14 * ASSET_GRID_SIZE, 5 * ASSET_GRID_SIZE, ASSET_GRID_SIZE)

    self.music = {}
    self:load_music()
    self.sounds = {}
    self:load_sounds()
end

--[[Load in the sprite sheet image, and resize it]]
function Assets:load_sprite_sheet(path, filename)
    local image = love.graphics.newImage(path .. "/" .. filename)
    return image
end

--[[Load an individual sprite image]]
function Assets:load_sprites(spritesheet, xcoord, ycoord, width, height)
    local quad = love.graphics.newQuad(xcoord, ycoord, width, height, spritesheet:getWidth(), spritesheet:getHeight())
    return quad
end

--[[Return a dictionary containing lists of images for the animations]]
function Assets:load_sprite_range(imageDict, spritesheet, row, col, width, height, resize)
    row = row or ASSET_GRID_SIZE
    col = col or ASSET_GRID_SIZE
    width = width or ASSET_GRID_SIZE
    height = height or ASSET_GRID_SIZE
    resize = resize or false

    local animation_images = {}
    for animation, coords in pairs(imageDict) do
        animation_images[animation] = {}
        for _, coord in ipairs(coords) do
            local x = coord[2] * col
            local y = coord[1] * row

            local quad = love.graphics.newQuad(x, y, width, height, spritesheet:getWidth(), spritesheet:getHeight())
            if resize then
                
                local scaleX = 8 / width
                local scaleY = 8 / height
                table.insert(animation_images[animation], {spritesheet = spritesheet, quad = quad, scaleX = scaleX, scaleY = scaleY})
            else
                table.insert(animation_images[animation], {spritesheet = spritesheet, quad = quad, scaleX = SCALE_FACTOR, scaleY = SCALE_FACTOR})
            end
        end
    end

    return animation_images
end

function Assets:load_music()
    for _, value in ipairs(MUSIC) do
        self.music[value] = love.audio.newSource('assets/music/'..value, 'stream')
        self.music[value]:setLooping(true)
    end
end

function Assets:load_sounds()
    for _, value in ipairs(SOUNDS) do
        self.sounds[value] = love.audio.newSource('assets/sfx/'..value, 'static')
    end
end