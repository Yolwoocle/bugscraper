require "scripts.util"
local Class = require "scripts.meta.class"

local Timer = Class:inherit()

function Timer:init(duration)
    self.duration = duration
    self.time = duration
    -- self.on_timeout = on_timeout

    self.is_active = false
    self:reset()
end

function Timer:reset()
    self.time = 0.0
    self.is_active = false
end

function Timer:update(dt)
    if not self.is_active then
        return false
    end

    self.time = math.max(self.time - dt, 0.0)
    if self.time <= 0 then
        self:stop()
        return true
    end
    return false
end

function Timer:get_time()
    return self.time
end

function Timer:set_time(val)
    self.time = val
end

function Timer:get_duration()
    return self.duration
end

function Timer:set_duration(val)
    self.duration = val
end

function Timer:start(duration)
    if duration then
        self:set_duration(duration)
    end
    self.is_active = true
    self.time = self.duration
end

function Timer:stop()
    self.is_active = false
    self:reset()
end

return Timer