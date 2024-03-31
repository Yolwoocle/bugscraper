require "scripts.util"
local Larva = require "data.enemies.larva"
local HoneypotLiquid = require "data.enemies.honeypot_liquid"
local sounds = require "data.sounds"
local images = require "data.images"

local HoneypotAnt = Larva:inherit()
	
function HoneypotAnt:init(x, y)
    self:init_larva(x,y, images.honeypot_ant1, 12, 16)
    self.name = "honeypot_ant"

    self.gravity_mult = -1
    self.spr_oy = 8

    self.anim_frame_len = 0.4
    self.anim_frames = {images.honeypot_ant1, images.honeypot_ant2}
end

function HoneypotAnt:update(dt)
    self:update_larva(dt)
end

function HoneypotAnt:on_death()
    Particles:image(self.mid_x, self.mid_y, 30, images.snail_shell_fragment, 13, nil, 0, 10)
    local liquid = HoneypotLiquid:new(self.x, self.y)
    liquid.vy = 0
    game:new_actor(liquid)
end

return HoneypotAnt
