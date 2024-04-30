require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"

local MushroomAnt = Enemy:inherit()

-- This ant will walk around corners, but this code will not work for "ledges".
-- Please look at the code of my old project (gameaweek1) if needed
function MushroomAnt:init(x, y) 
    -- this hitbox is too big, but it works for walls
    -- self:init_enemy(x, y, images.mushroom_ant, 20, 20)
    self:init_enemy(x, y, images.mushroom_ant1, 20, 20)
    self.name = "mushroom_ant"
    self.follow_player = false

    self.is_on_wall = false

    self.up_vect = {x=0, y=-1}
    self.walk_dir = random_sample{-1, 1}
    self.walk_speed = 70
    self.is_knockbackable = false

    self.flip = 1
    self.gun = Guns.unlootable.MushroomAntGun:new(self)

    self.rot = 0
    self.target_rot = 0

    self.shoot_cooldown_range = {2, 3}
    self.shoot_timer = random_range(unpack(self.shoot_cooldown_range))

    self.anim_frames = {images.mushroom_ant1, images.mushroom_ant2}
    self.anim_frame_len = 0.3
end

function MushroomAnt:update(dt)
    self:update_enemy(dt)
    
    if self.is_on_wall then
        local walk_x, walk_y = get_orthogonal(self.up_vect.x, self.up_vect.y, self.walk_dir)
        self.vx = walk_x * self.walk_speed
        self.vy = walk_y * self.walk_speed
        
        self.target_rot = atan2(self.up_vect.y, self.up_vect.x) + pi/2
    end

    self.rot = lerp_angle(self.rot, self.target_rot, 0.4)
    self.spr:set_flip_x(self.walk_dir)

    self.shoot_timer = self.shoot_timer - dt
    if self.shoot_timer <= 0 then
        local r1, r2 = unpack(self.shoot_cooldown_range)
        self.shoot_timer = random_range(r1, r2)

        local vx, vy = cos(self.rot - pi/2), sin(self.rot - pi/2)

        self.gun:shoot(dt, self, self.mid_x, self.mid_y, vx, vy)
    end
end

function MushroomAnt:after_collision(col, other)
    if col.type ~= "cross" then
        self.is_on_wall = true

        self.up_vect.x = col.normal.x
        self.up_vect.y = col.normal.y
    end
end

function MushroomAnt:draw()
    local f = (self.damaged_flash_timer > 0) and draw_white or gfx.draw
    self:draw_actor(f)
end

function MushroomAnt:on_grounded()
    -- After gounded, reset to floating
    self.gravity = 0
    self.friction_x = 1
    self.friction_y = 1
end

return MushroomAnt