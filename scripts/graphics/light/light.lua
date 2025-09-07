require "scripts.util"
local Class = require "scripts.meta.class"
local vec2 = require "lib.batteries.vec2"
local Segment = require "scripts.math.segment"

local Light = Class:inherit()

function Light:init(x, y, params)
    params = params or {}

    self.position = vec2(x, y)
    self.is_active = param(params.is_active, true)
end

function Light:update(dt)
end

function Light:set_active(value)
    self.is_active = value
end

function Light:draw(bounds)
end

return Light