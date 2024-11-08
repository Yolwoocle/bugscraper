require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local Timer = require "scripts.timer"
local sounds = require "data.sounds"
local images = require "data.images"

local Pendulum = Enemy:inherit()
	
function Pendulum:init(x, y, angle_range, radius, swing_speed, initial_angle_t)
    Pendulum.super.init(self, x,y, images.dung_beetle_shield, 32, 32)
    self.name = "pendulum"
    self.is_flying = true
    self.life = 10
    self.follow_player = false
    self.is_stompable = false
    self.is_affected_by_bounds = false
    self.affected_by_walls = false
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

    self.is_pushable = false
    
    self.anchor_x = x
    self.anchor_y = y
    self.angle_range = angle_range or pi/3
    self.radius = radius or 200
    self.swing_speed = swing_speed or 2

    self.angle = 0.0
    self.angle_t = initial_angle_t or (random_range_int(0, 1) * pi)

    self.gravity = 0
    self.friction_y = self.friction_x

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    -- self.anim_frame_len = 0.05
    -- self.anim_frames = {images.fly1, images.fly2}

    self.damage = 0
    self.no_damage_timer = Timer:new(1.0)
    self.no_damage_timer:start()
    self.t = 0.0

    self.rope = ElectricArc:new(self.x, self.y)
    self.rope.is_arc_active = false
    game:new_actor(self.rope)

    self:update_pendulum_position(0)
end

function Pendulum:update(dt)
    Pendulum.super.update(self, dt)

    self.t = self.t + dt
    self.no_damage_timer:update(dt)
    if self.no_damage_timer.is_active then
        self.spr.color = ternary(self.t % 0.2 < 0.1, COL_WHITE, {1, 1, 1, 0.5})
        self.damage = 0

        self:update_pendulum_position(0)
    else 
        self.damage = 1
        self.spr.color = COL_WHITE

        self:update_pendulum_position(dt)
    end 
end

function Pendulum:update_pendulum_position(dt)
    self.angle = pi/2 + math.cos(self.angle_t) * self.angle_range                
    self:set_pos(
        self.anchor_x + math.cos(self.angle) * self.radius - self.w / 2,
        self.anchor_y + math.sin(self.angle) * self.radius - self.h / 2
    )
    self.rope:set_segment(self.anchor_x, self.anchor_y, self.x + self.w/2, self.y + self.h/2)

    self.angle_t = self.angle_t + dt * self.swing_speed
end

function Pendulum:on_removed()
    self.rope:remove()
end

return Pendulum