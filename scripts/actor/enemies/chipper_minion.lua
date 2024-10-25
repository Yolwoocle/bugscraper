require "scripts.util"
local Chipper = require "scripts.actor.enemies.chipper"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local Rect = require "scripts.math.rect"
local sounds = require "data.sounds"
local images = require "data.images"

local ChipperMinion = Chipper:inherit()
	
function ChipperMinion:init_fly(x, y, spr)
    self.super.init(self, x,y, spr or images.chipper_1)
    self.name = "chipper_minion"
end

function ChipperMinion:update(dt)
    self.super.update(self, dt)
end

function ChipperMinion:update_stink_bug(dt)
    self.super.update(self, dt)
end

function ChipperMinion:get_random_walk_duration()
    return random_range(self.min_walk_duration, self.max_walk_duration)
end

function ChipperMinion:detect_player_in_range()
    return true
end

function ChipperMinion:draw()
	self.super.draw(self)
end

function ChipperMinion:after_collision(col, other)
    if col.type ~= "cross" then
        -- Particles:smoke(col.touch.x, col.touch.y)

        if self.state_machine:in_state("attack") and self:is_collision_normal_to_direction(col.normal) then
            self.state_machine:set_state("post_attack")
        end

        if self.state_machine:in_state("wander") then
            local new_vx, new_vy = bounce_vector_cardinal(-math.cos(self.direction * pi/2), -math.sin(self.direction * pi/2), col.normal.x, col.normal.y)
            self.direction = math.floor(math.atan2(new_vy, new_vx) / (pi/2))
        end
    end
end

return ChipperMinion