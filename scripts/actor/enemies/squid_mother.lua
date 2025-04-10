require "scripts.util"
local RandomRotater = require "scripts.actor.enemies.random_rotater"
local Timer = require "scripts.timer"
local SquidChild = require "scripts.actor.enemies.squid_child"
local StateMachine = require "scripts.state_machine"
local images = require "data.images"

local SquidMother = RandomRotater:inherit()

function SquidMother:init(x, y)
    SquidMother.super.init(self, x,y, images.cloud_enemy_size3, 24, 24)
    self.name = "squid_mother"

    self.life = 10
    
    self.number_of_children = 6
    self.children = {}
    self:spawn_children()
end

function SquidMother:spawn_children()
    self.children = {}
    local previous_superior = self
    for i = 1, self.number_of_children do
        local child = SquidChild:new(self.x, self.y, self, previous_superior)
        game:new_actor(child)
        table.insert(self.children, child) --todo fzijozeoi
        
        previous_superior = child
    end
end

function SquidMother:after_collision(col, other)
    SquidMother.super.after_collision(self, col, other)
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