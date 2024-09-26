require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectCoffee = require "scripts.effect.effect_espresso"

local UpgradeEspresso = Upgrade:inherit()

function UpgradeEspresso:init()
    self.name = "espresso"
    self:init_upgrade()
    self.sprite = images.upgrade_coffee

    self.color = COL_MID_BROWN
end

function UpgradeEspresso:update(dt)
    self:update_upgrade(dt)
end

function UpgradeEspresso:apply_instant(player)
    player:apply_effect(EffectCoffee:new(), 60)
end

function UpgradeEspresso:on_finish(player)
end

return UpgradeEspresso