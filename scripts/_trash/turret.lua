require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local guns = require "data.guns"
local images = require "data.images"
local Timer = require "scripts.timer"
local FlyingDung = require "scripts.actor.enemies.flying_dung"

local Turret = Enemy:inherit()

function Turret:init(x, y, spr, w, h)
    self:init_enemy(x,y, spr or images.spiked_fly, w or 20, h or 14)
    self.name = "woodlouse"
    self.follow_player = false

    self.life = 60
    self.speed = 0
    self.speed_x = 0

    self.is_flying = true
    self.gravity = 0
    self.speed = 100
    self.is_stompable = false
    self.self_knockback_mult = 0

    self.sin_x_value = 0
    self.sin_y_value = 0

    self.spawn_dung_timer = Timer:new(2.0)
    self.spawn_dung_timer:start()
    self.dung_limit = 6
    self.dungs = {}

    self.gun = guns.unlootable.TurretGun:new(self)
end

function Turret:update(dt)
    self:update_enemy(dt)

    if self.spawn_dung_timer:update(dt) then
        local flying_dung = FlyingDung:new(self.mid_x, self.mid_y, self)
        flying_dung:center_actor()
        game:new_actor(flying_dung)
        table.insert(self.dungs, flying_dung)

        if #self.dungs < self.dung_limit then
            self.spawn_dung_timer:start()
        end
    end
    
    for i = #self.dungs, 1, -1 do
        local dung = self.dungs[i]
        if dung.is_removed then
            table.remove(self.dungs, i)
            self.spawn_dung_timer:start()
        end
    end


    self.sin_x_value = self.sin_x_value + dt
    self.sin_y_value = self.sin_y_value + dt * 7
    self.vx = math.cos(self.sin_x_value) * self.speed
    self.vy = math.sin(self.sin_y_value) * self.speed

    self.gun:update(dt)
    
    self.target = self:get_nearest_player()
    if self.target then
        local dx, dy = get_direction_vector(self.mid_x, self.mid_y, self.target.mid_x, self.target.mid_y)
        self.gun:shoot(dt, self, self.mid_x, self.mid_y, dx, dy)
    end
end

function Turret:after_collision(col, other)
    if col.type ~= "cross" then
    end
end

return Turret
