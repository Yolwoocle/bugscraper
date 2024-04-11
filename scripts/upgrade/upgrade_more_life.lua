require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeMoreLife = Upgrade:inherit()

function UpgradeMoreLife:init()
    self:init_upgrade()
    self.name = "upgrade_more_life"
    self.sprite = images.upgrade_coffee
end

function UpgradeMoreLife:update(dt)
    self:update_upgrade(dt)
end

function UpgradeMoreLife:on_apply(player)
    player:add_max_life(1)
    player:heal(1)
end

function UpgradeMoreLife:on_finish(player)
end

return UpgradeMoreLife