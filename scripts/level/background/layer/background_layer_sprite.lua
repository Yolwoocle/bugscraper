require "scripts.util"
local BackgroundLayer = require "scripts.level.background.layer.background_layer"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local BackgroundLayerSprite = BackgroundLayer:inherit()

function BackgroundLayerSprite:init(background, parallax, params)
    params = params or {}
    BackgroundLayerSprite.super.init(self, background, parallax, params)

    self.spr = AnimatedSprite:new({
        normal = {params.image, params.frame_duration or 1, params.frame_count or 1},
    }, "normal", SPRITE_ANCHOR_LEFT_TOP)
end

function BackgroundLayerSprite:update(dt)
    BackgroundLayerSprite.super.update(self, dt)
end

function BackgroundLayerSprite:draw()
    BackgroundLayerSprite.super.draw(self)

    self.spr:draw(self.layer_x * self.parallax, self.layer_y * self.parallax)
end

return BackgroundLayerSprite