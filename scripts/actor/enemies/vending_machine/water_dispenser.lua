require "scripts.util"
local images = require "data.images"
local VendingMachine = require "scripts.actor.enemies.vending_machine.vending_machine"

local UpgradeWater = require "scripts.upgrade.upgrade_water"

local utf8 = require "utf8"

local WaterDispenser = VendingMachine:inherit()

function WaterDispenser:init(x, y)
    WaterDispenser.super.init(self, x, y, 15, 45)
    self.name = "water_dispenser"
    
    self:set_image(images.water_dispenser)
    self.sprite_pressed = images.water_dispenser

    self.products = {
        UpgradeWater:new(),
    }
    
    self.disappear_after_press = false
    self.show_text = false
    self.show_preview = false
    self.do_collected_particle = true

    self:set_pressed(true)
end

return WaterDispenser