require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"
local EffectCoffee = require "scripts.effect.effect_coffee"

local UpgradePeanut = Upgrade:inherit()

function UpgradePeanut:init()
    self:init_upgrade()
    self.name = "upgrade_coffee"
    self.sprite = images.upgrade_peanut
    self.strength = 2.0

    self.color = COL_MID_BEIGE
    self.title = "PEANUT"
    self.description = "x2 maximum ammo"
end

function UpgradePeanut:update(dt)
    self:update_upgrade(dt)
end

function UpgradePeanut:on_apply(player)
    player:multiply_max_ammo_multiplier(self.strength)
end

function UpgradePeanut:on_finish(player)
end

return UpgradePeanut