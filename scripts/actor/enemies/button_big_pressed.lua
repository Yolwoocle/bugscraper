require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local images = require "data.images"

local ButtonBigPressed = Enemy:inherit()

function ButtonBigPressed:init(x, y)
    self:init_button_big_pressed(x, y)
end

function ButtonBigPressed:init_button_big_pressed(x, y)
    self:init_enemy(x,y, images.big_red_button_pressed, 34, 40)
    self.name = "button_big_pressed"
    self.follow_player = false

    self.max_life = 999999
    self.life = self.max_life
    self.score = 0
    
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