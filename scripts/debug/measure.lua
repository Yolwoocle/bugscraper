local Class = require "scripts.meta.class"

local Measure = Class:inherit()

function Measure:init(max_iterations) 
    self.active = true
    
    self.max_iterations = max_iterations
    self.iterations = 0
    self.acc_time = 0.0
end

function Measure:tick(func, repeat_times)
    repeat_times = repeat_times or 1
    if not self.active then
        func()
        return
    end

    for i=1, repeat_times do
        local tick = love.timer.getTime()
        func()
        local time = love.timer.getTime() - tick

        self.acc_time = self.acc_time + time/self.max_iterations
        self.iterations = self.iterations + 1
        
        if self.iterations >= self.max_iterations then
            self.active = false
            
            return self.acc_time / self.max_iterations
        end
    end
end 

return Measure