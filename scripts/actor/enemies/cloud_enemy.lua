require "scripts.util"
local Fly = require "scripts.actor.enemies.fly"
local Timer = require "scripts.timer"
local Explosion = require "scripts.actor.enemies.explosion"
local StateMachine = require "scripts.state_machine"
local sounds = require "data.sounds"
local images = require "data.images"

local CloudEnemy = Fly:inherit()
	
function CloudEnemy:init(x, y, size)
    size = size or 3
    self:init_fly(x,y, images["cloud_enemy_size"..tostring(size)] or images.cloud_enemy_size3, size*8, size*8, false)
    self.size = size
    self.name = "cloud_enemy_CHANGEME"
    self.max_life = 1 + (size-1) * 4
    self.enemies_on_death = 2
    self.life = self.max_life
    self.ai_template = "random_rotate"
    
    self.do_stomp_animation = false
    self.counts_as_enemy = true
    self.follow_player = false

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL

    if self.size > 1 then
        self.loot = {}
    end
    self.anim_frames = nil
    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
end

function CloudEnemy:after_collision(col, other)
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function CloudEnemy:update(dt)
    self:update_fly(dt)

end

function CloudEnemy:draw()
    CloudEnemy.super.draw(self)
end
function CloudEnemy:on_death()
    if self.size <= 2 then
        return
    end
    for i = 1, self.enemies_on_death do
        local slug = CloudEnemy:new(self.x, self.y, self.size - 1)
        slug.vy = -200
        slug.harmless_timer = 0.5
        game:new_actor(slug)
    end
end

return CloudEnemy