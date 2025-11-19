require "scripts.util"
local Chipper = require "scripts.actor.enemies.chipper"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local Rect = require "scripts.math.rect"
local sounds = require "data.sounds"
local images = require "data.images"

local ChipperMinion = Chipper:inherit()
	
function ChipperMinion:init(x, y, direction, attack_speed, wait_duration)
    ChipperMinion.super.init(self, x,y, spr or images.chipper_1)
    self.name = "chipper_minion"
    self.direction = direction or random_sample {0, 2}
    self.target_rot = self.direction * pi/2
    self.spr:set_rotation(self.target_rot)

    self.wander_no_attack_timer:stop()
    self.turn_timer:stop()

    if attack_speed then
        self.attack_speed = attack_speed
    end

    self.loot = {}
    self.score = 0

    self.damage = 0
    self.telegraph_timer:set_duration(wait_duration)
end

function ChipperMinion:update(dt)
    ChipperMinion.super.update(self, dt)    

    if self.state_machine.current_state_name == "telegraph" then
        self.damage = 0
        self.spr:set_color({1, 1, 1, ternary(self.t % 0.2 < 0.1, 1, 0.5)})
        
    else
        self.spr:set_color({1, 1, 1, 1})
        self.damage = 1
    end
end

function ChipperMinion:get_random_walk_duration()
    return random_range(self.min_walk_duration, self.max_walk_duration)
end

function ChipperMinion:detect_player_in_range()
    return true
end

function ChipperMinion:draw()
	ChipperMinion.super.draw(self)
end

function ChipperMinion:after_collision(col, other)
    if col.type ~= "cross" then
        self.death_counts_for_fury_combo = false
        self:kill()
    end
end

return ChipperMinion