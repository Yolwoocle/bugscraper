require "scripts.util"
local Sprite = require "scripts.graphics.sprite"
local Timer = require "scripts.timer"
local images= require "data.images"

local AnimatedSprite = Sprite:inherit()

function AnimatedSprite:init(animation, anchor, params)
    params = params or {}
    self.super.init(self, animation[1] or images.empty, anchor, params)

    self.animation = param(animation, {})
    self.frame_i = param(params.start_frame, 1)
    self.frame_timer = Timer:new(param(params.frame_duration or 1))
    self.frame_timer:start()
end

function AnimatedSprite:set_animation(animation)
    self.animation = animation
end

function AnimatedSprite:update_frame_sprite()
    self:set_image(self.animation[self.frame_i])
end

function AnimatedSprite:update(dt)
    self.super.update(self, dt)

    if self.frame_timer:update(dt) then
        self.frame_i = mod_plus_1(self.frame_i + 1, #self.animation)
        self:update_frame_sprite()
        
        self.frame_timer:start()
    end
end

return AnimatedSprite