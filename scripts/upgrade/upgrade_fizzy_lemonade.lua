require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeFizzyLemonade = Upgrade:inherit()

function UpgradeFizzyLemonade:init()
    UpgradeFizzyLemonade.super.init(self, "fizzy_lemonade")
    self.sprite = images.upgrade_fizzy_lemonade

    self.color = COL_LIGHT_YELLOW
    self.palette = {COL_LIGHT_BEIGE, COL_LIGHT_YELLOW, COL_YELLOW_ORANGE}

    self.activate_sound = "sfx_upgrades_fizzy_lemonade_pickedup"
end

function UpgradeFizzyLemonade:update(player, dt)
    UpgradeFizzyLemonade.super:update(self, player, dt)
end

function UpgradeFizzyLemonade:apply_permanent(player)
    player.can_hold_jump_to_float = true
end

function UpgradeFizzyLemonade:apply_instant(player)
end

function UpgradeFizzyLemonade:play_effects(player)
end

function UpgradeFizzyLemonade:on_finish(player)
end



return UpgradeFizzyLemonade