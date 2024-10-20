require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local EffectSlowness = require "scripts.effect.effect_slowness"
local Timer = require "scripts.timer"
local sounds = require "data.sounds"
local images = require "data.images"

local Projectile = Enemy:inherit()
	
function Projectile:init(x, y, image, w, h, invul_duration, angle, min_speed, max_speed)
    -- Changing this to self.super.init causes a stack overflow. I HAVE NO FUCKING CLUE WHY.
    self:init_enemy(x,y, image or images.dung_projectile, w or 8, h or 8)
    self.name = "projectile"
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.gravity_mult = 0.2
    self.follow_player = false

    self.is_stompable = false
    self.is_immune_to_bullets = true
    
    angle = angle or (-pi/2 + random_neighbor(pi/3))
    local spd = random_range(min_speed or 200, max_speed or 300)
    self.vx = math.cos(angle) * spd
    self.vy = math.sin(angle) * spd
    self.friction_x = 1.0

    self.invul_duration = invul_duration or 0.3
    self.invul_timer = Timer:new(self.invul_duration)
    self.invul_timer:start()
    self.damage = 0

    self.loot = {}
end

function Projectile:update(dt)
    self:update_enemy(dt)

    if self.invul_timer:update(dt) then
        self.damage = 1
    end
end

function Projectile:after_collision(col, other)
    if (col.type ~= "cross" or col.other.name == "") then
        self:on_projectile_land()
    end
end

function Projectile:on_projectile_land()
    self:kill()
end

return Projectile
