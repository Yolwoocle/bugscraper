require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local Grasshopper = Enemy:inherit()

function Grasshopper:init(x, y)
    self:init_enemy(x,y, images.grasshopper, 12, 12)
    self.name = "grasshopper"
    self.life = 7
    self.follow_player = false
    
    self.speed = 100
    self.vx = self.speed
    self.friction = 1
    self.friction_x = 1
    self.friction_y = 1
    self.walk_dir_x = random_sample{-1, 1}
    self.is_knockbackable = true

    self.gravity = self.gravity * 0.5

    self.jump_speed = 300
end

function Grasshopper:update(dt)
    self:update_enemy(dt)
    self.vx = self.speed * self.walk_dir_x
end

function Grasshopper:draw()
    self:draw_enemy()
end

function Grasshopper:after_collision(col, other)
    if other.is_solid then
        if col.normal.y == 0 then
            self.walk_dir_x = col.normal.x
        end
    end
end

function Grasshopper:on_grounded()
    self.vy = -self.jump_speed
    Audio:play_var("jump_short", 0.2, 1.2, {pitch=0.4})
end

return Grasshopper