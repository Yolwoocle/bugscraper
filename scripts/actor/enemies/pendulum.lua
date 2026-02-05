require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local Timer = require "scripts.timer"
local sounds = require "data.sounds"
local images = require "data.images"

local spike_ball = require "data.models.spike_ball"
local Renderer3D = require "scripts.graphics.3d.renderer_3d"
local Object3D = require "scripts.graphics.3d.object_3d"

local Pendulum = Enemy:inherit()
	
function Pendulum:init(x, y, params) --angle_range, radius, swing_speed, initial_angle_t)
    params = params or {}
    Pendulum.super.init(self, x,y, images.dung_beetle_shield, 32, 32)
    self.name = "pendulum"
    self.is_flying = true
    self.life = 10
    self.follow_player = false
    self.is_stompable = false
    self.is_affected_by_bounds = false
    self.is_affected_by_walls = false
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true
    self.counts_as_enemy = false

    self.is_pushable = false
    
    self.anchor_x = x
    self.anchor_y = y
    self.angle_range = param(params.angle_range, pi/3)
    self.radius = param(params.radius, 200)
    self.swing_speed = param(params.swing_speed, 2)

    self.angle = 0.0
    self.angle_t = param(params.initial_angle_t, (random_range_int(0, 1) * pi))

    self.gravity = 0
    self.friction_y = self.friction_x

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    self.score = 0

    -- self.anim_frame_len = 0.05
    -- self.anim_frames = {images.fly1, images.fly2}

    self.damage = 0
    self.no_damage_timer = Timer:new(param(params.no_damage_time, 1.5))
    self.no_damage_timer:start()
    self.t = 0.0

    self.def_ball_scale = 20
    self.object_3d = Object3D:new(spike_ball)
    self.renderer = Renderer3D:new({self.object_3d})

    self.renderer.line_color = COL_WHITE
	self.renderer.lighting_palette = {{1, 1, 1, 0}}
    self.object_3d.scale:sset(self.def_ball_scale)
    self.object_3d.position.x = 200
    self.object_3d.position.y = 200
    self.ball_rotate_speed = 4
    
    self:set_constant_sound("amb", "sfx_enemy_pendulum_ambient", true)
    self:set_constant_sound_volume("amb", 1.0)
end

function Pendulum:ready(dt)
    self.rope = ElectricArc:new(self.x, self.y)
    self.rope.lightning.style = LIGHTNING_STYLE_BITS
    self.rope.is_arc_active = false
    game:new_actor(self.rope)

    self:update_pendulum_position(0)
end

function Pendulum:update(dt)
    Pendulum.super.update(self, dt)

    self.no_damage_timer:update(dt)
    if self.no_damage_timer.is_active then
        local flash = self.t % 0.2 < 0.1
        self.spr.color = ternary(flash, COL_WHITE, {1, 1, 1, 0.3})
        self.damage = 0
        
        self:update_pendulum_position(0)
    else 
        self.damage = 1
        self.spr.color = COL_WHITE

        self:update_pendulum_position(dt)
    end 

    -- 3D
    self.renderer.line_color = self.spr.color
    self.object_3d.position.x = self.x + self.w/2
    self.object_3d.position.y = self.y + self.h/2
    self.object_3d.rotation.z = math.atan2(self.y + self.h/2 - self.anchor_y, self.x + self.w/2 - self.anchor_x)
    self.object_3d.rotation.x = self.object_3d.rotation.x + dt*self.ball_rotate_speed

    self.renderer:update(dt)
end

function Pendulum:update_pendulum_position(dt)
    local old_angle = self.angle
    self.angle = pi/2 + math.cos(self.angle_t) * self.angle_range                
    self:set_position(
        self.anchor_x + math.cos(self.angle) * self.radius - self.w / 2,
        self.anchor_y + math.sin(self.angle) * self.radius - self.h / 2
    )
    self.rope:set_segment(self.anchor_x, self.anchor_y, self.x + self.w/2, self.y + self.h/2)

    self.angle_t = self.angle_t + dt * self.swing_speed

    if (old_angle < pi/2 and self.angle > pi/2) or (old_angle > pi/2 and self.angle < pi/2) then
        self:play_sound_var("sfx_enemy_pendulum_swing_{01-06}", 0.1, 1.1)
    end
end

function Pendulum:on_removed()
    if self.rope then
        self.rope:remove()
    end
end

function Pendulum:draw()
    Pendulum.super.draw(self)
    
    self.renderer:draw()
end

return Pendulum