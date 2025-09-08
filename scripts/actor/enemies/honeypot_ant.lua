require "scripts.util"
local Larva = require "scripts.actor.enemies.larva"
local HoneypotLiquid = require "scripts.actor.enemies.honeypot_liquid"
local sounds = require "data.sounds"
local images = require "data.images"

local HoneypotAnt = Larva:inherit()
	
function HoneypotAnt:init(x, y)
    self:init_larva(x,y, images.honeypot_ant1, 12, 16)
    self.name = "honeypot_ant"

    self.gravity_mult = -1
    self.spr:update_offset(nil, 8)

    self.anim_frame_len = 0.4
    self.anim_frames = {images.honeypot_ant1, images.honeypot_ant2}
    
    self.fury_damage_multiplier = 2.0
    self.score = 10

    self.sound_death = "sfx_enemy_kill_general_gore_{01-10}"
    self.sound_stomp = "sfx_enemy_kill_general_gore_{01-10}"
end

function HoneypotAnt:update(dt)
    self:update_larva(dt)
end

function HoneypotAnt:on_death()
    local liquid = HoneypotLiquid:new(self.x, self.y)
    liquid.vy = 0
    game:new_actor(liquid)
end

return HoneypotAnt
