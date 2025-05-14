require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local ArumTitanMinion = require "scripts.actor.enemies.arum_titan_minion"
local StateMachine = require "scripts.state_machine"
local AnimatedSprite = require "scripts.graphics.animated_sprite"
local Timer = require "scripts.timer"
local images = require "data.images"

local ArumTitanBoss = Enemy:inherit()
	
function ArumTitanBoss:init(x, y, spr, w, h)
    ArumTitanBoss.super.init(self, x,y, spr or images.arum_titan_boss, 32 or w, 32 or h)

    self.name = "arum_titan_boss"
    self.is_flying = true
    self.life = 10
    
    self.speed = 0
    self.speed_x = self.speed
    self.speed_y = self.speed

    self.gravity = 0
    self.friction_y = self.friction_x
    self.self_knockback_mult = 0
    self.is_pushable = false
    self.is_stompable = false

    self.spr = AnimatedSprite:new({
        closed = {{images.arum_titan_boss_spiked}, 0.1},
        opened = {{images.arum_titan_boss}, 0.1},
    }, "closed", SPRITE_ANCHOR_CENTER_CENTER)

	self.score = 10
    self:set_max_life(100)
    self.opened_life_threshold = 50

    self.minion_layers = {
        {
            amount = 5,
            rotate_distance = 80,
            rotate_speed = pi2*0.1,
        },
        {
            amount = 5,
            rotate_distance = 160,
            rotate_speed = -pi2*0.1,
        }
    }
    
    self.minions = {}

    self:set_bouncy(true)
    self.state_timer = Timer:new(0)
    self.state_machine = StateMachine:new({
        closed = {
            enter = function(state)
                self:set_bouncy(true)
                
                self:spawn_minions(self.minion_layers)
                self.spr:set_animation("closed")
                self.is_stompable = false
            end,
            update = function(state, dt)
                for i = #self.minions, 1, -1 do
                    if self.minions[i].is_dead then
                        table.remove(self.minions, i)
                    end
                end

                if #self.minions == 0 then
                    return "opened"
                end 
            end
        },
        opened = {
            enter = function(state)
                self:set_bouncy(false)
                
                self.spr:set_animation("opened")
                state.reference_life = self.life
                self.state_timer:start(10.0)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) or self.life <= state.reference_life - self.opened_life_threshold then
                    return "closed"
                end
            end,
        }
    }, "closed")
end

function ArumTitanBoss:update(dt)
    ArumTitanBoss.super.update(self, dt)

    -- self.debug_values[1] = #self.minions
    self.debug_values[2] = concat(self.life, " HP")
    self.state_machine:update(dt)
end

function ArumTitanBoss:spawn_minions(layers)
    for i_layer = 1, #layers do
        local layer = layers[i_layer]
        local amount = layer.amount
        for i = 0, amount-1 do
            local a = ArumTitanMinion:new(0, 0, self, {
                rotate_distance = layer.rotate_distance,
                rotate_angle = pi2*(i/amount),
                rotate_speed = layer.rotate_speed,
            })
            game:new_actor(a)

            table.insert(self.minions, a)
        end
    end
end

function ArumTitanBoss:draw()
    ArumTitanBoss.super.draw(self) 
end

return ArumTitanBoss