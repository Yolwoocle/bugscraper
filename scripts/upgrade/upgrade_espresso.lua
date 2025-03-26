require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectEspresso = require "scripts.effect.effect_espresso"

local UpgradeEspresso = Upgrade:inherit()

function UpgradeEspresso:init()
    UpgradeEspresso.super.init(self, "espresso")
    self.sprite = images.upgrade_espresso
    self.strength = 2.0
    self.duration = 20 -- Lasts for X floors 
    self:set_description(self.strength, self.duration)

    self.color = COL_MID_BROWN
    self.palette = {COL_MID_BROWN, COL_LIGHT_BROWN, COL_DARK_BROWN}
end

function UpgradeEspresso:update(dt)
    UpgradeEspresso.super:update(self, dt)
end

function UpgradeEspresso:apply_instant(player)
    player:apply_effect(EffectEspresso:new(self.strength), self.duration, {duration_unit = "floor"})
end

function UpgradeEspresso:on_finish(player)
end

return UpgradeEspresso