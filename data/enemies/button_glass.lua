require "scripts.util"
local Enemy = require "scripts.enemy"
local sounds = require "data.sounds"
local images = require "data.images"
local Guns = require "data.guns"
local Button = require "data.enemies.button"

local ButtonGlass = Enemy:inherit()

function ButtonGlass:init(x, y)
    -- We can reuse this for other stuff
    x,y = CANVAS_WIDTH/2, game.world_generator.box_by * BLOCK_WIDTH 
    y = game.door_by - 45
    x = floor(x - 58/2)
    -- y = floor(y - 45/2)
    self:init_enemy(x,y, images.big_red_button_crack3, 58, 45)
    self.name = "button_glass"
    self.follow_player = false

    self.max_life = 80
    self.life = self.max_life
    self.activ_thresh = 40
    self.break_range = self.life - self.activ_thresh
    self.knockback = 0

    self.is_solid = true
    self.is_stompable = false
    self.is_pushable = false
    self.is_knockbackable = false

    self.damage = 0
    self.screenshake = 0
    self.max_screenshake = 4

    self.break_state = 3
    self.loot = {}

    self.play_sfx = false
end

function ButtonGlass:update(dt)
    self:update_enemy(dt)

    if self.life < self.activ_thresh then
        --self.spr = images.big_red_button
    end
end

function ButtonGlass:on_damage(n, old_life)
    local k = 4
    local old_state = self.break_state
    local part = self.max_life / k
    local new_state = floor(self.life / part)

    local sndname = "impactglass_light_00"..random_str(1,4)
    local pitch = random_range(1/1.1, 1.1) - .5*self.life/self.max_life
    Audio:play(sndname, random_range(1-0.2, 1), pitch)
    
    if old_state ~= new_state then
        self.break_state = new_state
        local spr = images["big_red_button_crack"..tostring(self.break_state)]
        spr = spr or images.big_red_button_crack3

        self.spr = spr
        game:screenshake(10)
        Particles:image(self.mid_x, self.mid_y, 100, images.ptc_glass_shard, self.h)
        local pitch = max(0.1, lerp(0.5, 1, self.life/self.max_life))
        Audio:play("glass_fracture", nil, pitch)
    end

    if game.screenshake_q < 5 then
        game:screenshake(2)
    end
end

function ButtonGlass:on_death()
    Audio:play("glass_break")
    game:screenshake(15)
    Particles:image(self.mid_x, self.mid_y, 300, images.ptc_glass_shard, self.h)

    local b = create_actor_centered(Button, CANVAS_WIDTH/2, game.world_generator.box_rby)
    game:new_actor(b)
end

return ButtonGlass