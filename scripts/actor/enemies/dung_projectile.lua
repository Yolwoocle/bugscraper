require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local EffectSlowness = require "scripts.effect.effect_slowness"
local Timer = require "scripts.timer"
local sounds = require "data.sounds"
local images = require "data.images"

local DungProjectile = Enemy:inherit()
	
function DungProjectile:init(x, y)
    self:init_enemy(x,y, images.dung_projectile, 8, 8)
    self.name = "honeypot_liquid"

    self.gravity_mult = 0.2
    self.follow_player = false

    self.is_stompable = false
    self.is_immune_to_bullets = true
    
    local angle = -pi/2 + random_neighbor(pi/3)
    local spd = random_range(200, 300)
    self.vx = math.cos(angle) * spd
    self.vy = math.sin(angle) * spd
    self.friction_x = 1.0

    self.invul_timer = Timer:new(0.3)
    self.invul_timer:start()
    self.damage = 0

    self.loot = {}
end

function DungProjectile:update(dt)
    self.super.update(self, dt)

    if self.invul_timer:update(dt) then
        self.damage = 1
        self:set_image(images.dung_projectile)
    end
end

function DungProjectile:after_collision(col, other)
    if (col.type ~= "cross" or col.other.name == "") then
        self:kill()
    end
end

-- function DungProjectile:on_death()
--     Particles:image(self.mid_x, self.mid_y, 15, {images.honey_fragment_1, images.honey_fragment_2}, 13, nil, 0, 10) 
-- end

return DungProjectile
