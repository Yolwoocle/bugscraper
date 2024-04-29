require "scripts.util"
local images = require "data.images"
local sounds = require "data.sounds"

local Enemy = require "scripts.actor.enemy"
local Guns = require "data.guns"
local Button = require "scripts.actor.enemies.button_big"
local CollisionInfo = require "scripts.physics.collision_info"

local ButtonBigGlass = Enemy:inherit()

function ButtonBigGlass:init(x, y)
    self:init_button_big_glass(x, y)
end

function ButtonBigGlass:init_button_big_glass(x, y)
    -- We can reuse this for other stuff
    -- x,y = CANVAS_WIDTH/2, game.world_generator.box_by * BLOCK_WIDTH
    -- y = game.door_by - 45
    -- x = floor(x - 58/2)
    self:init_enemy(x,y, images.big_red_button_crack3, 58, 45)
    
    self.name = "button_big_glass"
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

    self.break_state = 3
    self.loot = {}

    self.play_sfx = false

    self.spawned_button = Button
    self.images_cracked = {
        [0] = images.big_red_button_crack0,
        [1] = images.big_red_button_crack1,
        [2] = images.big_red_button_crack2,
        [3] = images.big_red_button_crack3,
    }
    self.number_of_break_states = 4

    self.damage_screenshake = 2
    self.change_break_state_screenshake = 10
    self.change_break_state_num_particles = 100
    self.break_screenshake = 15
    self.break_num_particles = 300

    self.sound_fracture = "glass_fracture"
    self.sound_break = "glass_break"
end

function ButtonBigGlass:on_buffered()
	self.x = CANVAS_WIDTH/2
	self.y = game.door_by - 45
	-- self:center_self()
end

function ButtonBigGlass:update(dt)
    self:update_enemy(dt)

    if self.life < self.activ_thresh then
        --self.spr = images.big_red_button
    end
end

function ButtonBigGlass:on_damage(n, old_life)
    local k = self.number_of_break_states
    local old_state = self.break_state
    local part = self.max_life / k
    local new_state = floor(self.life / part)

    local sndname = "impactglass_light_00"..random_str(1,4)
    local pitch = random_range(1/1.1, 1.1) - 0.5*self.life/self.max_life
    Audio:play(sndname, random_range(1-0.2, 1), pitch)
    
    if old_state ~= new_state then
        self.break_state = new_state
        local image = self.images_cracked[self.break_state] or images.big_red_button_crack3

        self.spr:set_image(image)
        game:screenshake(self.change_break_state_screenshake)
        Particles:image(self.mid_x, self.mid_y, self.change_break_state_num_particles, images.glass_shard, self.h)
        local pitch = max(0.1, lerp(0.5, 1, self.life/self.max_life))
        Audio:play(self.sound_fracture, nil, pitch)
    end

    game:screenshake(self.damage_screenshake)
end

function ButtonBigGlass:on_death()
    Audio:play(self.sound_break)
    game:screenshake(self.break_screenshake)
    Particles:image(self.mid_x, self.mid_y, self.break_num_particles, images.glass_shard, self.h)

    -- local b = create_actor_centered(self.spawned_button, CANVAS_WIDTH/2, game.world_generator.box_rby)
    local b = create_actor_centered(self.spawned_button, self.mid_x, self.mid_y)
    game:new_actor(b)
end

return ButtonBigGlass