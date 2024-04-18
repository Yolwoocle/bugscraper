require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectCoffee = require "scripts.effect.effect_coffee"

local UpgradeEspresso = Upgrade:inherit()

function UpgradeEspresso:init()
    self:init_upgrade()
    self.name = "upgrade_coffee"
    self.sprite = images.upgrade_coffee

    self.color = COL_DARK_BROWN
    self.title = "ESPRESSO"
    self.description = "x2 shooting speed for a minute"
end

function UpgradeEspresso:update(dt)
    self:update_upgrade(dt)
end

function UpgradeEspresso:on_apply(player)
    player:apply_effect(EffectCoffee:new(), 60)
end

function UpgradeEspresso:on_finish(player)
end

return UpgradeEspresso