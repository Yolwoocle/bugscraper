require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"

local ButtonPressed = require "scripts.actor.enemies.button_big_pressed"

local ButtonBig = Enemy:inherit()

function ButtonBig:init(x, y, spr, w, h)
    self:init_button_big(x, y, spr, w, h)
end

function ButtonBig:init_button_big(x, y, spr, w, h)
    self:init_enemy(x,y, spr or images.big_red_button, w or 34, h or 40)
    self.name = "button_big"
    self.follow_player = false

    self.max_life = 40
    self.life = self.max_life
    
    self.knockback = 0
    self.is_stompable = true
    self.do_stomp_animation = false
    self.is_pushable = false
    self.is_knockbackable = false
    self.play_sfx = false
    self.can_be_stomped_if_on_head = false
    self.loot = {}

    self.damage = 0

    self.spawned_button_pressed = ButtonPressed
end

function ButtonBig:update(dt)
    self:update_enemy(dt)
end

function ButtonBig:draw()
    self:draw_enemy()
end

function ButtonBig:on_stomp_killed(damager)
    game:screenshake(10)
    -- game:on_red_button_pressed()
    Audio:play("button_press")
    
    -- TODO: smoke particles
    -- local b = ButtonPressed:new(CANVAS_WIDTH/2, game.world_generator.box_rby)
    local b = self.spawned_button_pressed:new(self.x, self.y)
    game:new_actor(b)
end

function ButtonBig:on_death(damager, reason)
    if reason ~= "stomped" then
        game:screenshake(15)
        Audio:play("glass_fracture", 0.7, 0.2)
        game:enable_endless_mode()
        -- particles:image(self.mid_x, self.mid_y, 100, images.glass_shard, self.h)
        Particles:image(self.mid_x, self.mid_y, 300, images.button_fragments, self.h, 6, 0.05, 0)
        Particles:word(self.mid_x, self.mid_y, "ENDLESS MODE!")
    end
end

return ButtonBig