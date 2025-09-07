require "scripts.util"
local shaders = require "data.shaders"
local Light = require "scripts.graphics.light.light_spotlight"
local Rect = require "scripts.math.rect"

local Layer = require "scripts.graphics.layer"

local LightWorld = Layer:inherit()

function LightWorld:init()
    self.bounds = Rect:new(-6000, -16, 6000, 15*16 + 3)
    self.darkness_intensity = 0.8
    self.custom_fill_color = nil
    self.lights = {}
end

function LightWorld:reset_lights()
    self.lights = {}
end

function LightWorld:new_light(name, light)
    self.lights[name] = light
end

function LightWorld:update(dt)
    for _, light in pairs(self.lights) do
        light:update(dt)
    end
end

function LightWorld:paint(x, y)
    for _, light in pairs(self.lights) do
        if light.is_active then
            light:draw(self.bounds)
        end
    end
end

return LightWorld