require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local PoisonCloud = require "scripts.actor.enemies.poison_cloud"
local sounds = require "data.sounds"
local images = require "data.images"
local AnimatedSprite = require "scripts.graphics.animated_sprite"

local StinkBug = Enemy:inherit()
	
function StinkBug:init(x, y, spr)
    self:init_fly(x, y)
end

function StinkBug:init_fly(x, y, spr)
    self:init_enemy(x,y, spr or images.stink_bug_1)
    self.name = "stink_cloud"
    self.is_flying = true
    self.life = 7
    self.follow_player = false
    --self.speed_y = 0--self.speed * 0.5
    
    self.speed = random_range(7,13) --10
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.direction = random_range(0, pi2)

    self.gravity = 0
    self.friction_y = self.friction_x

    self.spr = AnimatedSprite:new({
        walk = {images.stink_bug_walk, 0.2, 2},
    }, "walk")
	self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
    
    self.sound_death = "stink_bug_death"
    self.sound_stomp = "stink_bug_death"
end

function StinkBug:update(dt)
    self:update_stink_bug(dt)
end

function StinkBug:update_stink_bug(dt)
    self:update_enemy(dt)

    self.direction = self.direction + random_sample({-1, 1}) * dt * 3
    
	self.vx = self.vx + math.cos(self.direction) * self.speed
	self.vy = self.vy + math.sin(self.direction) * self.speed

    self.spr:set_rotation(self.direction)
end

function StinkBug:draw()
	self:draw_enemy()
end

function StinkBug:after_collision(col, other)
    -- Pong-like bounce
    if col.type ~= "cross" then
        -- Particles:smoke(col.touch.x, col.touch.y)

        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function StinkBug:on_death()
    for i = 1, random_range_int(3, 5) do
        local spawn_x = clamp(self.mid_x - 10, game.level.cabin_rect.ax, game.level.cabin_rect.bx - 20)
        local spawn_y = clamp(self.mid_y - 10, game.level.cabin_rect.ay, game.level.cabin_rect.by - 20)
        local cloud = PoisonCloud:new(spawn_x, spawn_y)

        local d = random_range(0, pi2)
        local r = random_range(0, 200)
        cloud.vx = math.cos(d) * r
        cloud.vy = math.sin(d) * r
        game:new_actor(cloud)
    end
end

return StinkBug