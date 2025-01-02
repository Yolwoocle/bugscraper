require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradeAppleJuice = Upgrade:inherit()

function UpgradeAppleJuice:init()
    UpgradeAppleJuice.super.init(self, "apple_juice")
    self.sprite = images.upgrade_apple_juice
    self.strength = 1
    self:set_description(self.strength)

    self.color = COL_LIGHT_GREEN
end
    
function UpgradeAppleJuice:update(dt)
    UpgradeAppleJuice.super:update(self, dt)
end

function UpgradeAppleJuice:apply_permanent(player)
end

function UpgradeAppleJuice:apply_instant(player)
    player:heal(self.strength)
end


function UpgradeAppleJuice:play_effects(player)
	Particles:word(player.mid_x, player.y, concat(self.strength, "❤"), COL_LIGHT_RED)
end

function UpgradeAppleJuice:on_finish(player)
end

return UpgradeAppleJuice