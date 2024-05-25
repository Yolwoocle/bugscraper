require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Fly = require "scripts.actor.enemies.fly"
local Prop = require "scripts.actor.enemies.prop"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local sounds = require "data.sounds"
local images = require "data.images"

local ElectricRays = Prop:inherit()

function ElectricRays:init(x, y)
    self:init_prop(x,y, images.spiked_fly)
    self.name = "electric_rays"
    
    self.angle = 0
    self.angle_speed = 0.5
    self.n_rays = 3
    self.rays = {}

    self.rays_spawned = false
end

function ElectricRays:update(dt)
    self:update_prop(dt)
    if not self.rays_spawned then
        self.rays_spawned = true
        for i = 0, self.n_rays - 1 do
            local arc = ElectricArc:new(self.x, self.y)
            table.insert(self.rays, arc)
            game:new_actor(arc)
        end
    end 

    self.angle = (self.angle + self.angle_speed * dt)
    for i = 0, self.n_rays - 1 do
        local ax, ay, bx, by = get_vector_in_rect_from_angle(self.angle + i * (pi2 / self.n_rays), game.level.cabin_inner_rect)
        self.rays[i+1]:set_segment(ax, ay, bx, by)

        -- Particles:bullet_vanish(bx, by, math.atan2(by-ay, bx-ax))
    end
end

function ElectricRays:draw()
	-- self:draw_prop()
end

function ElectricRays:on_hit_electrictiy()
    self.is_electrified = true
end

function ElectricRays:pause_repeating_sounds() --scotch
    -- self.buzz_source:setVolume(0)
end
function ElectricRays:play_repeating_sounds()
    -- self.buzz_source:setVolume(1)
end

function ElectricRays:on_death()
    self.buzz_source:stop()

    Particles:spark(self.mid_x, self.mid_y, 10)
end

return ElectricRays