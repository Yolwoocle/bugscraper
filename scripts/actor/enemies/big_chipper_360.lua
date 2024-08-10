require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Chipper360 = require "scripts.actor.enemies.chipper_360"
local sounds = require "data.sounds"
local images = require "data.images"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Segment = require "scripts.math.segment"
local guns  = require "data.guns"

local BigChipper360 = Chipper360:inherit()

function BigChipper360:init(x, y)
    self.super.init(self, x, y)
    self.name = "todo_changeme"
    self:set_dimensions(24, 24)
    self.spr:set_scale(2, 2)
    self.attack_bounces = 8
    self.life = 40
    self.is_stompable = false
end

function BigChipper360:update(dt)
    self.super.update(self, dt)
end

function BigChipper360:enter_wander()
    self.super.enter_wander(self)
end

function BigChipper360:detect_player_in_range()
    return self.super.detect_player_in_range(self)
end

return BigChipper360