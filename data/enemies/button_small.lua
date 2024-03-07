require "scripts.util"
local Enemy = require "scripts.enemy"
local images = require "data.images"
local ButtonBig = require "data.enemies.button_big"

local ButtonSmallPressed = require "data.enemies.button_small_pressed"

local ButtonSmall = ButtonBig:inherit()

function ButtonSmall:init(x, y)
    self:init_button_big(x, y)

    self.name = "button_small"
    self.max_life = 40

    self.spawned_button_pressed = ButtonSmallPressed
    self:set_sprite(images.small_button)
end

function ButtonSmall:on_stomped(damager)
    game:screenshake(5)
    -- game:on_red_button_pressed()
    Audio:play("button_press")
    
    -- TODO: smoke particles
    -- local b = ButtonPressed:new(CANVAS_WIDTH/2, game.world_generator.box_rby)
    local b = ButtonSmallPressed:new(self.x, self.y)
    game:new_actor(b)
end

function ButtonSmall:on_death(damager, reason)
    if reason ~= "stomped" then
        -- game:screenshake(15)
        -- Audio:play("glass_fracture", nil, 0.2)
        -- game:enable_endless_mode()
        -- -- particles:image(self.mid_x, self.mid_y, 100, images.ptc_glass_shard, self.h)
        -- Particles:image(self.mid_x, self.mid_y, 300, {
        --     images.btnfrag_1,
        --     images.btnfrag_2,
        --     images.btnfrag_3,
        --     images.btnfrag_4,
        --     images.btnfrag_5,
        -- }, self.h, 6, 0.05, 0, parms)
        -- Particles:word(self.mid_x, self.mid_y, "ENDLESS MODE!")
    end
end

return ButtonSmall