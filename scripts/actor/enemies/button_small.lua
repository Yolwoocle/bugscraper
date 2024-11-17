require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local images = require "data.images"
local ButtonBig = require "scripts.actor.enemies.button_big"

local ButtonSmall = ButtonBig:inherit()

function ButtonSmall:init(x, y, spr, w, h)
    self:init_button_small(x, y, spr, w, h)
end

function ButtonSmall:init_button_small(x, y, spr, w, h)
    self:init_button_big(x, y, spr, w or 16, h or 18)

    self.name = "button_small"
    self.max_life = 40000000
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true
    self.is_killed_on_stomp = false
    self.pressed_disappear_timer = Timer:new(0.5)
    self.disappear_after_press = true

    self.sprite_pressed = images.small_button_pressed
    self.is_pressed = false

    self:set_image(images.small_button)
end

function ButtonSmall:update(dt)
    self:update_button_small(dt)
end

function ButtonSmall:update_button_small(dt)
    self:update_enemy(dt)

    if self.is_pressed then
        if self.pressed_disappear_timer:update(dt) then
            self:kill()
        end
    end
end

function ButtonSmall:on_stomp_killed(damager)
    game:screenshake(5)
    Audio:play("button_press")
    
    self:press_button()
end

function ButtonSmall:press_button()
    self.is_pressed = true
    if self.disappear_after_press then
        self.pressed_disappear_timer:start()
    end
    
    self:set_image(self.sprite_pressed)
    self:on_press()
    self.is_stompable = false
end

function ButtonSmall:on_press()
    game.can_start_game = true
end

function ButtonSmall:on_death(damager, reason)
    -- x, y, number, spr, spw_rad, life, vs, g, parms
    Particles:image(self.mid_x, self.mid_y, 15, images.button_fragments, 8, 0.5, 0.5, 10)
end

return ButtonSmall