require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local ButtonBigPressed = require "data.enemies.button_big_pressed"

local ButtonSmallPressed = ButtonBigPressed:inherit()

function ButtonSmallPressed:init(x, y)
    self:init_button_big_pressed(x, y)
    self.name = "button_small_pressed"

    self.pressed_disappear_timer = 0.5

    self:set_sprite(images.small_button_pressed)
end

function ButtonSmallPressed:update(dt)
    self:update_enemy(dt)

    self.pressed_disappear_timer = self.pressed_disappear_timer - dt
    if self.pressed_disappear_timer <= 0 then
        game:kill_all_enemies()
    end
end

function ButtonSmallPressed:on_death(damager, reason)
    -- x, y, number, spr, spw_rad, life, vs, g, parms
    Particles:image(self.mid_x, self.mid_y, 15, images.button_fragments, 8, 0.5, 0.5, 10)
end

return ButtonSmallPressed