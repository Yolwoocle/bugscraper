require "scripts.util"
local Class = require "scripts.meta.class"

local Timer = Class:inherit()

function Timer:init(duration, params)
    params = params or {}
    
    self:set_duration(duration)
    self.time = duration
    self.loopback = param(params.loopback, false)
    self:apply_args(params)

    self.is_active = false
    self:reset()
end

function Timer:apply_args(args)
    args = args or {}
    
    self.on_apply = args.on_apply
    self.on_timeout = args.on_timeout
end

function Timer:reset()
    self.time = 0.0
    self.is_active = false
end

function Timer:update(dt)
    if not self.is_active then
        return false
    end

    self.time = self.time - dt
    if self.time <= 0 then
        if self.on_timeout then
            self:on_timeout()
        end
        if self.loopback then
            self.time = self.time + self.duration
        else
            self:stop()
        end
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

function Timer:set_duration(duration) 
    if type(duration) == "table" and #duration >= 2 then
        self.duration_range = duration
    else
        self.duration = duration
    end
end

function Timer:start(duration, args)
    if duration then
        self:set_duration(duration)
    end
    if self.duration_range then
        self.duration = random_range(self.duration_range[1], self.duration_range[2])
    end
    self:apply_args(args)
    
    self.is_active = true
    self.time = self.duration
    if self.on_apply then
        self:on_apply()
    end
    return self
end

function Timer:stop()
    self.time = 0
    self.is_active = false
    self:reset()
end

return Timer