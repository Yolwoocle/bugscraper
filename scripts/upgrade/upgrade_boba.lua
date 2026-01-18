require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"

local UpgradeBoba = Upgrade:inherit()

function UpgradeBoba:init()
    UpgradeBoba.super.init(self, "boba")
    self.sprite = images.upgrade_boba
    self.strength = 2.0
    self:set_description(self.strength)

    self.color = COL_PINK
    self.palette = {COL_PINK, COL_PURPLE, COL_DARK_BROWN}

    self.activate_sound = "sfx_upgrades_boba_pickedup"
end

function UpgradeBoba:update(player, dt)
    UpgradeBoba.super:update(self, player, dt)
end

function UpgradeBoba:apply_permanent(player)
    player:multiply_max_ammo_multiplier(self.strength)
end

function UpgradeBoba:on_finish(player)
end

return UpgradeBoba