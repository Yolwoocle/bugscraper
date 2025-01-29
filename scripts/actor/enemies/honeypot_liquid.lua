require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local EffectSlowness = require "scripts.effect.effect_slowness"
local sounds = require "data.sounds"
local images = require "data.images"

local HoneypotLiquid = Enemy:inherit()
	
function HoneypotLiquid:init(x, y)
    self:init_enemy(x,y, images.honeypot_liquid, 14, 14)
    self.name = "honeypot_liquid"

    self.gravity_mult = 0.3
    self.follow_player = false

    self.is_stompable = false
    self.is_pushable = false
    self.is_immune_to_bullets = true

    self.counts_as_enemy = false
    
    self.loot = {}
end

function HoneypotLiquid:after_collision(col, other)
    if (col.type ~= "cross" or col.other.name == "") and (col.normal.x == 0 and col.normal.y == -1) then
        self:kill()
    end
end

function HoneypotLiquid:on_death()
    Particles:image(self.mid_x, self.mid_y, 15, {images.honey_fragment_1, images.honey_fragment_2}, 13, nil, 0, 10) 
end


function HoneypotLiquid:on_damage_player(player, damage)
	player:apply_effect(EffectSlowness:new(), 4.0)
    self:kill()
end

return HoneypotLiquid
