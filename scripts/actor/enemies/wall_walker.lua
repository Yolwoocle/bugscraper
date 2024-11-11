require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local WallWalker = Enemy:inherit()

-- This ant will walk around corners, but this code will not work for "ledges".
-- Please look at the code of my old project (gameaweek1) if needed
function WallWalker:init(x, y) 
    -- this hitbox is too big, but it works for walls
    -- self:init_enemy(x, y, images.mushroom_ant, 20, 20)
    WallWalker.super.init(self, x, y, images.mushroom_ant1, 20, 20)
    self.name = "wall_walker"
    
    self.follow_player = false
    self.is_on_wall = false

    self.up_vect = {x=0, y=-1}
    self.walk_dir = random_sample{-1, 1}
    self.walk_speed = 70
    self.is_knockbackable = false
    self.is_wall_walking = true

    self.flip = 1

    self.target_rot = 0
end

function WallWalker:update(dt)
    WallWalker.super.update(self, dt)
    
    if self.is_on_wall and self.is_wall_walking then
        local walk_x, walk_y = get_orthogonal(self.up_vect.x, self.up_vect.y, self.walk_dir)
        self.vx = walk_x * self.walk_speed
        self.vy = walk_y * self.walk_speed
        
        self.target_rot = atan2(self.up_vect.y, self.up_vect.x) + pi/2
    end

    self.spr:set_rotation(lerp_angle(self.spr.rot, self.target_rot, 0.4))
    self.spr:set_flip_x(self.walk_dir == -1)
end

function WallWalker:after_collision(col, other)
    if col.type ~= "cross" then
        self.is_on_wall = true

        self.up_vect.x = col.normal.x
        self.up_vect.y = col.normal.y
    end
end

function WallWalker:draw()
    WallWalker.super.draw(self)
end

function WallWalker:on_grounded()
    -- After gounded, reset to floating
    self.gravity = 0
    self.friction_x = 1
    self.friction_y = 1
end

return WallWalker