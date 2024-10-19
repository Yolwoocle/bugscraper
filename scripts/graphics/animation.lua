require "scripts.util"
local Class = require "scripts.meta.class"
local Timer = require "scripts.timer"
local images = require "data.images"

local Animation = Class:inherit()

function Animation:init(frames, frame_duration)
    frames = frames or {}
    frame_duration = frame_duration or 0.1

    self.frames = frames
    self.frame_duration = frame_duration
end

return Animation