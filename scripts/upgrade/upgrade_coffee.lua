require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeCoffee = Upgrade:inherit()

function UpgradeCoffee:init()
    self:init_upgrade()
    self.name = "upgrade_coffee"
    self.sprite = images.upgrade_coffee
end

function UpgradeCoffee:update(dt)
    self:update_upgrade(dt)
end

function UpgradeCoffee:on_apply(actor)
    actor:apply_effect(EffectSlowness:new(), 5)
end

function UpgradeCoffee:on_finish(actor)
end

return UpgradeCoffee