require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"
local ButtonSmall = require "data.enemies.button_small"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeCoffee = require "scripts.upgrade.upgrade_coffee"

local VendingMachine = ButtonSmall:inherit()

function VendingMachine:init(x, y)
    self:init_button_small(x, y, nil, 25, 61)
    self.name = "vending_machine"

    self.sprite_pressed = images.machine_coffee_pressed
    self.products = {UpgradeCoffee:new()}
    self.product = nil
    self:select_random_product()
    self:set_sprite(images.machine_coffee)
    self.is_focused = false

    self.player_detection_radius = 40
    self.target_player = nil
end

function VendingMachine:update(dt)
    self:update_button_small(dt)

    local player, distance = self:get_nearest_player()
    self.is_focused = (distance <= self.player_detection_radius)

    self.target_player = ternary(self.is_focused, player, nil)
end

function VendingMachine:get_nearest_player()
	local shortest_dist_sqr = math.huge
	local nearest_player = nil
	for _, ply in pairs(game.players) do
		local dist = distsqr(self.mid_x, self.mid_y, ply.mid_x, ply.mid_y)
		if dist < shortest_dist_sqr then
			shortest_dist_sqr = dist
			nearest_player = ply
		end
	end
	return nearest_player, math.sqrt(shortest_dist_sqr)
end

function VendingMachine:select_random_product()
    self.product = self.products[random_range_int(1, #self.products)]
end

function VendingMachine:on_press()
    if self.product then
        game:apply_upgrade(self.product)
    end
end

function VendingMachine:draw()
	self:draw_enemy()

    if self.is_focused then
        self.product:draw(self.mid_x, self.mid_y - self.h)
    end
end

return VendingMachine