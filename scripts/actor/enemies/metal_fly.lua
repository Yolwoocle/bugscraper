require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Fly = require "scripts.actor.enemies.fly"
local Lightning = require "scripts.graphics.lightning"
local Segment = require "scripts.math.segment"
local sounds = require "data.sounds"
local images = require "data.images"

local MetalFly = Fly:inherit()
	
local PHASE_CHASE = "chase"
local PHASE_TELEGRAPH = "telegraph"
local PHASE_ATTACK = "attack"

local PHASE_TELEGRAPH_DURATION = 0.4

function MetalFly:init(x, y)
    self:init_fly(x,y, images.metal_mosquito_1, 14, 14)
    self.name = "metal_fly"
    self.life = 10

    self.anim_frame_len = 0.05
    self.anim_frames = {images.metal_mosquito_1, images.metal_mosquito_2}

    self.is_immune_to_electricity = true
    self.is_electrified = false

    self.lightning_radius = 8
    self.lightning = Lightning:new({
        min_step_size = 0.4,
        max_step_size = 0.8,
        jitter_width = 5,
        coordinate_mode = LIGHNING_COORDINATE_MODE_POLAR,
    })

    self.electrified_flash = random_range(0, 1)
    self.score = 10
end

function MetalFly:update(dt)
    self:update_fly(dt)

    self.electrified_flash = (self.electrified_flash + dt) % 0.5
    self.is_stompable = not self.is_electrified

    if self.is_electrified then
        self.lightning_radius = random_range(10, 14)
        self.lightning:generate(Segment:new(self.lightning_radius, 0, self.lightning_radius, pi2))
        
        if random_range(0, 1) < 0.05 then
            Particles:spark(self.mid_x, self.mid_y)
        end

        self.spr.color = ternary(self.electrified_flash % 0.5 < 0.25, COL_LIGHT_YELLOW, COL_WHITE)
    end
end

function MetalFly:draw()
	self:draw_enemy()

    if self.is_electrified then
        self.lightning:draw(self.mid_x, self.mid_y-2)
    end
    
    -- love.graphics.print(concat(self.phase), self.x, self.y-16)
    -- love.graphics.print(concat(self.attack_target == nil), self.x, self.y-32)
end

function MetalFly:on_hit_electrictiy()
    self.is_electrified = true
end

return MetalFly