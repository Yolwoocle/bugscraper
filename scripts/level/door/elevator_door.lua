require "scripts.util"
local images = require "data.images"

local Class = require "scripts.meta.class"
local sounds = require "data.sounds"

local ElevatorDoor = Class:inherit()
function ElevatorDoor:init(x, y, w, h, params)
    params = params or {}

    self.offset = 0.0
    self.offset_target = 0.0

    self.x = x
    self.y = y

    self.w = w
    self.h = h
    self.is_opened = false

    self.sound_open = "elev_door_open"
    self.sound_close = "elev_door_close"
end

function ElevatorDoor:update(dt)
    self.offset = lerp(self.offset, self.offset_target, 0.1)
end

function ElevatorDoor:open(play_sound)
    play_sound = param(play_sound, true)
    if self.is_opened then
        return
    end
    
    self.is_opened = true
    self.offset_target = 1
    if play_sound then
        Audio:play(self.sound_open)
    end
end

function ElevatorDoor:close(play_sound)
    play_sound = param(play_sound, true)
    if not self.is_opened then
        return
    end

    self.is_opened = false
    self.offset_target = 0
    if play_sound then
        Audio:play(self.sound_close)
    end
end

function ElevatorDoor:set_opened(value)
    self.is_opened = value
    self.offset_target = ternary(value, 1, 0)
    self.target = self.offset_target
end

function ElevatorDoor:draw()
end

function ElevatorDoor:draw_front()
end

return ElevatorDoor