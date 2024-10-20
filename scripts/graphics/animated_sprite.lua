require "scripts.util"
local Sprite = require "scripts.graphics.sprite"
local Animation = require "scripts.graphics.animation"
local Timer = require "scripts.timer"
local images = require "data.images"

local unpack = table.unpack or unpack

local AnimatedSprite = Sprite:inherit()

function AnimatedSprite:init(animations, default, anchor, params)
    params = params or {}
    params.default = param(params.default, "")
    self.super.init(self, images.empty, anchor, params)

    self.animations = animations
    for anim_name, anim_table in pairs(animations) do
        self.animations[anim_name] = Animation:new(unpack(anim_table))
    end
    self.animation = param(animations[params.default])
    self.frame_i = param(params.start_frame, 1)
    self.frame_timer = Timer:new(param(params.frame_duration or 1))
    self.frame_timer:start()

    if default then
        self:set_animation(default)
    end
end

function AnimatedSprite:set_animation(animation_name)
    local anim = self.animations[animation_name]
    assert(anim, "Animation '" .. animation_name .. "' does not exist") 
    self.animation = anim
    self.frame_i = 1

    self.frame_timer:start(anim.frame_duration)
    self:update_frame_sprite()
end

function AnimatedSprite:update_frame_sprite()
    self:set_image(self.animation.frames[self.frame_i])
end

function AnimatedSprite:update(dt)
    self.super.update(self, dt)

    if self.frame_timer:update(dt) then
        self.frame_i = mod_plus_1(self.frame_i + 1, #self.animation.frames)
        self:update_frame_sprite()
        
        self.frame_timer:start()
    end
end

return AnimatedSprite