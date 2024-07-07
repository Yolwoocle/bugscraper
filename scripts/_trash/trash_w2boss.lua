require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local ElectricRays = require "scripts.actor.enemies.electric_rays"
local Timer = require "scripts.timer"
local guns  = require "data.guns"

local W2boss = Enemy:inherit()

function W2boss:init(x, y)
    self:init_enemy(x,y, images.dummy_target, 15, 26)
    self.name = "todo_changeme"

    self.life = 300

    self.rays = ElectricRays:new(self.mid_x, self.mid_y, 8)
    self.rays.angle_speed = 0
    game:new_actor(self.rays)

    self.rays_disabled_timer = Timer:new(1.5)
    self.rays_telegraph_duration = 1.5
    self.rays_activated_timer = Timer:new(3)
    self.rays_activated_timer:start()
    self.rays:start_activation_timer(self.rays_telegraph_duration)

    self.gun = guns.unlootable.MushroomAntGun:new()
    self.shoot_timer = Timer:new(0.2)
    self.shoot_timer:start()

    self.is_stompable = false
    self.self_knockback_mult = 0

    self.follow_player = false 
end

function W2boss:update(dt)
    self:update_enemy(dt)

    self.gun:update(dt)
    if self.shoot_timer:update(dt) then
        local a = random_range(0, pi*2)
        self.gun:shoot(dt, self, self.mid_x, self.mid_y, math.cos(a), math.sin(a))
        self.shoot_timer:start()
    end

    if self.rays_activated_timer:update(dt) then
        self.rays:set_state("disabled")
        self.rays_disabled_timer:start()
    end
    if self.rays_disabled_timer:update(dt) then
        self.rays:start_activation_timer(self.rays_telegraph_duration)
        self.rays.angle = random_range(0, pi*2)
        self.rays_activated_timer:start()
    end
end

function W2boss:on_death(dt)
    self.rays:kill()
end

return W2boss