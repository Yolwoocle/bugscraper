require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"

local UpgradeBoba = Upgrade:inherit()

function UpgradeBoba:init()
    self.name = "boba"
    self:init_upgrade()
    self.sprite = images.upgrade_boba
    self.strength = 2.0

    self.color = COL_PINK
end

function UpgradeBoba:update(dt)
    UpgradeBoba.super:update(self, dt)
end

function UpgradeBoba:apply_permanent(player)
    player:multiply_max_ammo_multiplier(self.strength)
end

function UpgradeBoba:on_finish(player)
end

return UpgradeBoba