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
local BigChipper360 = require "scripts.actor.enemies.big_chipper_360"
local MotherboardButton = require "scripts.actor.enemies.motherboard_button"
local FlyingDung       = require "scripts.actor.enemies.flying_dung"
local MetalFly        = require "scripts.actor.enemies.metal_fly"

local Motherboard = Enemy:inherit()

function Motherboard:init(x, y)
    self:init_enemy(x,y, images.big_ceiling_guy, 24*16, 4)
    self.name = "todo_changeme"  --removeme(dont actually)

    -- Parameters 
    self.follow_player = false
    self.life = 400
    self.self_knockback_mult = 0
    self.is_pushable = false
    self.is_stompable = false
    self.gravity = 0

    self.is_affected_by_bounds = false

    self.rays = ElectricRays:new(self.mid_x, self.y + self.h + 16, {
        angle_speed = 0.2,
        n_rays = 7,
        spawn_state = "disabled",
    })
    game:new_actor(self.rays)

    self.state_timer = Timer:new(0)
    self.ray_timer = Timer:new(1.0)
    self.spawn_timer = Timer:new({0.5, 1.5})
    self.new_button_timer = Timer:new(1.5)
    self.max_chippers = 6
    self.dung_damage = 20
    self.burst_gun = guns.unlootable.W2BossBurst:new(self)
    self.turret_gun = guns.unlootable.W2BossTurretGun:new(self)
    self.enemy_mix = {
        {Chipper, 2},
        {MetalFly, 1},
        {FlyingDung, 2},
    }
    self.state_machine = StateMachine:new({
        rays = {
            enter = function(state)
                self.wave_enemies = {}
                self:set_bouncy()

                self.ray_timer:start()
                self.spawn_timer:start()

                -- self.ray_cycles_left = 7
                self.ray_cycles_left = 3 --changeme
                
                self:set_bouncy(true)
            end,
            exit = function(state)
                self.rays:set_state("disabled")

                for i = 1, #self.wave_enemies do
                    self.wave_enemies[i]:kill()
                end
            end,
            update = function(state, dt)
                local cabin_rect = game.level.cabin_inner_rect

                -- Update rays
                if self.ray_timer:update(dt) then
                    self.rays:set_state(({
                        disabled = "telegraph",
                        telegraph = "active",
                        active = "disabled",
                    })[self.rays.state])
                    self.ray_timer:start(1.0)

                    if self.rays.state == "disabled" then
                        self.ray_cycles_left = self.ray_cycles_left - 1
                        if self.ray_cycles_left <= 0 then
                            self.state_machine:set_state("charging")
                        end
                    end
                end

                -- Spawn enemies
                if self.spawn_timer:update(dt) then
                    if #self.wave_enemies < self.max_chippers then
                        local x0 = random_range(cabin_rect.ax + 16, cabin_rect.bx - 16)
                        local y0 = self.y + self.h + 16
                        local enemy_class = random_weighted(self.enemy_mix) 

                        local enemy 
                        if enemy_class == FlyingDung then
                            enemy = enemy_class:new(x0, y0, self)
                        else
                            enemy = enemy_class:new(x0, y0)
                        end
                        game:new_actor(enemy)

                        table.insert(self.wave_enemies, enemy)
                    end

                    self.spawn_timer:start()
                end

                -- Remove dead enemies
                for i = #self.wave_enemies, 1, -1 do
                    if self.wave_enemies[i].is_dead then
                        table.remove(self.wave_enemies, i)
                    end
                end
            end,
        },
        charging = {
            enter = function(state)
                self.wave_enemies = {}
                for i=1, 1 do
                    local chipper = BigChipper360:new(self.mid_x, self.y + self.h + 16)
                    game:new_actor(chipper)
                    table.insert(self.wave_enemies, chipper)
                end

                -- self.state_timer:start(20.0)
                self.state_timer:start(8.0)
                self.button_side = random_neighbor(1)
                
                self:set_bouncy(true)
                self:spawn_button()
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self.state_machine:set_state("bullets")
                end

                if self.new_button_timer:update(dt) then
                    self:spawn_button()
                end
            end,
            exit = function(state)
                for _, e in pairs(self.wave_enemies) do
                    if not e.is_dead then
                        e:kill()
                    end
                end
            end
        },
        bullets = {
            enter = function(state)
                -- self.state_timer:start(15.0)
                self.state_timer:start(5.0)
                self.gun_target = self:get_random_player()

                self:set_bouncy(false)
            end,
            update = function(state, dt)
                if self.state_timer:update(dt) then
                    self.state_machine:set_state("rays")
                end

                self.turret_gun:update(dt)
                self.burst_gun:update(dt)
                
                if self.gun_target then
                    local dx, dy = get_direction_vector(self.mid_x, self.mid_y, self.gun_target.mid_x, self.gun_target.mid_y)
                    self.turret_gun:shoot(dt, self, self.mid_x, self.mid_y + 8, dx, dy)
                end

                if not self.burst_gun.is_reloading and self.burst_gun.ammo == self.burst_gun.max_ammo then
                    local a = random_range(0, pi)
                    self.burst_dirx, self.burst_diry = math.cos(a), math.sin(a)
                end
                if self.burst_dirx then
                    self.burst_gun:shoot(dt, self, self.mid_x, self.mid_y + 8, self.burst_dirx, self.burst_diry)
                end
            end,
        } 
    }, "charging")
end

function Motherboard:on_hit_flying_dung(dung)
    self:do_damage(self.dung_damage)
end

function Motherboard:update(dt)
    self:update_enemy(dt)

    self.state_machine:update(dt)
end

function Motherboard:on_motherboard_button_pressed(button)
    self.button_side = random_neighbor(1)
    self.new_button_timer:start()
end

function Motherboard:spawn_button()
    local button = MotherboardButton:new(self.mid_x + self.button_side * 8*BW, self.y + self.h, self)
    game:new_actor(button)
    table.insert(self.wave_enemies, button)
end

function Motherboard:draw()
    self:draw_enemy()

    print_centered_outline(nil, nil, concat(self.life, "❤"), self.mid_x, self.y + self.h + 16)
end

return Motherboard