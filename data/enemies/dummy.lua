require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local DummyTarget = Enemy:inherit()

function DummyTarget:init(x, y)
    self:init_enemy(x,y, images.dummy_target, 15, 26)
    self.name = "dummy"
    self.follow_player = false

    self.life = 12
    self.damage = 0
    self.self_knockback_mult = 0.1

    self.knockback = 0
    
    self.is_pushable =false
    self.is_knockbackable = false
    self.loot = {}

    self.sound_damage = {"cloth1", "cloth2", "cloth3"}
    self.sound_death = "cloth_drop"
    self.sound_stomp = "cloth_drop"
end

function DummyTarget:update(dt)
    self:update_enemy(dt)
end

function DummyTarget:on_death()
    Particles:image(self.mid_x, self.mid_y, 20, {images.dummy_target_ptc1, images.dummy_target_ptc2}, self.w, nil, nil, 0.5)
    --number, spr, spw_rad, life, vs, g
end

return DummyTarget