require "scripts.util"
local Class = require "scripts.meta.class"

local Sound = Class:inherit()

function Sound:init(source, pitch, volume, is_looping)
    pitch = param(pitch, 1.0)
    volume = param(volume, 1.0)
    is_looping = param(is_looping, false)
    
    self.source = source
    self.pitch = pitch
    self.volume = volume
    self.is_looping = is_looping
end

-- function Sound:clone()
--     return Sound:new(self.source, self.pitch, self.volume, self.is_looping)
-- end

-- ---@param offset number
-- ---@param unit "seconds"|"samples"
-- function Sound:seek(offset, unit)
--     self.source:seek(offset, unit)
-- end

return Sound