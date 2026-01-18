require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeMilk = Upgrade:inherit()

function UpgradeMilk:init()
    UpgradeMilk.super.init(self, "milk")
    self.sprite = images.upgrade_milk
    self.strength = 1
    self:set_description(self.strength)
    
    self.color = COL_MID_BLUE
    self.palette = {COL_MID_BLUE, COL_WHITE, COL_DARK_BLUE}

    self.activate_sound = "sfx_upgrades_milk_pickedup"
end

function UpgradeMilk:update(player, dt)
    UpgradeMilk.super:update(self, player, dt)
end

function UpgradeMilk:apply_permanent(player)
    player:add_max_life(self.strength)
end

function UpgradeMilk:apply_instant(player)
end

function UpgradeMilk:on_finish(player)
end

return UpgradeMilk