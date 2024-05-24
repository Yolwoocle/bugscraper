require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Fly = require "scripts.actor.enemies.fly"
local sounds = require "data.sounds"
local images = require "data.images"

local MetalFly = Fly:inherit()
	
local PHASE_CHASE = "chase"
local PHASE_TELEGRAPH = "telegraph"
local PHASE_ATTACK = "attack"

local PHASE_TELEGRAPH_DURATION = 0.4

function MetalFly:init(x, y)
    self:init_fly(x,y, images.mosquito1)
    self.name = "metal_fly"
    self.life = 5

    self.anim_frame_len = 0.05
    self.anim_frames = {images.mosquito1, images.mosquito2}

    self.buzz_source = sounds.fly_buzz.source:clone()
    self.buzz_source:setPitch(1.5)

    self.is_immune_to_electricity = true
    self.is_electrified = false
end

function MetalFly:update(dt)
    self:update_fly(dt)

    self.spr.color = ternary(self.is_electrified, COL_LIGHT_YELLOW, COL_WHITE)
    self.is_stompable = not self.is_electrified
end

function MetalFly:draw()
	self:draw_enemy()
    
    -- love.graphics.print(concat(self.phase), self.x, self.y-16)
    -- love.graphics.print(concat(self.attack_target == nil), self.x, self.y-32)
end

function MetalFly:on_hit_electrictiy()
    self.is_electrified = true
end

function MetalFly:pause_repeating_sounds() --scotch
    self.buzz_source:setVolume(0)
end
function MetalFly:play_repeating_sounds()
    self.buzz_source:setVolume(1)
end

function MetalFly:on_death()
    self.buzz_source:stop()
end

return MetalFly