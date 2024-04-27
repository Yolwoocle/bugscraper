require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeTea = Upgrade:inherit()

function UpgradeTea:init()
    self.name = "tea"
    self:init_upgrade()
    self.sprite = images.upgrade_tea

    self.color = COL_MID_GREEN
end

function UpgradeTea:update(dt)
    self:update_upgrade(dt)
end

function UpgradeTea:on_apply(player)
    player:add_temporary_life(2)

    Particles:smoke(player.mid_x, player.mid_y, 8, COL_LIGHT_GREEN)
end

function UpgradeTea:on_finish(player)
end



return UpgradeTea