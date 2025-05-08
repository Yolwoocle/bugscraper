require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local Spider = Enemy:inherit()

function Spider:init(x, y) 
    self:init_enemy(x, y, images.spider1, 21, 15)
    self.name = "spider"
    self.follow_player = false

    self.life = 8
    self.gravity = -self.default_gravity

    self.anim_frame_len = 0.4
    self.anim_frames = {images.spider1, images.spider2}

    self.time_before_flip = 0
    self.move_dir_x = random_sample{-1, 1}
    self.speed = 5

    self.is_on_ceiling = false
    self.ceiling_y = 0
    self.string_len = 0
    self.max_string_len = random_range(100, 150)
    self.string_grow_dir = 1
    self.string_growth_speed = random_range(30,55)

    self.score = 10
    self.dt = 0

    self.sound_death = {"sfx_enemies_stomp_gore_01", "sfx_enemies_stomp_gore_02", "sfx_enemies_stomp_gore_03", "sfx_enemies_stomp_gore_04"}
    self.sound_stomp = {"sfx_enemies_stomp_gore_01", "sfx_enemies_stomp_gore_02", "sfx_enemies_stomp_gore_03", "sfx_enemies_stomp_gore_04"}
end

function Spider:update(dt)
    self:update_enemy(dt)
    self.dt = dt

    self.time_before_flip = self.time_before_flip - dt
    if self.time_before_flip <= 0 or random_range(0,1) <= 0.01 then
        self.time_before_flip = random_range(0.5, 2)
        
        self.move_dir_x = -self.move_dir_x
    end
    
    self.vx = self.vx + self.move_dir_x * self.speed

    if self.is_on_ceiling then
        self.vy = self.string_grow_dir * self.string_growth_speed
        
        self.string_len = self.y - self.ceiling_y
        if self.string_len > self.max_string_len then
            self.string_grow_dir = -1
        end
        if self.string_len <= 60 then
            self.string_grow_dir = 1
        end
    end
end

function Spider:draw()
    self:draw_enemy()
    if self.is_on_ceiling then
        line_color({1, 1, 1, 0.7}, self.mid_x, self.y, self.mid_x - self.vx*self.dt*3, self.ceiling_y)
    end
end

function Spider:after_collision(col, other)
    if col.type ~= "cross" then
        if col.normal.x == 0 and col.normal.y == 1 then
            self.is_on_ceiling = true
            self.gravity = 0
            self.gravity_y = 0
            self.ceiling_y = self.y
        end
        if col.normal.y == 0 then
            self.time_before_flip = random_range(0.5, 2)
            self.walk_dir_x = col.normal.x
        end
    end
end

return Spider