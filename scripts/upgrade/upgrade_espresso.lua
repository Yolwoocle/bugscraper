require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectEspresso = require "scripts.effect.effect_espresso"

local UpgradeEspresso = Upgrade:inherit()

function UpgradeEspresso:init()
    UpgradeEspresso.super.init(self, "espresso")
    self.sprite = images.upgrade_espresso
    self.strength = 2.0
    self:set_description(self.strength)

    self.color = COL_MID_BROWN
end

function UpgradeEspresso:update(dt)
    UpgradeEspresso.super:update(self, dt)
end

function UpgradeEspresso:apply_instant(player)
    player:apply_effect(EffectEspresso:new(self.strength), 60)
end

function UpgradeEspresso:on_finish(player)
end

return UpgradeEspresso