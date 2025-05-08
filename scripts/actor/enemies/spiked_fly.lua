require "scripts.util"
local Enemy = require "scripts.actor.enemy"
local sounds = require "data.sounds"
local images = require "data.images"

local SpikedFly = Enemy:inherit()

function SpikedFly:init(x, y)
    self:init_enemy(x,y, images.spiked_fly, 15,15)
    self.name = "fly"
    self.is_flying = true
    self.life = 5

    self.is_stompable = false
    --self.speed_y = 0--self.speed * 0.5

    self.speed = random_range(7,13)
    self.speed_x = self.speed
    self.speed_y = self.speed*0.5

    self.gravity = 0
    self.friction_y = self.friction_x

	self.score = 15

    self.sound_death = {"sfx_enemies_stomp_gore_01", "sfx_enemies_stomp_gore_02", "sfx_enemies_stomp_gore_03", "sfx_enemies_stomp_gore_04"}
    self.sound_stomp = {"sfx_enemies_stomp_gore_01", "sfx_enemies_stomp_gore_02", "sfx_enemies_stomp_gore_03", "sfx_enemies_stomp_gore_04"}
end

return SpikedFly