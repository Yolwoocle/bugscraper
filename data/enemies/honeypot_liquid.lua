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
    self.is_immune_to_bullets = true
    
    self.loot = {}

    -- self.anim_frame_len = 0.4
    -- self.anim_frames = {images.slug1, images.slug2}
end

function HoneypotLiquid:after_collision(col, other)
    if (col.other.is_solid or col.other.name == "") and (col.normal.x == 0 and col.normal.y == -1) then
        self:kill()
    end
end

function HoneypotLiquid:on_death()
    Particles:image(self.mid_x, self.mid_y, 15, {images.honey_fragment_1, images.honey_fragment_2}, 13, nil, 0, 10)
    
    -- Particles:image(self.mid_x, self.mid_y, 30, images.snail_shell_fragment, 13, nil, 0, 10)
    -- local slug = Slug:new(self.x, self.y)
    -- slug.vy = -200
    -- game:new_actor(slug)
end


function HoneypotLiquid:on_damage_player(player, damage)
	player:apply_effect(EffectSlowness:new(), random_range(5.0, 10.0))
    self:kill()
end

return HoneypotLiquid
