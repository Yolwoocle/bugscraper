require "scripts.util"
local Class = require "scripts.meta.class"
local Timer = require "scripts.timer"
local images = require "data.images"

local Animation = Class:inherit()

function Animation:init(frames, frame_duration, frame_count_x, frame_count_y, params)
    params = params or {} 
    frames = frames or {}
    frame_duration = frame_duration or 0.1
    frame_count_x = frame_count_x or 1
    frame_count_y = frame_count_y or 1

    self.frames = frames
    self.frame_duration = frame_duration
    if type(frames) == "table" then
        self.frame_count_x = (#self.frames or frame_count_x) or 1
        self.frame_count_y = 1
        self.is_spritesheet = false
    else
        self.frame_count_x = frame_count_x or 1
        self.frame_count_y = frame_count_y or 1
        self.is_spritesheet = true
    end

    self.frame_count = self.frame_count_x * self.frame_count_y
    self.duration = self.frame_count * self.frame_duration
    
    self.looping = param(params.looping, true) 
end

return Animation