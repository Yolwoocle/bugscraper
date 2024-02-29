require "scripts.util"
local Class = require "scripts.class"

local TimerManager = Class:inherit()

function TimerManager:init()
    self.timers = {}
end

function TimerManager:update(dt)
    for i, timer in ipairs(self.timers) do
        timer:update(dt)
    end

    for i, timer in ipairs(self.timers) do
        if timer.is_marked_for_deletion then
            table.remove(self.timers, i)
        end
    end
end

return TimerManager