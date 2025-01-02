require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeTea = Upgrade:inherit()

function UpgradeTea:init()
    UpgradeTea.super.init(self, "tea")
    self.sprite = images.upgrade_tea
    self.number_of_hearts = 2
    self:set_description(self.number_of_hearts)

    self.color = COL_MID_GREEN
end

function UpgradeTea:update(dt)
    UpgradeTea.super:update(self, dt)
end

function UpgradeTea:apply_instant(player)
    player:add_temporary_life(self.number_of_hearts)
end

function UpgradeTea:play_effects(player)
    -- Particles:smoke(player.mid_x, player.mid_y, 8, COL_LIGHT_GREEN)
    Particles:smoke_big(player.mid_x, player.mid_y, COL_LIGHT_GREEN)
    Particles:image(player.mid_x, player.mid_y, self.number_of_hearts, images.particle_leaf, 5, 1.5, 0.6, 0.5)
end

function UpgradeTea:on_finish(player)
end



return UpgradeTea