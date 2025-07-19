require "scripts.util"
local Timer = require "scripts.timer"

local Class = require "scripts.meta.class"

local CutsceneScene = Class:inherit()

function CutsceneScene:init(params)
    params = params or {}

    self.description = param(params.description, "[no description]")
    self.duration = param(params.duration, 1.0)
    
    self.enter_func = param(params.enter, function(scene) end)
    self.update_func = param(params.update, function(scene, dt) end)
    self.exit_func = param(params.exit, function(scene) end)
end

function CutsceneScene:enter(...)
    self.enter_func(...)
end

function CutsceneScene:exit(...)
    self.exit_func(...)
end

function CutsceneScene:update(...)
    return self.update_func(...)
end

return CutsceneScene