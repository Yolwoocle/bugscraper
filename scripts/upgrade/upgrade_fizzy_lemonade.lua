require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeFizzyLemonade = Upgrade:inherit()

function UpgradeFizzyLemonade:init()
    UpgradeFizzyLemonade.super.init(self, "fizzy_lemonade")
    self.sprite = images.upgrade_fizzy_lemonade

    self.color = COL_LIGHT_YELLOW
end

function UpgradeFizzyLemonade:update(dt)
    UpgradeFizzyLemonade.super:update(self, dt)
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