require "scripts.util"
local Class = require "scripts.class"

local Timer = Class:inherit()

function Timer:init(duration, on_timeout)
    self.duration = duration
    self.time = duration
    self.on_timeout = on_timeout

    self.is_marked_for_deletion = false
end

function Timer:update(dt)
    if self.is_marked_for_deletion then
        return
    end

    self.time = self.time - dt
    if self.time <= 0 then
        self.on_timeout()
        self.is_marked_for_deletion = true
    end
end

return Timer