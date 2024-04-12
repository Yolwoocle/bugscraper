require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeCoffee = Upgrade:inherit()

function UpgradeCoffee:init()
    self:init_upgrade()
    self.name = "upgrade_coffee"
    self.sprite = images.upgrade_coffee

    self.color = COL_MID_BROWN
end

function UpgradeCoffee:update(dt)
    self:update_upgrade(dt)
end

function UpgradeCoffee:on_apply(player)
    player:apply_effect(EffectSlowness:new(), 5)
end

function UpgradeCoffee:on_finish(player)
end

return UpgradeCoffee