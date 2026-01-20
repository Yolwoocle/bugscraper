require "scripts.util"
local DrillBee = require "scripts.actor.enemies.drill_bee"
local Timer = require "scripts.timer"
local StateMachine = require "scripts.state_machine"
local Segment = require "scripts.math.segment"
local Rect = require "scripts.math.rect"
local sounds = require "data.sounds"
local images = require "data.images"
local Explosion = require "scripts.actor.enemies.explosion"

local DrillBeeMinion = DrillBee:inherit()
	
function DrillBeeMinion:init(x, y, params)
    params = params or {}
    DrillBeeMinion.super.init(self, x,y, params.spr)
    self.name = "drill_bee_minion"

    self.direction = params.direction 

    self.state_machine:set_state("telegraph")

    self.loot = {}
end

function DrillBeeMinion:detect_player_in_range()
    return true
end


function DrillBeeMinion:update(dt)
    DrillBeeMinion.super.update(self, dt)
end

function DrillBeeMinion:after_collision(col, other)
    self.state_machine:_call("after_collision", col)
end

function DrillBeeMinion:draw()
    self:draw_enemy()
end

return DrillBeeMinion