require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local SquidChild = require "scripts.actor.enemies.squid_child"
local Explosion = require "scripts.actor.enemies.explosion"
local StateMachine = require "scripts.state_machine"
local sounds = require "data.sounds"
local images = require "data.images"

local SquidMother = Enemy:inherit()

function SquidMother:init(x, y)
    SquidMother.super.init(self, x,y, images.cloud_enemy_size3, 16, 16)
    self.name = "squid_mother"
    
    self.max_life = 10
    self.life = self.max_life

    self.ai_template = "random_rotate"
    
    self.friction_y = self.friction_x
    self.gravity = 0
    
    self.follow_player = false

    self.flip_mode = ENEMY_FLIP_MODE_MANUAL
    self.score = 10

    self.spr:set_anchor(SPRITE_ANCHOR_CENTER_CENTER)

    self.number_of_children = 4
    self.children = {}
    self:spawn_children()
end

function SquidMother:spawn_children()
    self.children = {}
    local previous_leader = self
    for i = 1, self.number_of_children do
        local child = SquidChild:new(self.x, self.y, self, previous_leader)
        table.insert(self.children, child) todo fzijozeoi
        
        previous_leader = child
    end
end

function SquidMother:after_collision(col, other)
    if col.type ~= "cross" then
        local new_vx, new_vy = bounce_vector_cardinal(math.cos(self.direction), math.sin(self.direction), col.normal.x, col.normal.y)
        self.direction = math.atan2(new_vy, new_vx)
    end
end

function SquidMother:update(dt)
    SquidMother.super.update(self, dt)

end

function SquidMother:draw()
    SquidMother.super.draw(self)
end

function SquidMother:on_death()
end

return SquidMother