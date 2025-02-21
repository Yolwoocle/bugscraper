require "scripts.util"
local BackgroundLayer = require "scripts.level.background.layer.background_layer"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"

local BackgroundLayerParticles = BackgroundLayer:inherit()

function BackgroundLayerParticles:init(background, parallax, params)
    params = params or {}
    BackgroundLayerParticles.super.init(self, background, parallax)

    self.speed_range = params.speed_range or {1, 1}
    self.amount = params.amount or 20
    self.particles = params.particles or {}
    self.y_range = params.y_range or {-CANVAS_HEIGHT, 0}
    self.particles_data = params.particles or {}

    if self.y_range[2] < self.y_range[1] then
        self.y_range[1], self.y_range[2] = self.y_range[2], self.y_range[1]
    end

    self.particles = self:create_particles(self.amount)    
end

function BackgroundLayerParticles:create_particles(amount)
    local particles = {}

    for i=1, amount do
        table.insert(particles, self:new_particle())
    end

    return particles
end

function BackgroundLayerParticles:new_particle(p)
    p = p or {}
    
    local particle_params = random_sample(self.particles_data or {}) or {}
    local image = random_sample(particle_params.images or {images.empty})

    local x_anchor = particle_params.x_anchor or "random"
    local x_range = particle_params.x_range or {0, CANVAS_WIDTH}
    if x_range[2] < x_range[1] then
        x_range[1], x_range[2] = x_range[2], x_range[1]
    end
    local x_anchor_offset_range = particle_params.x_anchor_offset_range or {0, 0}
    local flip_if_on_right_edge = param(particle_params.flip_if_on_right_edge, x_anchor == "leftright")
    
    if x_anchor == "leftright" then
        x_anchor = random_sample{"left", "right"}
    end
    if x_anchor == "random" then
        p.x = random_range(x_range[1], x_range[2])
        
    elseif x_anchor == "left" then
        p.x = x_range[1] + image:getWidth()/2

    elseif x_anchor == "center" then
        p.x = math.floor((x_range[1] + x_range[2]) / 2)

    elseif x_anchor == "right" then
        p.x = x_range[2] - image:getWidth()/2
    end
    p.x = p.x + random_range(x_anchor_offset_range[1], x_anchor_offset_range[2])

    p.y = random_range(self.y_range[1], self.y_range[2]) - image:getHeight()
    p.speed = random_range(self.speed_range[1], self.speed_range[2])
    p.spr = Sprite:new(image, SPRITE_ANCHOR_CENTER_CENTER)
    if flip_if_on_right_edge and x_anchor == "right" then
        p.spr:set_flip_x(true)
    end

    p.despawn_condition = function(_self)
        return _self.y - _self.spr.h > CANVAS_HEIGHT
    end

    p.draw = function(_self)
        _self.spr:draw(math.floor(_self.x), math.floor(_self.y))
    end

    return p
end

function BackgroundLayerParticles:update(dt)
    BackgroundLayerParticles.super.update(self, dt)
	for _, particle in pairs(self.particles) do
        particle.y = particle.y + particle.speed * self.background:get_speed() * self.parallax * dt

        if particle:despawn_condition() then
            self:new_particle(particle)
        end
    end
end

function BackgroundLayerParticles:draw()
    BackgroundLayerParticles.super.draw(self)

    for _, particle in pairs(self.particles) do
        particle:draw()
    end
end

return BackgroundLayerParticles