require "scripts.util"
local Centipede = require "scripts.actor.enemies.centipede"
local PoisonCloud = require "scripts.actor.enemies.poison_cloud"
local sounds = require "data.sounds"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local CentipedeBoss = Centipede:inherit()

function CentipedeBoss:init(x, y, length, parent, params)
    params = params or {}
    params.w = params.w or 20
    length = length or 15
    CentipedeBoss.super.init(self, x, y, length, parent, params)
    self.name = "centipede_boss"

    self.spr:set_scale(2, 2)
    self.life = 30
    self.score = 10

    self.is_boss = true
    self.do_boss_gun_damage = false

    self.centipede_spacing = 24
    self.centipede_spring_force = 2

    self.sound_death = "sfx_enemy_kill_general_stomp_{01-10}"
    self.sound_stomp = "sfx_enemy_kill_general_stomp_{01-10}"
end

function CentipedeBoss:get_self_class()
    return CentipedeBoss
end

function CentipedeBoss:get_centipede_speed()
    return 0.75 * (10 + (20 - clamp(0, self.total_centipede_length, 20)))
end

function CentipedeBoss:update(dt)
    CentipedeBoss.super.update(self, dt)
end

function CentipedeBoss:draw()
    CentipedeBoss.super.draw(self)
end

function CentipedeBoss:on_death()
end

return CentipedeBoss
