require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local images = require "data.images"

local Frog = Enemy:inherit()

function Frog:init(x, y)
    self:init_enemy(x, y, images.slug1, 14, 9)
    self.name = "slug"
    self.follow_player = false

    self.gravity = self.default_gravity * 0.5

    self.def_speed_x = self.speed_x

    self.anim_frame_len = 0.4
    self.anim_frames = {images.slug1, images.slug2}

    self.def_friction_x = self.friction_x
    self.jump_timer = Timer:new(0)
    self.jump_delay_range = {0.5, 2.0}
    self:reset_jump_timer()
end

function Frog:reset_jump_timer()
    self.jump_timer:start(random_range(self.jump_delay_range[1], self.jump_delay_range[2]))
end

function Frog:jump()
    self.vy = -random_range(100, 400)
    self.vx = random_sample{-1, 1} * random_range(200, 400)
end

function Frog:update(dt)
    self.friction_x = ternary(self.is_grounded, self.def_friction_x, 1)
    if not self.jump_timer.is_active and self.is_grounded then
        self:reset_jump_timer()
    end
    if self.jump_timer:update(dt) then
        self:jump()
    end

    self:update_enemy(dt) 
end

function Frog:after_collision(col, other)
    if col.type ~= "cross" and col.normal.y == 0 then
        self.vx = col.normal.x * math.abs(self.vx)
    end
end

function Frog:draw()
    self:draw_enemy()
end

return Frog