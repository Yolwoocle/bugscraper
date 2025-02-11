require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local Timer= require "scripts.timer"

local Dummy = Enemy:inherit()

function Dummy:init(x, y)
    self:init_enemy(x,y, images.dummy_target, 15, 26)
    self.name = "dummy"
    self.follow_player = false

    self.max_life = 10
    self.life = self.max_life
    self.damage = 0
    self.self_knockback_mult = 0.1

    self.knockback = 0
    
    self.is_pushable =false
    self.is_knockbackable = false
    self.can_be_stomped_if_on_head = false
	self.is_killed_on_stomp = false
    self.kill_when_negative_life = false
    self.counts_as_enemy = true
    self.loot = {}

    self.respawn_timer = Timer:new(1.0)

    self.sound_damage = {"cloth1", "cloth2", "cloth3"}
    self.sound_death = "cloth_drop"
    self.sound_stomp = "cloth_drop"
end

function Dummy:update(dt)
    self:update_enemy(dt)

    if self.respawn_timer:update(dt) then
        self:enable_dummy()
    end
end

function Dummy:on_stomped()
    self:disable_dummy()
end

function Dummy:on_negative_life()
    self:disable_dummy()
end

function Dummy:enable_dummy()
    self.life = self.max_life

    self.spr.is_visible = true
    self.is_stompable = true
    self.destroy_bullet_on_impact = true
    self.is_immune_to_bullets = false

    self.vy = -200
    Particles:smoke_big(self.mid_x, self.mid_y, {COL_WHITE, COL_LIGHT_GRAY, COL_LIGHTEST_GRAY})
end


function Dummy:disable_dummy()
    Particles:floating_image({
        images.star_small_1,
        images.star_small_2,
    }, self.mid_x, self.mid_y, random_range_int(5, 7), 0, 0.25, 1, 120, 0.95)
    Particles:smoke(self.mid_x, self.mid_y)
    Particles:star_splash(self.mid_x, self.mid_y)
    Particles:image(self.mid_x, self.mid_y, 20, {images.dummy_fragment_1, images.dummy_fragment_2}, self.w, nil, nil, 0.5)

    self.respawn_timer:start()
    self.spr.is_visible = false
    self.is_stompable = false

    self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

    Audio:play_var(self.sound_death, 0.1, 1.2)
end

function Dummy:on_death()
    Particles:image(self.mid_x, self.mid_y, 20, {images.dummy_fragment_1, images.dummy_fragment_2}, self.w, nil, nil, 0.5)
    --number, spr, spw_rad, life, vs, g
end

return Dummy