require "scripts.util"
local images = require "data.images"

local BreakableCrate = require "scripts.actor.enemies.breakable_crate"
local Button = require "scripts.actor.enemies.button_big"

local ButtonBigGlass = BreakableCrate:inherit()

function ButtonBigGlass:init(x, y, img, w, h)
    ButtonBigGlass.super.init(self, x, y, images.big_red_button_crack3, 58, 45)
    self.name = "button_big_glass"

    self.images_cracked = {
        images.big_red_button_crack0,
        images.big_red_button_crack1,
        images.big_red_button_crack2,
        images.big_red_button_crack3,
    }

    self.spawned_actor = Button

    self.max_life = 80
    self.life = self.max_life
end

return ButtonBigGlass