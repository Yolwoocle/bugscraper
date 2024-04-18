require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeMilk = Upgrade:inherit()

function UpgradeMilk:init()
    self:init_upgrade()
    self.name = "upgrade_more_life"
    self.sprite = images.upgrade_milk

    self.color = COL_WHITE
    self.title = "MILK"
    self.description = "+1 permanent ❤"
end

function UpgradeMilk:update(dt)
    self:update_upgrade(dt)
end

function UpgradeMilk:on_apply(player)
    player:add_max_life(1)
    player:heal(1)
end

function UpgradeMilk:on_finish(player)
end

return UpgradeMilk