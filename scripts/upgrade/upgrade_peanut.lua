require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"

local UpgradePeanut = Upgrade:inherit()

function UpgradePeanut:init()
    self.name = "peanut"
    self:init_upgrade()
    self.sprite = images.upgrade_peanut
    self.strength = 2.0

    self.color = COL_MID_BEIGE
end

function UpgradePeanut:update(dt)
    UpgradePeanut.super:update(self, dt)
end

function UpgradePeanut:apply_permanent(player)
    player:multiply_max_ammo_multiplier(self.strength)
end

function UpgradePeanut:on_finish(player)
end

return UpgradePeanut