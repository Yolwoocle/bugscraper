require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local Loot = require "scripts.actor.loot"
local guns = require "data.guns"

local utf8 = require "utf8"

local GunDisplay = Prop:inherit()

function GunDisplay:init(x, y)
    self:init_prop(x, y, images.upgrade_jar, 16, 16)
    self.name = "gun_display"
    
    self.gun = guns.Triple:new(nil)

    self.life = 10
    self.loot = {}

    self.gravity = self.default_gravity
    self.is_flying = false

    self.is_pushable = true
    self.is_knockbackable = true

    self.is_stompable = true
    self.is_killed_on_stomp = false
    self.stomps = 500
    self.damage_on_stomp = 3

	self.destroy_bullet_on_impact = true
	self.is_immune_to_bullets = false

    self.player_detection_range_x = 26
    self.player_detection_range_y = 64
    self.target_players = {}

    self.friction_x = 0.9
    self.self_knockback_mult = 0.7
    
	self.sound_damage = "glass_fracture"
	self.sound_death = "glass_break_weak"
end

function GunDisplay:assign_upgrade(upgrade)
    self.product = upgrade
end

function GunDisplay:update(dt)
    self:update_prop(dt)

    self.gun.x = self.x
    self.gun.y = self.y
end

function GunDisplay:draw()
    if self.gun then
        self.gun:draw()
    end
	self:draw_prop() 
end

function GunDisplay:on_death(damager, reason)
    Particles:image(self.mid_x, self.mid_y, 10, images.glass_shard, self.h)

    local dropped = Loot.Gun:new(self.x, self.y, nil, random_neighbor(20), -random_range(10, 30), self.gun)
    game:new_actor(dropped)
end

function GunDisplay:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" and col.normal.y == 0 then
        -- local dx, dy = bounce_vector_cardinal(self.vx, self.vy, col.normal.x, col.normal.y)
        self.vx = col.normal.x * math.abs(self.vx)
        -- self.vy = dy
    end
end

return GunDisplay