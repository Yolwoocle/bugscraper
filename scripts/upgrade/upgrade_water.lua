require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeWater = Upgrade:inherit()

function UpgradeWater:init()
    UpgradeWater.super.init(self, "water") 
    self.sprite = images.upgrade_water

    self.color = COL_LIGHT_BLUE
    self.palette = {COL_LIGHT_BLUE, COL_MID_BLUE, COL_DARK_BLUE}

    self.activate_sound = "sfx_upgrades_water_pickedup"
end

function UpgradeWater:update(player, dt)
    UpgradeWater.super:update(self, player, dt)
end

function UpgradeWater:apply_instant(player)
end

function UpgradeWater:play_effects(player)
    Particles:smoke_big(player.mid_x, player.mid_y, COL_LIGHT_BLUE)
end

function UpgradeWater:on_finish(player)
    Particles:image(player.mid_x, player.mid_y, 1, images.upgrade_water, _spw_rad, 3, 0, 2)
end



return UpgradeWater