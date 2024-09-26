require "scripts.util"
local Timer = require "scripts.timer"

local Class = require "scripts.meta.class"

local Scene = Class:inherit()

function Scene:init(params)
    params = params or {}

    self.duration = param(params.duration, 1.0)
    
    self.enter_func = param(params.enter, function(scene) end)
    self.update_func = param(params.update, function(scene, dt) end)
    self.exit_func = param(params.exit, function(scene) end)
end

function Scene:enter()
    self:enter_func()
end

function Scene:exit()
    self:exit_func()
end

function Scene:update(dt)
    self:update_func(dt)
end

return Scene