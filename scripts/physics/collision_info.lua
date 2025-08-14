require "scripts.util"
local Class = require "scripts.meta.class"

local CollisionInfo = Class:inherit()

function CollisionInfo:init(params)
    self.type =        param(params.type, COLLISION_TYPE_SOLID)
    self.enabled =     param(params.enabled, true)
    self.is_slidable = param(params.is_slidable, true)
    self.affected_by_solid = param(params.affected_by_solid, false)

    self.walk_sound = param(params.walk_sound, nil)
    self.slide_sound = param(params.slide_sound, nil)
    self.land_sound = param(params.land_sound, nil)
end

return CollisionInfo