require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local ElectricRays = require "scripts.actor.enemies.electric_rays"
local StateMachine = require "scripts.state_machine"
local Timer = require "scripts.timer"
local Segment = require "scripts.math.segment"
local guns  = require "data.guns"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local Chipper     = require "scripts.actor.enemies.chipper"

local BigCeilingGuy = Enemy:inherit()

function BigCeilingGuy:init(x, y)
    self:init_enemy(x,y, images.big_ceiling_guy, 26*16, 16)
    self.name = "todo_changeme"  --removeme(dont actually)

    -- Parameters 
    self.follow_player = false
    self.life = 800
    self.self_knockback_mult = 0
    self.is_pushable = false

    self.is_affected_by_bounds = false

    self.rays = {}
    self.n_rays = 4
    self.ray_timer = Timer:new({0.5, 1.0})
    self.spawn_timer = Timer:new({2.0, 4.0})
    self.max_chippers = 6
    self.state_machine = StateMachine:new({
        rays = {
            enter = function(state)
                for i = 1, self.n_rays do
                    self.rays_spawned = true
                    self.ray_i = 1

                    local arc = ElectricArc:new(self.x, self.y)
                    arc:set_arc_active(false)
                    arc:set_active(false)
                    self.rays[i] = arc
                    game:new_actor(arc)
                end

                self.chippers = {}
                
                self.ray_timer:start()
                self.spawn_timer:start()
            end,
            update = function(state, dt)
                local cabin_rect = game.level.cabin_inner_rect

                if self.ray_timer:update(dt) then
                    self.ray_i = mod_plus_1(self.ray_i + 1, self.n_rays)
                    
                    local ray = self.rays[self.ray_i]
                    local x1 = random_range(cabin_rect.ax, cabin_rect.bx)
                    local x2 = random_range(cabin_rect.ax, cabin_rect.bx)
                    ray:set_segment(x1, cabin_rect.ay, x2, cabin_rect.by)
                    ray:set_active(true)
                    ray:set_arc_active(false)
                    ray:start_activation_timer(1.0)

                    self.ray_timer:start()
                end

                if self.spawn_timer:update(dt) then
                    if #self.chippers < self.max_chippers then
                        local x0 = random_range(cabin_rect.ax + 16, cabin_rect.bx - 16)
                        local chipper = Chipper:new(x0, self.y + self.h + 16)
                        game:new_actor(chipper)

                        table.insert(self.chippers, chipper)
                    end

                    self.spawn_timer:start()
                end

                for i = #self.chippers, 1, -1 do
                    if self.chippers[i].is_dead then
                        table.remove(self.chippers, i)
                    end
                end
            end,
        }
    }, "rays")
end

function BigCeilingGuy:update(dt)
    self:update_enemy(dt)

    self.state_machine:update(dt)
    self.debug_values[2] = concat(self.life,"❤")
end


function BigCeilingGuy:draw()
    self:draw_enemy()
end

return BigCeilingGuy