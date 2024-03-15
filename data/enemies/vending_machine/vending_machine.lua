require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local ButtonSmall = require "data.enemies.button_small"
local EffectSlowness = require "scripts.effect.effect_slowness"

local VendingMachine = ButtonSmall:inherit()

function VendingMachine:init(x, y)
    self:init_button_small(x, y, nil, 16, 61)
    self.name = "machine_coffee"

    self.sprite_pressed = images.machine_coffee_pressed
    self.products = {}
    self:set_sprite(images.machine_coffee)
end

function VendingMachine:on_press()
    for i, player in ipairs(game.players) do
	    player:apply_effect(EffectSlowness:new(), random_range(5.0, 10.0))
    end
end

return VendingMachine