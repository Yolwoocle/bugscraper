require "scripts.util"
local BackgroundLayer = require "scripts.level.background.layer.background_layer"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local BackgroundLayerSolidColor = BackgroundLayer:inherit()

function BackgroundLayerSolidColor:init(background, parallax, params)
    params = params or {}
    BackgroundLayerSolidColor.super.init(self, background, parallax, params)

    self.color = params.color
end

function BackgroundLayerSolidColor:update(dt)
    BackgroundLayerSolidColor.super.update(self, dt)
end

function BackgroundLayerSolidColor:draw()
    BackgroundLayerSolidColor.super.draw(self)

    local cx, cy = game.camera:get_real_position()
    rect_color(self.color, "fill", cx, cy, CANVAS_WIDTH, CANVAS_HEIGHT)
end

return BackgroundLayerSolidColor