require "scripts.util"
local SquidMother = require "scripts.actor.squid_mother"
local Timer = require "scripts.timer"
local Explosion = require "scripts.actor.enemies.explosion"
local StateMachine = require "scripts.state_machine"
local sounds = require "data.sounds"
local images = require "data.images"

local SquidChild = SquidMother:inherit()

function SquidChild:init(x, y, mother, next_squid)
    SquidChild.super.init(self, x,y, images.cloud_enemy_size1, 8, 8)
    self.name = "squid_child"
    
    self.max_life = 2
    self.life = self.max_life

    self.mother = mother
end

function SquidChild:after_collision(col, other)
end

function SquidChild:update(dt)
    SquidChild.super.update(self, dt)

end

function SquidChild:draw()
    SquidChild.super.draw(self)
end

function SquidChild:on_death()
end

return SquidChild