require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local Slug = require "data.enemies.slug"

local SnailShelled = Enemy:inherit()

function SnailShelled:init(x, y, spr)
    self:init_snail_shelled(x, y, spr)
end

function SnailShelled:init_snail_shelled(x, y, spr)
    self:init_enemy(x,y, spr or images.snail_shell, 16, 16)
    self.name = "snail_shelled"
    self.is_flying = true
    self.follow_player = false
    self.do_stomp_animation = false

    self.destroy_bullet_on_impact = false
    self.is_bouncy_to_bullets = true
    self.is_immune_to_bullets = true

    self.rot_speed = 3

    self.gravity = 0
    self.friction_y = self.friction_x 

    self.pong_speed = 40
    self.dir = (pi/4 + pi/2 * love.math.random(0,3)) % pi2
    -- self.dir = love.math.random() * pi2
    self.pong_vx = cos(self.dir) * self.pong_speed
    self.pong_vy = sin(self.dir) * self.pong_speed

    self.center_sprite = true
    -- self.spr_oy = floor((self.spr_h - self.h) / 2)
    self.sound_death = "snail_shell_crack"
    self.sound_stomp = "snail_shell_crack"
    self:update_sprite_offset()
end

function SnailShelled:update(dt)
    self:update_snail_shelled(dt)
end

function SnailShelled:update_snail_shelled(dt)
    self:update_enemy(dt)
    self.rot = self.rot + self.rot_speed * dt

    self.vx = self.vx + (self.pong_vx or 0)
    self.vy = self.vy + (self.pong_vy or 0)
end

function SnailShelled:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" or col.other.name == "" then
        local s = "metalfootstep_0"..tostring(love.math.random(0,4))
        Audio:play_var(s, 0.3, 1.1, {pitch=0.8, volume=0.5})

        Particles:smoke(col.touch.x, col.touch.y)

        self.pong_vx, self.pong_vy = bounce_vector_cardinal(self.pong_vx, self.pong_vy, col.normal.x, col.normal.y)
    end
end

function SnailShelled:draw()
    self:draw_enemy()
end

function SnailShelled:on_death()
    Particles:image(self.mid_x, self.mid_y, 30, images.snail_shell_fragment, 13, nil, 0, 10)
    local slug = Slug:new(self.x, self.y)
    slug.vy = -200
    game:new_actor(slug)
end

return SnailShelled