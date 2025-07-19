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
    for anim_name, anim_data in pairs(animations) do
        self.animations[anim_name] = Animation:new(unpack(anim_data))
    end
    self.animation = param(animations[params.default])
    self.current_animation_name = params.default
    self.frame_i = param(params.start_frame, 1)
    self.frame_timer = Timer:new(param(params.frame_duration or 1), {loopback = true})
    self.frame_timer:start()

    if default then
        self:set_animation(default)
    end
end

function AnimatedSprite:set_animation(animation_name)
    if self.current_animation_name == animation_name then
        return
    end
    local anim = self.animations[animation_name]
    assert(anim, "Animation '" .. tostring(animation_name) .. "' does not exist") 

    self.animation = anim
    self.current_animation_name = animation_name
    self.frame_i = 1

    self.frame_timer:start(anim.frame_duration)
    if self.animation.is_spritesheet then
        self:set_spritesheet(self.animation.frames, self.animation.frame_count_x, self.animation.frame_count_y)
    end 

    self:update_frame_sprite()
end

function AnimatedSprite:update_frame_sprite()
    if self.animation.is_spritesheet then
        self:set_spritesheet_tile(self.frame_i)
    else
        self:set_image(self.animation.frames[self.frame_i])
    end
end

function AnimatedSprite:set_frame_index(frame_i)
    self.frame_i = mod_plus_1(frame_i, self.animation.frame_count)
    self:update_frame_sprite()
end

function AnimatedSprite:update(dt)
    self.super.update(self, dt)

    if self.frame_timer:update(dt) then
        if self.animation.looping then
            self.frame_i = mod_plus_1(self.frame_i + 1, self.animation.frame_count)
        else
            self.frame_i = min(self.frame_i + 1, self.animation.frame_count)
        end
        self:update_frame_sprite() 
    end
end

return AnimatedSprite