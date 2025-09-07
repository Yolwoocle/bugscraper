require "scripts.util"
local Light = require "scripts.graphics.light.light"
local vec2 = require "lib.batteries.vec2"
local shaders = require "data.shaders"

local LightPoint = Light:inherit()

function LightPoint:init(x, y, params)
    LightPoint.super.init(self, x, y, params)
    params = params or {}

    self.position = vec2(x, y)
    self.radius = param(params.radius, 64)
    self.attenuation = param(params.attenuation, 8)

    self.target = param(params.target, nil)
end

function LightPoint:update(dt)
    if self.target then
        self.position:scalar_set(self.target.mid_x or self.target.x, self.target.mid_y or self.target.y)    
    end
end

function LightPoint:draw(bounds)
    if not self.is_active then
        return
    end

    love.graphics.circle("fill", self.position.x, self.position.y, self.radius)
end

return LightPoint