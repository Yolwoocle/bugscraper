require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Beelet = require "scripts.actor.enemies.beelet"
local sounds = require "data.sounds"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Segment = require "scripts.math.segment"
local guns  = require "data.guns"

local BigBeelet = Beelet:inherit()

function BigBeelet:init(x, y)
    self.super.init(self, x, y)
    self.name = "big_beelet"
    self:set_dimensions(24, 24)
    self.spr:set_scale(2, 2)
    self.attack_bounces = 8
    self.life = 40
    self.is_stompable = false

    self.base_scale = 2
    self.attack_speed = 70

    self.spr = AnimatedSprite:new({
        normal = {{images.chipper_1, images.chipper_2, images.chipper_3, images.chipper_2}, 0.2},
        attack = {{images.chipper_attack_1, images.chipper_attack_2, images.chipper_attack_3, images.chipper_attack_2}, 0.1},
    }, "normal", SPRITE_ANCHOR_CENTER_CENTER) 
end

function BigBeelet:update(dt)
    self.super.update(self, dt)
end

function BigBeelet:enter_wander()
    self.super.enter_wander(self)
end

function BigBeelet:detect_player_in_range()
    return true
    -- return self.super.detect_player_in_range(self)
end

return BigBeelet