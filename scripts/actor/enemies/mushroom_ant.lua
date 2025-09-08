require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local WallWalker = require "scripts.actor.enemies.wall_walker"

local MushroomAnt = WallWalker:inherit()

-- This ant will walk around corners, but this code will not work for "ledges".
-- Please look at the code of my old project (gameaweek1) if needed
function MushroomAnt:init(x, y) 
    -- this hitbox is too big, but it works for walls
    -- self:init_enemy(x, y, images.mushroom_ant, 20, 20)
    MushroomAnt.super.init(self, x, y, images.mushroom_ant1, 20, 20)
    self.name = "mushroom_ant"
    self.gun = Guns.unlootable.MushroomAntGun:new(self)

    self.walk_speed = random_range(50, 90)

    self.shoot_cooldown_range = {2, 3}
    self.shoot_timer = random_range(unpack(self.shoot_cooldown_range))

    self.anim_frames = {images.mushroom_ant1, images.mushroom_ant2}
    self.anim_frame_len = 0.3
    self.score = 10
    
    self.sound_death = "sfx_enemy_kill_general_stomp_{01-10}"
    self.sound_stomp = "sfx_enemy_kill_general_stomp_{01-10}"
end

function MushroomAnt:update(dt)
    MushroomAnt.super.update(self, dt)
    
    self.shoot_timer = self.shoot_timer - dt
    if self.shoot_timer <= 0 then
        local r1, r2 = unpack(self.shoot_cooldown_range)
        self.shoot_timer = random_range(r1, r2)

        local vx, vy = cos(self.spr.rot - pi/2), sin(self.spr.rot - pi/2)

        self.gun:shoot(dt, self, self.mid_x, self.mid_y, vx, vy)
    end
end

function MushroomAnt:draw()
    MushroomAnt.super.draw(self)
end

return MushroomAnt