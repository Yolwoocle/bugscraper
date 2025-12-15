require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeHotChocolate = Upgrade:inherit()

function UpgradeHotChocolate:init()
    UpgradeHotChocolate.super.init(self, "hot_chocolate")
    self.sprite = images.upgrade_hot_chocolate
    self.value = 1.5

    self:set_description(self.value)

    self.color = COL_LIGHT_BROWN
    self.palette = {COL_LIGHT_BROWN, COL_WHITE, COL_MID_BROWN}

    self.activate_sound = "sfx_upgrades_hot_chocolate_pickedup"
end

function UpgradeHotChocolate:update(dt)
    UpgradeHotChocolate.super:update(self, dt)
end

function UpgradeHotChocolate:apply_instant(player)
end

function UpgradeHotChocolate:apply_permanent(player)
    player.gun_reload_speed_multiplier = self.value
    player.gun_natural_recharge_speed_multiplier = self.value
end

function UpgradeHotChocolate:play_effects(player)
end

function UpgradeHotChocolate:on_finish(player)
end

return UpgradeHotChocolate