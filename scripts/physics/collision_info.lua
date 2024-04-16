require "scripts.util"
local Class = require "scripts.meta.class"

local CollisionInfo = Class:inherit()

function CollisionInfo:init(params)
    self.type =        param(params.type, COLLISION_TYPE_SOLID)
    self.is_slidable = param(params.is_slidable, true)
end

return CollisionInfo