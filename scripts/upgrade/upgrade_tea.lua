require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeTea = Upgrade:inherit()

function UpgradeTea:init()
    self.name = "tea"
    self:init_upgrade()
    self.sprite = images.upgrade_tea
    self.number_of_hearts = 2

    self.color = COL_MID_GREEN
end

function UpgradeTea:update(dt)
    self:update_upgrade(dt)
end

function UpgradeTea:on_apply(player)
    player:add_temporary_life(self.number_of_hearts)

    -- Particles:smoke(player.mid_x, player.mid_y, 8, COL_LIGHT_GREEN)
    Particles:smoke_big(player.mid_x, player.mid_y, COL_LIGHT_GREEN)
    Particles:image(player.mid_x, player.mid_y, self.number_of_hearts, images.particle_leaf, 5, 1.5, 0.6, 0.5)
end

function UpgradeTea:on_finish(player)
end



return UpgradeTea