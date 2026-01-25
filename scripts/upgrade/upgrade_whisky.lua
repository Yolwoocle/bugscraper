require "scripts.util"
local Upgrade = require "scripts.upgrade.upgrade"
local images= require "data.images"
local EffectSlowness = require "scripts.effect.effect_slowness"

local UpgradePomegranateJuice = Upgrade:inherit()

function UpgradePomegranateJuice:init()
    UpgradePomegranateJuice.super.init(self, "whisky") 
    self.sprite = images.upgrade_whisky

    self.color = COL_DARK_BROWN
    self.palette = {COL_DARK_BROWN, COL_DARK_RED, COL_MID_BROWN}

    self.activate_sound = "vavava"
end

function UpgradePomegranateJuice:update(player, dt)
    UpgradePomegranateJuice.super:update(self, player, dt)
end

function UpgradePomegranateJuice:apply_permanent(player, is_revive)
    player.vatefairefoutre = true
end

function UpgradePomegranateJuice:play_effects(player)
end

function UpgradePomegranateJuice:on_finish(player)
end

return UpgradePomegranateJuice