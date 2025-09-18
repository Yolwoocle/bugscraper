require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local Timer = require "scripts.timer"
local images = require "data.images"
local ButtonBig = require "scripts.actor.enemies.button_big"

local ButtonSmallRocket = ButtonBig:inherit()

function ButtonSmallRocket:init(x, y, spr, w, h)
    self:init_button_small(x, y, spr, w, h)
end

function ButtonSmallRocket:init_button_small(x, y, spr, w, h)
    self:init_button_big(x, y, spr, w or 16, h or 18)

    self.name = "button_small"
    self.max_life = 40000000
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true
    self.is_killed_on_stomp = false
    self.pressed_disappear_timer = Timer:new(0.5)
    self.disappear_after_press = true

    self.sprite_pressed = images.small_button_pressed
    self.sprite_unpressed = images.small_button
    self.is_pressed = false

    self:set_image(images.small_button)
end

function ButtonSmallRocket:update(dt)
    self:update_button_small(dt)
end

function ButtonSmallRocket:update_button_small(dt)
    self:update_enemy(dt)

    if self.is_pressed then
        if self.pressed_disappear_timer:update(dt) then
            self:kill()
        end
    end
end

function ButtonSmallRocket:on_stomp_killed(damager)
    game:screenshake(5)
    Audio:play("sfx_actor_button_small_pressed")
    
    self:press_button(damager)
end

function ButtonSmallRocket:press_button(presser)
    self:set_pressed(true)
    if self.disappear_after_press then
        self.pressed_disappear_timer:start()
    end
    
    self:on_press(presser)
end

function ButtonSmallRocket:set_pressed(value)
    self:set_image(ternary(value, self.sprite_pressed, self.sprite_unpressed))
    self.is_pressed = value
    self.is_stompable = not value
end

function ButtonSmallRocket:on_press(presser)
    print_debug("LIGHTS ON")
    game:play_cutscene("basement_light_on")
    if game.level.backroom then
        game.level.backroom.tutorial_timer = 10.0
    end
end

function ButtonSmallRocket:on_death(damager, reason)
    -- x, y, number, spr, spw_rad, life, vs, g, parms
    Particles:image(self.mid_x, self.mid_y, 15, images.button_fragments, 8, 0.5, 0.5, 10)
end

return ButtonSmallRocket