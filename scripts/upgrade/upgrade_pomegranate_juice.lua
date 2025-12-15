require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradePomegranateJuice = Upgrade:inherit()

function UpgradePomegranateJuice:init()
    UpgradePomegranateJuice.super.init(self, "pomegranate_juice") 
    self.sprite = images.upgrade_pomegranate_juice

    self.color = COL_PURPLE
    self.palette = {COL_PURPLE, COL_DARK_RED, COL_DARK_PURPLE}

    self.activate_sound = "sfx_upgrades_pomegranate_juice_pickedup"
end

function UpgradePomegranateJuice:update(dt)
    UpgradePomegranateJuice.super:update(self, dt)
end

function UpgradePomegranateJuice:apply_permanent(player, is_revive)
    player.spawn_explosion_on_damage = true
end

function UpgradePomegranateJuice:play_effects(player)
end

function UpgradePomegranateJuice:on_finish(player)
end

return UpgradePomegranateJuice