require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeTemporaryLife = Upgrade:inherit()

function UpgradeTemporaryLife:init()
    self:init_upgrade()
    self.name = "upgrade_temporary_life"
    self.sprite = images.upgrade_coffee
end

function UpgradeTemporaryLife:update(dt)
    self:update_upgrade(dt)
end

function UpgradeTemporaryLife:on_apply(player)
    player:add_temporary_life(1)
end

function UpgradeTemporaryLife:on_finish(player)
end

return UpgradeTemporaryLife