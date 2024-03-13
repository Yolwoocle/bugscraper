require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local ButtonBig = require "data.enemies.button_big"

local ButtonSmallPressed = require "data.enemies.button_small_pressed"

local ButtonSmall = ButtonBig:inherit()

function ButtonSmall:init(x, y)
    self:init_button_big(x, y)

    self.name = "button_small"
    self.max_life = 40000000
	self.destroy_bullet_on_impact = false
	self.is_immune_to_bullets = true

    self.spawned_button_pressed = ButtonSmallPressed
    self:set_sprite(images.small_button)
end

function ButtonSmall:on_stomped(damager)
    game:screenshake(5)
    Audio:play("button_press")
    
    -- TODO: smoke particles
    -- local b = ButtonPressed:new(CANVAS_WIDTH/2, game.world_generator.box_rby)
    local b = ButtonSmallPressed:new(self.x, self.y)
    game:new_actor(b)
end

return ButtonSmall