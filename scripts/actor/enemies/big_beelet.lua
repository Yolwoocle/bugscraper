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
    BigBeelet.super.init(self, x, y)
    self.name = "big_beelet"
    self:set_dimensions(24, 24)
    self.attack_bounces = 8
    self.life = 40
    self.is_stompable = true
    self.damage_on_stomp = 5 --todo test if this works

    self.attack_speed = 70
    self.score = 30

    self.spr = AnimatedSprite:new({
        normal = {images.big_chipper, 0.2, 4},
        attack = {images.big_chipper_activated, 0.1, 4},
    }, "normal", SPRITE_ANCHOR_CENTER_CENTER) 
end

function BigBeelet:update(dt)
    BigBeelet.super.update(self, dt)
end

function BigBeelet:enter_wander()
    BigBeelet.super.enter_wander(self)
end

function BigBeelet:detect_player_in_range()
    return true
    -- return self.super.detect_player_in_range(self)
end

return BigBeelet