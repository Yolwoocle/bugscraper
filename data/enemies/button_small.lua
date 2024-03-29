require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local ButtonBig = require "data.enemies.button_big"

local ButtonSmall = ButtonBig:inherit()

function ButtonSmall:init(x, y, spr, w, h)
    self:init_button_small(x, y, spr, w, h)
end

function ButtonSmall:init_button_small(x, y, spr, w, h)
    self:init_button_big(x, y, spr, 16, 18)

    self.name = "button_small"
    self.max_life = 40000000
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true
    self.is_killed_on_stomp = false
    self.pressed_disappear_timer = 0.5

    self.sprite_pressed = images.small_button_pressed
    self.is_pressed = false

    self:set_sprite(images.small_button)
end

function ButtonSmall:update(dt)
    self:update_button_small(dt)
end

function ButtonSmall:update_button_small(dt)
    self:update_enemy(dt)

    if self.is_pressed then
        self.pressed_disappear_timer = self.pressed_disappear_timer - dt
        if self.pressed_disappear_timer <= 0 then
            game:kill_all_enemies()
        end
    end
end

function ButtonSmall:on_stomped(damager)
    game:screenshake(5)
    Audio:play("button_press")
    
    self:press_button()
end

function ButtonSmall:press_button()
    self.is_pressed = true
    
    self:set_sprite(self.sprite_pressed)
    self:on_press()
    self.is_stompable = false
end

function ButtonSmall:on_press()
    game:start_game()
    self.pressed_disappear_timer = 0.5
end

function ButtonSmall:on_death(damager, reason)
    -- x, y, number, spr, spw_rad, life, vs, g, parms
    Particles:image(self.mid_x, self.mid_y, 15, images.button_fragments, 8, 0.5, 0.5, 10)
end

return ButtonSmall