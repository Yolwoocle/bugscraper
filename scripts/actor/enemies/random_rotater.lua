require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local images = require "data.images"

local RandomRotater = Enemy:inherit()

function RandomRotater:init(x, y, spr, w, h)
    RandomRotater.super.init(self, x,y, spr, w or 16, h or 16)
    self.name = "random_rotator"
    
    self.max_life = 10
    self.life = self.max_life

    self.ai_template = "random_rotate"
    
    self.friction_y = self.friction_x
    self.gravity = 0
    
    self.follow_player = false

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.score = 10

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)
end

function RandomRotater:after_collision(col, other)
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function RandomRotater:update(dt)
    RandomRotater.super.update(self, dt)
end

function RandomRotater:draw()
    RandomRotater.super.draw(self)
end

return RandomRotater