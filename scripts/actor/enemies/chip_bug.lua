require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local PoisonCloud = require "scripts.actor.enemies.poison_cloud"
local sounds = require "data.sounds"
local images = require "data.images"

local ChipBug = Enemy:inherit()
	
function ChipBug:init(x, y, spr)
    self:init_fly(x, y)
end

function ChipBug:init_fly(x, y, spr)
    self:init_enemy(x,y, spr or images.stink_bug_1)
    self.name = "chip_bug"
    self.is_flying = true
    self.life = 10
    self.follow_player = false
    --self.speed_y = 0--self.speed * 0.5
    
    self.speed = random_range(7,13) --10
    -- self.speed_x = self.speed
    -- self.speed_y = self.speed

    self.direction = random_range_int(0, 3)

    self.gravity = 0
    self.friction_y = self.friction_x

    self.anim_frame_len = 0.05
    self.anim_frames = {images.stink_bug_1, images.stink_bug_1}
    self.do_vx_flipping = false

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    self.sound_death = "stink_bug_death"
    self.sound_stomp = "stink_bug_death"
end

function ChipBug:update(dt)
    self:update_stink_bug(dt)
end

function ChipBug:update_stink_bug(dt)
    self:update_enemy(dt)

    if random_range(0, 1) < 0.02 then
        self.direction = (self.direction + random_sample({-1, 1})) % 4
    end
    
	self.vx = self.vx + math.cos(self.direction * pi/2) * self.speed
	self.vy = self.vy + math.sin(self.direction * pi/2) * self.speed
    
    self.spr:set_rotation(self.direction * pi/2)

    if random_range(0, 1) < 0.02 then
        -- Particles:word(self.mid_x, self.mid_y, random_sample{"0", "1"}, random_sample{COL_LIGHT_GREEN, COL_MID_GREEN})
    end
end

function ChipBug:draw()
	self:draw_enemy()
end

function ChipBug:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        -- Particles:smoke(col.touch.x, col.touch.y)

        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction * pi/2), math.sin(self.direction * pi/2), col.normal.x, col.normal.y)
        self.direction = math.floor(math.atan2(new_vy, new_vx) / (pi/2))
    end
end

return ChipBug