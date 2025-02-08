require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"

local UpgradeHotSauce = Upgrade:inherit()

function UpgradeHotSauce:init()
    UpgradeHotSauce.super.init(self, "hot_sauce")
    self.sprite = images.upgrade_hot_sauce
    self.color = COL_DARK_RED
    self.palette = {COL_LIGHT_RED, COL_DARK_RED, COL_MID_GREEN}

    self.ammo_usage = 2.0
    self.damage_mult = 2.0
    self:set_description(self.damage_mult, self.ammo_usage)
end

function UpgradeHotSauce:update(dt)
    UpgradeHotSauce.super:update(self, dt)
end

function UpgradeHotSauce:apply_permanent(player)
    player:set_ammo_usage_multiplier(self.ammo_usage)
    player:set_gun_damage_multiplier(self.damage_mult)

	player.ammo_bar_icon = images.ammo_hot_sauce
	player.ammo_bar_fill_color = COL_DARK_RED
	player.ammo_bar_shad_color = COL_DARK_BROWN
end

function UpgradeHotSauce:on_finish(player)
end

return UpgradeHotSauce