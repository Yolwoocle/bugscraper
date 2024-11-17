require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeMilk = Upgrade:inherit()

function UpgradeMilk:init()
    self.name = "milk"
    self:init_upgrade()
    self.sprite = images.upgrade_milk
    self.strength = 1

    self.color = COL_WHITE
end

function UpgradeMilk:update(dt)
    UpgradeMilk.super:update(self, dt)
end

function UpgradeMilk:apply_permanent(player)
    player:add_max_life(self.strength)
end

function UpgradeMilk:apply_instant(player)
    player:heal(self.strength)
end

function UpgradeMilk:on_finish(player)
end

return UpgradeMilk