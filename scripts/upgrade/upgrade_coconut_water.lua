require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"

local UpgradeCoconutWater = Upgrade:inherit()

function UpgradeCoconutWater:init()
    UpgradeCoconutWater.super.init(self, "coconut_water")
    self.sprite = images.upgrade_coconut_water
    self.value = 0.5

    self:set_description(self.value * 100)

    self.color = COL_WHITE
end

function UpgradeCoconutWater:update(dt)
    UpgradeCoconutWater.super:update(self, dt)
end

function UpgradeCoconutWater:apply_instant(player)
end

function UpgradeCoconutWater:apply_permanent(player)
    player.ammo_percent_gain_on_stomp = self.value
end

function UpgradeCoconutWater:play_effects(player)
end

function UpgradeCoconutWater:on_finish(player)
end



return UpgradeCoconutWater