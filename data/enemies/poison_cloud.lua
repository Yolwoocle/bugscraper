require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local StinkBug = Enemy:inherit()
	
function StinkBug:init(x, y, spr)
    self:init_fly(x, y)
end

function StinkBug:init_fly(x, y, spr)
    self:init_enemy(x,y, spr or images.stink_bug_1)
    self.name = "fly"
    self.is_flying = true
    self.life = 10
    self.follow_player = false
    --self.speed_y = 0--self.speed * 0.5
    
    self.speed = random_range(7,13) --10
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.direction = random_range(0, pi2)

    self.gravity = 0
    self.friction_y = self.friction_x

    self.anim_frame_len = 0.05
    self.anim_frames = {images.stink_bug_1, images.stink_bug_1}
    self.do_vx_flipping = false
end

function StinkBug:update(dt)
    self:update_stink_bug(dt)
end

function StinkBug:update_stink_bug(dt)
    self:update_enemy(dt)

    self.direction = self.direction + random_sample({-1, 1}) * dt * 3
    
	self.vx = self.vx + math.cos(self.direction) * self.speed
	self.vy = self.vy + math.sin(self.direction) * self.speed

    self.rot = self.direction
end

function StinkBug:draw()
	self:draw_enemy()
    love.graphics.line(self.mid_x, self.mid_y, self.mid_x + math.cos(self.direction) * 20, self.mid_y + math.sin(self.direction) * 20)
end

function StinkBug:after_collision(col, other)
    -- Pong-like bounce
    if col.other.is_solid then
        Particles:smoke(col.touch.x, col.touch.y)

        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

return StinkBug