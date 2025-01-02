require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"

local UpgradeEnergyDrink = Upgrade:inherit()

function UpgradeEnergyDrink:init()
    UpgradeEnergyDrink.super.init(self, "energy_drink")
    self.sprite = images.upgrade_energy_drink
    -- self.strength_fury_max = 5.0
    self.strength_fury_speed = 0.5

    self.color = COL_PURPLE
end

function UpgradeEnergyDrink:update(dt)
    UpgradeEnergyDrink.super:update(self, dt)
end

function UpgradeEnergyDrink:apply_permanent(player)
    -- player:add_fury_max(self.strength_fury_max)
    player:multiply_fury_speed(self.strength_fury_speed)
    player.has_energy_drink = true
end

function UpgradeEnergyDrink:on_finish(player)
end

return UpgradeEnergyDrink