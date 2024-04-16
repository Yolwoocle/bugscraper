require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"

local ButtonBigPressed = Enemy:inherit()

function ButtonBigPressed:init(x, y)
    self:init_button_big_pressed(x, y)
end

function ButtonBigPressed:init_button_big_pressed(x, y)
    -- x,y = CANVAS_WIDTH/2, game.world_generator.box_by * BLOCK_WIDTH 
    -- x = floor(x - 34/2)
    y = game.door_by - 40
    self:init_enemy(x,y, images.big_red_button_pressed, 34, 40)
    self.name = "button_big_pressed"
    self.follow_player = false

    self.max_life = 999999
    self.life = self.max_life
    
    self.knockback = 0
    self.is_stompable = false
    self.is_pushable = false
    self.is_knockbackable = false
    self.loot = {}

    self.gravity = 0
    self.gravity_y = 0
    self.squash = 2

    self.damage = 0
end


return ButtonBigPressed