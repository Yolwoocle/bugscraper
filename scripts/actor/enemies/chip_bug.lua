require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local PoisonCloud = require "scripts.actor.enemies.poison_cloud"
local sounds = require "data.sounds"
local images = require "data.images"

local ChipBug = Enemy:inherit()
	
function ChipBug:init(x, y, spr)
    self:init_fly(x, y)
end

function ChipBug:init_fly(x, y, spr)
    self:init_enemy(x,y, spr or images.chip_bug_1)
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

    self.anim_frame_len = 0.2
    self.anim_frames = {images.chip_bug_1, images.chip_bug_2, images.chip_bug_3, images.chip_bug_2}
	self.flip_mode = ENEMY_FLIP_MODE_MANUAL

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    self.min_walk_duration = 0.3
    self.max_walk_duration = 1.0
    self.turn_timer = Timer:new(self:get_random_walk_duration())
    self.turn_timer:start()
end

function ChipBug:update(dt)
    self:update_stink_bug(dt)
end

function ChipBug:update_stink_bug(dt)
    self:update_enemy(dt)

    if self.turn_timer:update(dt) then
        self.turn_timer:set_duration(self:get_random_walk_duration())
        self.turn_timer:start()

        self.direction = (self.direction + random_sample({-1, 1})) % 4
    end
    
	self.vx = self.vx + math.cos(self.direction * pi/2) * self.speed
	self.vy = self.vy + math.sin(self.direction * pi/2) * self.speed
    
    self.spr:set_rotation(self.direction * pi/2)

    if random_range(0, 1) < 0.02 then
        -- Particles:word(self.mid_x, self.mid_y, random_sample{"0", "1"}, random_sample{COL_LIGHT_GREEN, COL_MID_GREEN})
    end
end

function ChipBug:get_random_walk_duration()
    return random_range(self.min_walk_duration, self.max_walk_duration)
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