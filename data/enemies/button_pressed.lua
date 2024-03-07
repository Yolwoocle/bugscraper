require "scripts.util"
local Enemy = require "scripts.enemy"
local images = require "data.images"

local ButtonPressed = Enemy:inherit()

function ButtonPressed:init(x, y)
    -- x,y = CANVAS_WIDTH/2, game.world_generator.box_by * BLOCK_WIDTH 
    -- x = floor(x - 34/2)
    y = game.door_by - 40
    self:init_enemy(x,y, images.big_red_button_pressed, 34, 40)
    self.name = "button_pressed"
    self.follow_player = false

    self.max_life = 999999
    self.life = self.max_life
    
    self.knockback = 0
    self.is_solid = false
    self.is_stompable = false
    self.is_pushable = false
    self.is_knockbackable = false
    self.loot = {}

    self.gravity = 0
    self.gravity_y = 0
    self.squash = 2

    self.damage = 0
end

function ButtonPressed:update(dt)
    self:update_enemy(dt)
    -- self.squash = lerp(self.squash, 1, 0.2)
    -- self.sx = self.squash
    -- self.sy = 1/self.squash
end

return ButtonPressed