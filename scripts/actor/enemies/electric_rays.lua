require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Fly = require "scripts.actor.enemies.fly"
local Prop = require "scripts.actor.enemies.prop"
local ElectricArc = require "scripts.actor.enemies.electric_arc"
local Timer = require "scripts.timer"
local sounds = require "data.sounds"
local images = require "data.images"

local ElectricRays = Prop:inherit()

function ElectricRays:init(x, y, n_rays, activation_delay)
    self:init_prop(x,y, images.empty, 32, 32)
    self.name = "electric_rays"
    
    self.max_life = 100
    self.life = self.max_life
    
    self.angle = random_range(0, math.pi*2)
    self.angle_speed = 0.5
    self.n_rays = n_rays or 1
    self.rays = {}
    
    self.counts_as_enemy = false
    self.is_immune_to_electricity = true
    self.rays_spawned = false
	-- self.destroy_bullet_on_impact = true
	-- self.is_immune_to_bullets = false

    self.activation_timer = Timer:new(activation_delay or 2)
    self.activation_timer:start()
end

function ElectricRays:update(dt)
    self:update_prop(dt)
    
    -- Spawn rays
    if not self.rays_spawned then
        self:spawn_rays()
    end 
    
    -- Enable rays after some time
    if self.activation_timer:update(dt) then
        for _, ray in pairs(self.rays) do
            ray:set_arc_active(true)
        end
    end

    self.angle = (self.angle + self.angle_speed * dt)
    for i = 0, self.n_rays - 1 do
        local ax, ay, bx, by = get_vector_in_rect_from_angle(self.angle + i * (pi2 / self.n_rays), game.level.cabin_inner_rect)
        local ray = self.rays[i+1]
        ray:set_segment(ax, ay, bx, by)

        if ray.is_arc_active then
            Particles:dust(bx, by)
            if random_range(0, 1) < 0.1 then
                Particles:spark(bx, by)
            end
        end
    end
end

function ElectricRays:spawn_rays()
    self.rays_spawned = true
    for i = 0, self.n_rays - 1 do
        local arc = ElectricArc:new(self.x, self.y)
        arc:set_arc_active(false)
        table.insert(self.rays, arc)
        game:new_actor(arc)
    end
end

function ElectricRays:draw()
	self:draw_prop()
end

function ElectricRays:on_death()
    Particles:spark(self.mid_x, self.mid_y, 10)

    for i = 1, self.n_rays do
        self.rays[i]:kill()
    end
end

return ElectricRays