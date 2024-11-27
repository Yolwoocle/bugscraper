require "scripts.util"
local Class = require "scripts.meta.class"
local Timer = require "scripts.timer"
local images = require "data.images"

local Animation = Class:inherit()

function Animation:init(frames, frame_duration, frame_count, params)
    params = params or {} 
    frames = frames or {}
    frame_duration = frame_duration or 0.1

    self.frames = frames
    self.frame_duration = frame_duration
    if type(frames) == "table" then
        self.frame_count = (#self.frames or frame_count) or 1
        self.is_spritesheet = false
    else
        self.frame_count = frame_count or 1
        self.is_spritesheet = true
    end

end

return Animation