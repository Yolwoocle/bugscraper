require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local EffectSlowness = require "scripts.effect.effect_slowness"
local sounds = require "data.sounds"
local images = require "data.images"
local Timer  = require "scripts.timer"

local HoneyPatch = Enemy:inherit()
	
function HoneyPatch:init(x, y, params)
    params = params or {}
    self:init_enemy(x,y, images.honey_blob, 14, 14)
    self.name = "honey_patch"

    self.damage = 0

    self.gravity_mult = 0
    self.final_gravity_mult = 0.3
    self.wait_timer = Timer:new(params.wait_range or {0.2, 0.7}):start()
    self.follow_player = false

    self.friction_x = 1
    self.friction_y = 1
    
    self.is_stompable = false
    self.is_pushable = false
    self.is_immune_to_bullets = true

    self.counts_as_enemy = false
    
    self.loot = {}
end

function HoneyPatch:update(dt)
    HoneyPatch.super.update(self, dt)

    if self.wait_timer:update(dt) then
        self.gravity_mult = self.final_gravity_mult
    end
end

function HoneyPatch:after_collision(col, other)
    if col.normal.y == "-1" then
        self.vx = 0
    end

    if col.other.is_player then
    	col.other:apply_effect(EffectSlowness:new(0.1), 0.1)
        -- self:kill()
    end
end

function HoneyPatch:on_death()
    Particles:image(self.mid_x, self.mid_y, 15, {images.honey_fragment_1, images.honey_fragment_2}, 13, nil, 0, 10) 

    self:play_sound_var("sfx_enemy_honeypot_liquid_splash_{01-04}", 0.1, 1.1)
end


return HoneyPatch
