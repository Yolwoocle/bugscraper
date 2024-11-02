require "scripts.util"
local BackgroundLayer = require "scripts.level.background.layer.background_layer"
local Sprite = require "scripts.graphics.sprite"
local images = require "data.images"

local BackgroundLayerParticles = BackgroundLayer:inherit()

function BackgroundLayerParticles:init(background, parallax, params)
    params = params or {}
    BackgroundLayerParticles.super.init(self, background, parallax)

    self.speed_range = params.speed_range or {1, 1}
    self.images = params.images or {images.empty}
    self.x_range = params.x_range or {0, CANVAS_WIDTH}
    self.amount = params.amount or 20

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

    p.x = random_range(self.x_range[1], self.x_range[2])
    p.y = random_range(-CANVAS_HEIGHT, 0)
    p.speed = random_range(self.speed_range[1], self.speed_range[2])
    p.spr = Sprite:new(random_sample(self.images), SPRITE_ANCHOR_CENTER_CENTER)

    p.despawn_condition = function(_self)
        return _self.y - _self.spr.image:getHeight() > CANVAS_HEIGHT
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