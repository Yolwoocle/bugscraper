require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images = require "data.images"

local UpgradeSoda = Upgrade:inherit()

function UpgradeSoda:init()
    self.name = "soda"
    self:init_upgrade()
    self.sprite = images.upgrade_soda

    self.strength = 1

    self.color = COL_LIGHT_RED
end

function UpgradeSoda:update(dt)
    self:update_upgrade(dt)
end

function UpgradeSoda:apply_permanent(player)
    -- player:add_fury_max(self.strength_fury_max)
    player:add_max_jumps(self.strength)
    -- player.can_do_midair_jump = true
end

function UpgradeSoda:on_finish(player)
end

return UpgradeSoda