require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"

local UpgradeGuarana = Upgrade:inherit()

function UpgradeGuarana:init()
    UpgradeGuarana.super.init(self, "guarana")
    self.sprite = images.upgrade_guarana
    self.value = 10

    self:set_description()

    self.color = COL_LIGHT_RED
    self.palette = {COL_LIGHT_RED, COL_DARK_RED, COL_MID_GREEN}

    self.activate_sound = "sfx_upgrades_guarana_pickedup"
end

function UpgradeGuarana:update(player, dt)
    UpgradeGuarana.super:update(self, player, dt)
end

function UpgradeGuarana:apply_instant(player)
end

function UpgradeGuarana:apply_permanent(player)
end

function UpgradeGuarana:play_effects(player)
end

function UpgradeGuarana:on_finish(player)
end

function UpgradeGuarana:on_player_reload_gun(player)
    player:set_invincibility(self.value)
end



return UpgradeGuarana