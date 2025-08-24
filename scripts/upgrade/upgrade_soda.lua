
require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"

local UpgradeSoda = Upgrade:inherit()

function UpgradeSoda:init()
    UpgradeSoda.super.init(self, "soda")
    self.sprite = images.upgrade_soda
    
    self.strength = 1
    self:set_description(self.strength)

    self.color = COL_LIGHT_RED
    self.palette = {COL_LIGHT_RED, COL_MID_BROWN, COL_DARK_BROWN}

    self.activate_sound = "sfx_upgrades_soda_pickedup"
end

function UpgradeSoda:update(dt)
    UpgradeSoda.super:update(self, dt)
end

function UpgradeSoda:apply_permanent(player)
    -- player:add_fury_max(self.strength_fury_max)
    player:add_max_jumps(self.strength)
    -- player.can_do_midair_jump = true
end

function UpgradeSoda:on_finish(player)
end

return UpgradeSoda