require "scripts.util"
local images = require "data.images"
local Prop = require "scripts.actor.enemies.prop"
local guns = require "data.guns"

local utf8 = require "utf8"

local Explosion = Prop:inherit()

function Explosion:init(x, y, radius, resolution)
    self:init_prop(x, y, images.empty, 1, 1)
    self.name = "explosion"

    self.explosion_damage = 1
    self.radius = radius or 32
    self.resolution = resolution or 32

    self.do_killed_smoke = false
    self.gun = guns.unlootable.ExplosionGun:new(self, self.radius, self.explosion_damage, self.resolution)
end

function Explosion:update(dt)
    self:update_prop(dt)

    if not self.is_dead then
        self.gun:shoot(dt, self, self.mid_x, self.mid_y, math.cos(0), math.sin(0))
        for i=1, 10 do
            Particles:smoke_big(self.x, self.y, nil, self.radius)
        end
        self:kill()      
    end
end

function Explosion:draw()
    -- self:draw_prop()
end

return Explosion