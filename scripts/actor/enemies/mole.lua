require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local WallWalker = require "scripts.actor.enemies.wall_walker"

local Mole = WallWalker:inherit()

-- This ant will walk around corners, but this code will not work for "ledges".
-- Please look at the code of my old project (gameaweek1) if needed
function Mole:init(x, y) 
    -- this hitbox is too big, but it works for walls
    -- self:init_enemy(x, y, images.mushroom_ant, 20, 20)
    Mole.super.init(self, x, y, images.mole_digging_1, 20, 20)
    self.name = "mushroom_ant"

    -- self.spr = AnimatedSprite todo
 
    self.state_timer = Timer:new()
    self.state_machine = StateMachine:new({
        dig = {
            enter = function(state)
                self.walk_speed = 200
                self.damage = 0
                self.is_stompable = false
                self.walk_dir = random_sample{-1, 1}
                self.state_timer:start(random_range(1, 2))

                self.is_wall_walking = true
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "telegraph"
                end
            end,
        },
        telegraph = {
            enter = function(state)
                self.walk_speed = 0
                self.damage = 0
                self.is_stompable = false
                self.spr:update_offset(0, 0)

                self.state_timer:start(1)
            end,
            update = function(state, dt)
                self.spr:update_offset(random_polar(3), random_polar(3))
                
                if self.state_timer:update(dt) then
                    return "jump"
                end
            end,
            draw = function(state)
                self.spr:update_offset(0, 0)
            end,
        },
        jump = {
            enter = function(state)
                self.is_wall_walking = false
                self.vx = self.up_vect.x * 200
                self.vy = self.up_vect.y * 200
                self.is_stompable = true
            end,

            update = function(state, dt)

            end,

            on_collision = function(state, col, other)
                if col.type ~= "cross" then
                    print("ezzerzer")
                    self.is_on_wall = true
                    self.is_wall_walking = true
                    self.up_vect.x = col.normal.x
                    self.up_vect.y = col.normal.y

                    self.state_machine:set_state("linger")
                end
            end,
        },
        linger = {
            enter = function(state)
                self.walk_speed = 0
                self.state_timer:start(1)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    return "dig"
                end
            end,
        }
    }, "dig")
end

function Mole:update(dt)
    self.state_machine:update(dt)

    self.debug_values[1] = self.state_machine.current_state_name
    Mole.super.update(self, dt)
end

function Mole:on_collision(col, other)
    Mole.super.on_collision(self, col, other)
    self.state_machine:_call("on_collision", col, other)
end

function Mole:draw()
    Mole.super.draw(self)
end

return Mole