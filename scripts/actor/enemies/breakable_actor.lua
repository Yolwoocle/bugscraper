require "scripts.util"
local images = require "data.images"
local Enemy = require "scripts.actor.enemy"
local CollisionInfo = require "scripts.physics.collision_info"

local BreakableActor = Enemy:inherit()

function BreakableActor:init(x, y, img, w, h)
    BreakableActor.super.init(self, x,y, img or images.empty, w or 16, h or 16)
    
    self.name = "breakable_actor"
    self.follow_player = false

    self.max_life = 80
    self.life = self.max_life
    self.activ_thresh = 40
    self.break_range = self.life - self.activ_thresh
    self.knockback = 0

    self.collision_info = CollisionInfo:new {
        type = COLLISION_TYPE_SOLID,
        is_slidable = true,
    }
    self.is_stompable = false
    self.is_pushable = false
    self.is_knockbackable = false

    self.damage = 0
    self.screenshake = 0
    self.max_screenshake = 4

    self.break_state = math.huge
    self.loot = {}

    self.play_sfx = false

    self.images_cracked = {}

    self.damage_screenshake = 2
    self.change_break_state_screenshake = 10
    self.change_break_state_num_particles = 100
    self.break_screenshake = 15
    self.break_num_particles = 300

    self.change_break_state_particle_image = images.glass_shard
    self.break_particle_image = images.glass_shard

    self.sound_fracture = {"glass_fracture"}
    self.sound_break = {"glass_break"}
    self.sounds_impact = "sfx_impactglass_light_{001-005}"
    self.volume_fracture = 1
    -- self.pitch_fracture = 0.5
    self.volume_break = 1
    -- self.pitch_break = 0.5
end


function BreakableActor:update(dt)
    self:update_enemy(dt)

    local image = self.images_cracked[self.break_state+1] or images.big_red_button_crack3
    self.spr:set_image(image)
end

function BreakableActor:ready()
    self.break_state = math.min(self.break_state, #self.images_cracked -1)
end

function BreakableActor:on_damage(amount)
    local number_of_break_states = #self.images_cracked
    local old_state = self.break_state
    local part = self.max_life / number_of_break_states
    local new_state = floor(self.life / part)

    local pitch = random_range(1/1.1, 1.1) - 0.5*self.life/self.max_life
    self:play_sound(self.sounds_impact, 1, pitch)
    
    if old_state ~= new_state then
        self.break_state = new_state
        
        game:screenshake(self.change_break_state_screenshake)
        Particles:image(self.mid_x, self.mid_y, self.change_break_state_num_particles, self.change_break_state_particle_image, self.h)
        self:play_sound_var(self.sound_fracture, 0.1, 1.1)
    end

    game:screenshake(self.damage_screenshake)
end

function BreakableActor:on_death()
    self:play_sound(self.sound_break, self.volume_break)
    game:screenshake(self.break_screenshake)

    local vol = (self.w/16) * (self.h/16)
    for ix = 0, self.w, 16 do
        for iy = 0, self.h, 16 do
            Particles:image(self.x + ix, self.y + iy, math.floor(self.break_num_particles/vol), self.break_particle_image, 16, 16)
        end
    end
end

return BreakableActor