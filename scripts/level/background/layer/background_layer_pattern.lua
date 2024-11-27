require "scripts.util"
local BackgroundLayer = require "scripts.level.background.layer.background_layer"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"

local BackgroundLayerPattern = BackgroundLayer:inherit()

function BackgroundLayerPattern:init(background, parallax, params)
    params = params or {}
    BackgroundLayerPattern.super.init(self, background, parallax)
    
    self.pattern_image = params.pattern_image or images.empty
    self.pattern_x_offsets = params.pattern_x_offsets or {0}
    self.pattern_y_offsets = params.pattern_y_offsets or {0}
    self.determinant_function = params.determinant_function or function(_self, x, y) return true end
    self.pattern_height = self:get_pattern_height()
    self.row_count = math.ceil(CANVAS_HEIGHT / self.pattern_height) + 2

    self.tiles = self:create_tiles()
end

function BackgroundLayerPattern:get_pattern_height()
    local sum = 0
    for _, oy in pairs(self.pattern_y_offsets) do
        sum = sum + oy + self.pattern_image:getHeight()
    end
    return sum
end

function BackgroundLayerPattern:create_tiles(amount)
    local tiles = {}

    local iy = -self.pattern_height
    for i_row = 1, self.row_count * #self.pattern_y_offsets do
        local ox = self.pattern_x_offsets[(i_row % #self.pattern_x_offsets) + 1]
        local start_x = (ox % self.pattern_image:getWidth()) - self.pattern_image:getWidth()

        for ix = start_x, CANVAS_WIDTH, self.pattern_image:getWidth() do
            table.insert(tiles, self:new_particle(nil, ix, iy))
        end 

        iy = iy + self.pattern_image:getHeight() + self.pattern_y_offsets[(i_row % #self.pattern_y_offsets) + 1]
        i_row = i_row + 1
    end

    return tiles
end

function BackgroundLayerPattern:new_particle(p, x, y)
    p = p or {}

    p.x = x
    p.y = y
    p.spr = Sprite:new(self.pattern_image, SPRITE_ANCHOR_LEFT_TOP)

    p.visible = self:determinant_function(x, y + self.layer_y)

    p.despawn_condition = function(_self)
        return _self.y - _self.spr.h > CANVAS_HEIGHT
    end

    p.draw = function(_self)
        _self.spr:draw(math.floor(_self.x), math.floor(_self.y))
    end

    return p
end

function BackgroundLayerPattern:update(dt)
    BackgroundLayerPattern.super.update(self, dt)

	for _, tile in pairs(self.tiles) do
        tile.y = tile.y + self.background:get_speed() * self.parallax * dt

        if tile:despawn_condition() then
            tile.y = tile.y - self.pattern_height * self.row_count 
        end
    end
end

function BackgroundLayerPattern:draw()
    BackgroundLayerPattern.super.draw(self)

    for _, tile in pairs(self.tiles) do
        if tile.visible then
            tile:draw()
        end
    end
end

return BackgroundLayerPattern