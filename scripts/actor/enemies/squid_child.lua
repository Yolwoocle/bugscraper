require "scripts.util"
local RandomRotater = require "scripts.actor.enemies.random_rotater"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local images = require "data.images"

local SquidChild = RandomRotater:inherit()

function SquidChild:init(x, y, mother, superior)
    SquidChild.super.init(self, x,y, images.cloud_enemy_size1, 8, 8)
    self.name = "squid_mother"
    
    self.mother = mother
    self.superior = superior

    self.life = 2

    self.follow_offset = 16

    self.is_panicking = false
    self.panic_timer = Timer:new(random_range(1.5, 2.0))

    self.random_rotate_speed = 20
    self.random_rotate_probability = 0.7

    self.is_pushable = false
end

function SquidChild:after_collision(col, other)
    SquidChild.super.after_collision(self, col, other)
end

function SquidChild:update(dt)
    SquidChild.super.update(self, dt)

    if not self.is_panicking then
        local target_x = self.superior.mid_x - math.cos(self.superior.direction)
        local target_y = self.superior.mid_y - math.sin(self.superior.direction)
    
        self.direction = get_angle_between_vectors(self.mid_x, self.mid_y, target_x, target_y)
        
        if self.superior.is_dead or self.superior.is_panicking then
            self.is_panicking = true
            -- self:set_ai_template("random_rotate")
            self.ai_template = "random_rotate"
            self.speed = 40
            self.panic_timer:start()
        end
        
    else
        if self.panic_timer:update(dt) then
            self:kill()
        end
    end

end

function SquidChild:draw()
    SquidChild.super.draw(self)
end

function SquidChild:on_death()
end

return SquidChild