require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local Slug = require "scripts.actor.enemies.slug"

local PongBall = Enemy:inherit()

function PongBall:init(x, y, spr)
    self:init_pong_ball(x, y, spr)
end

function PongBall:init_pong_ball(x, y, spr)
    self:init_enemy(x,y, spr or images.snail_shell, 16, 16)
    self.name = "pong_ball"
    self.is_flying = true
    self.follow_player = false
    self.do_stomp_animation = false

    self.rot_speed = 3

    self.gravity = 0
    self.friction_x = 1.0 
    self.friction_y = self.friction_x 

    self:init_pong()
    
    self.center_sprite = true
    self:update_sprite_offset()
end

function PongBall:init_pong(speed)
    local dir = (pi/4 + pi/2 * love.math.random(0,3)) % pi2
    self.is_ponging = true
    self.pong_speed = speed or 100
    self.pong_vx = cos(dir) * self.pong_speed
    self.pong_vy = sin(dir) * self.pong_speed
end

function PongBall:update(dt)
    self:update_pong_ball(dt)
end

function PongBall:update_pong_ball(dt)
    self:update_enemy(dt)
    self.rot = self.rot + self.rot_speed * dt

    if self.is_ponging then
        self.vx = (self.pong_vx or 0)
        self.vy = (self.pong_vy or 0)
    end
end

function PongBall:after_collision(col, other)
    self:after_collision_pong_ball(col, other)
end

function PongBall:after_collision_pong_ball(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        if self.is_ponging then
            local s = "metalfootstep_0"..tostring(love.math.random(0,4))
            Audio:play_var(s, 0.3, 1.1, {pitch=0.8, volume=0.5})
            Particles:smoke(col.touch.x, col.touch.y)

            self.pong_vx, self.pong_vy = bounce_vector_cardinal(self.pong_vx, self.pong_vy, col.normal.x, col.normal.y)
        end
    end
end

function PongBall:draw()
    self:draw_pong_ball()
end

function PongBall:draw_pong_ball()
    self:draw_enemy()
end

return PongBall