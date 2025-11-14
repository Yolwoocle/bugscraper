require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local Timer= require "scripts.timer"

local InvisibleDummy = Enemy:inherit()

function InvisibleDummy:init(x, y)
    self:init_enemy(x,y, images.empty, 15, 26)
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
    self.is_killed_on_negative_life = false
    self.counts_as_enemy = true
    self.loot = {}

    self.respawn_timer = Timer:new(1.0)

	self.fury_bullet_damage_multiplier = 0
    self.fury_stomp_multiplier = 0

    self.sound_damage = "empty" 
    self.sound_death = "empty"
    self.sound_stomp = "empty"
end

function InvisibleDummy:update(dt)
    self:update_enemy(dt)

    if self.respawn_timer:update(dt) then
        self:enable_dummy()
    end
end

function InvisibleDummy:on_stomped()
    self:disable_dummy()
end

function InvisibleDummy:on_negative_life()
    self:disable_dummy()
end

function InvisibleDummy:enable_dummy()
    self.life = self.max_life

    self.spr.is_visible = true
    self.is_stompable = true
    self.destroy_bullet_on_impact = true
    self.is_immune_to_bullets = false

    self.vy = -200
    Particles:smoke_big(self.mid_x, self.mid_y, {COL_WHITE, COL_LIGHT_GRAY, COL_LIGHTEST_GRAY})
end


function InvisibleDummy:disable_dummy()
    self.respawn_timer:start()
    self.spr.is_visible = false
    self.is_stompable = false

    self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

    self:play_sound_var(self.sound_death, 0.1, 1.2)
end

function InvisibleDummy:on_death()
    Particles:image(self.mid_x, self.mid_y, 20, {images.dummy_fragment_1, images.dummy_fragment_2}, self.w, nil, nil, 0.5)
    --number, spr, spw_rad, life, vs, g
end

return InvisibleDummy