require "scripts.util"
local Chipper = require "scripts.actor.enemies.chipper"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local Rect = require "scripts.math.rect"
local sounds = require "data.sounds"
local images = require "data.images"

local ChipperMinion = Chipper:inherit()
	
function ChipperMinion:init(x, y, spr, direction)
    self.super.init(self, x,y, spr or images.chipper_1)
    self.name = "chipper_minion"
    self.direction = direction or random_sample {0, 2}
    self.target_rot = self.direction * pi/2
    self.spr:set_rotation(self.target_rot)

    self.wander_no_attack_timer:stop()
    self.turn_timer:stop()

    self.loot = {}
end

function ChipperMinion:update(dt)
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
        self:kill()
    end
end

return ChipperMinion