require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeFizzyLemon = Upgrade:inherit()

function UpgradeFizzyLemon:init()
    self.name = "fizzy_lemonade"
    self:init_upgrade()
    self.sprite = images.upgrade_fizzy_lemonade

    self.color = COL_LIGHT_YELLOW
end

function UpgradeFizzyLemon:update(dt)
    UpgradeFizzyLemon.super:update(self, dt)
end

function UpgradeFizzyLemon:apply_instant(player)
    player.can_hold_jump_to_float = true
end

function UpgradeFizzyLemon:play_effects(player)
end

function UpgradeFizzyLemon:on_finish(player)
end



return UpgradeFizzyLemon