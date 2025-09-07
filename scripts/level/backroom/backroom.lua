require "scripts.util"
local Class = require "scripts.meta.class"

local Backroom = Class:inherit()

function Backroom:init(params)
    params = params or {}
    self.name = "backroom"
    
    self.background = nil
    self.freeze_fury = true
end

--- (Abstract) Generate the map for this backroom.
function Backroom:generate(world_generator)

end

--- (Abstract) Returns whether the backroom should be exited.
function Backroom:can_exit()
    return false
end

--- (Abstract) Called when the backroom is entered
function Backroom:on_enter()
end

--- (Abstract) Called when the backroom is fully entered (the circle transition is finished and 
--- the backroom takes up the whole screen)
function Backroom:on_fully_entered()
end

function Backroom:on_exit()
end

function Backroom:update(dt)

end

function Backroom:draw()

end

function Backroom:draw_front()
end

return Backroom